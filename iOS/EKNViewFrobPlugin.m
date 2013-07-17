//
//  EKNViewFrobPlugin.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EKNViewFrobPlugin.h"

#import "EKNDevicePluginContext.h"
#import "EKNPropertyInfo.h"
#import "EKNPropertyDescription.h"
#import "EKNViewFrob.h"
#import "EKNViewFrobInfo.h"

#import "UIView+EKNFrobInfo.h"

@interface EKNViewFrobPlugin ()

@property (strong, nonatomic) UIWindow* focusOverlayWindow;
@property (strong, nonatomic) UIView* tapSelectionView;

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) NSString* focusedViewID;

@property (strong, nonatomic) NSTimer* pushViewTimer;

@property (strong, nonatomic) NSMutableArray* queuedMessages;

@property (strong, nonatomic) NSHashTable* updatedViews;
@property (strong, nonatomic) NSMutableSet* updatedViewIDs;

@end

@implementation EKNViewFrobPlugin

+ (EKNViewFrobPlugin*)sharedPlugin {
    static dispatch_once_t onceToken;
    static EKNViewFrobPlugin* frobber = nil;
    dispatch_once(&onceToken, ^{
        frobber = [[EKNViewFrobPlugin alloc] init];
    });
    return frobber;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.queuedMessages = [NSMutableArray array];
        self.updatedViews = [NSHashTable weakObjectsHashTable];
        self.updatedViewIDs = [NSMutableSet set];
    }
    return self;
}

- (NSString*)name {
    return EKNViewFrobName;
}

- (void)useContext:(id<EKNDevicePluginContext>)context {
    self.context = context;
    self.channel = [self.context channelWithName:@"ViewFrobber" fromPlugin:self];
}

- (void)beganConnection {
    [UIView frob_enable];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageBegin}];
    [self.context sendMessage:data onChannel:self.channel];
}

- (void)endedConnection {
    [UIView frob_disable];
    self.focusedViewID = nil;
    self.focusOverlayWindow.hidden = YES;
    [self.pushViewTimer invalidate];
    self.pushViewTimer = nil;
}

- (void)recursivelyAccumulateInfoForView:(UIView*)view into:(NSMutableArray*)accumulation {
    [accumulation addObject:[view frob_info]];
    for(UIView* subview in view.subviews) {
        [self recursivelyAccumulateInfoForView:subview into:accumulation];
    }
}

- (void)sendInitialInfo {
    NSMutableArray* accumulation = [NSMutableArray array];
    
    UIView* rootView = [[UIApplication sharedApplication] keyWindow];
    [self recursivelyAccumulateInfoForView:rootView into:accumulation];
    
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey: EKNViewFrobMessageUpdateAll, EKNViewFrobUpdateAllRootKey : rootView.frob_viewID, EKNViewFrobUpdateAllInfosKey : accumulation}];
    [self.context sendMessage:archive onChannel:self.channel];
}

- (void)sendFullViewInfo:(UIView*)focusedView {
    NSArray* properties = [focusedView frob_properties];
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageUpdateProperties, EKNViewFrobUpdatedProperties : properties, EKNViewFrobUpdatedViewID : focusedView.frob_viewID}];
    [self.context sendMessage:archive onChannel:self.channel];
}

- (void)makeFocusWindowIfNecessary {
    if(self.focusOverlayWindow == nil) {
        self.focusOverlayWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        self.focusOverlayWindow.layer.borderWidth = 3;
        self.focusOverlayWindow.layer.borderColor = [UIColor colorWithRed:0 green:.5 blue:1. alpha:1.].CGColor;
        self.focusOverlayWindow.userInteractionEnabled = NO;
        self.focusOverlayWindow.windowLevel = UIWindowLevelAlert;
        self.focusOverlayWindow.hidden = YES;
    }
}

- (void)pushFocusedView:(NSTimer*)timer {
    [self makeFocusWindowIfNecessary];
    UIView* focusedView = [UIView frob_viewWithID:self.focusedViewID];
    if(focusedView == nil) {
        [timer invalidate];
        self.pushViewTimer = nil;
        self.focusedViewID = nil;
        self.focusOverlayWindow.hidden = YES;
    }
    else {
        self.focusOverlayWindow.hidden = NO;
        CGRect focusFrame = [focusedView convertRect:focusedView.bounds toView:nil];
        if(![focusedView isKindOfClass:[UIWindow class]]) {
            focusFrame = [focusedView.window convertRect:focusFrame toWindow:nil];
        }
        self.focusOverlayWindow.frame = focusFrame;
        [self sendFullViewInfo:focusedView];
    }
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString* messageType = [message objectForKey:EKNViewFrobSentMessageKey];
    if([messageType isEqualToString:EKNViewFrobMessageLoadAll]) {
        [self sendInitialInfo];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageFocusView]) {
        self.focusedViewID = [message objectForKey:EKNViewFrobFocusViewID];
        [self.pushViewTimer invalidate];
        self.pushViewTimer = nil;
        if(self.focusedViewID != nil) {
            self.pushViewTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(pushFocusedView:) userInfo:nil repeats:YES];
        }
        else {
            self.focusOverlayWindow.hidden = YES;
        }
    }
    else if([messageType isEqualToString:EKNViewFrobMessageChangedProperty]) {
        NSString* viewID = [message objectForKey:EKNViewFrobChangedPropertyViewID];
        UIView* view = [UIView frob_viewWithID:viewID];
        EKNPropertyInfo* info = [message objectForKey:EKNViewFrobChangedPropertyInfo];
        [info.propertyDescription setWrappedValue:info.value ofSource:view];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageActivateTapSelection]) {
        [self showSelectionView];
    }
    else {
        NSLog(@"Unknown knobs message type %@", messageType);
    }
}

#pragma mark Tap To Select

- (void)makeSelectionViewIfNecessary {
    if(self.tapSelectionView == nil) {
        self.tapSelectionView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        self.tapSelectionView.backgroundColor = [UIColor colorWithRed:0 green:.3 blue:.9 alpha:.3];
        UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choseView:)];
        [self.tapSelectionView addGestureRecognizer:tapGesture];
    }
}

- (void)showSelectionView {
    [self makeSelectionViewIfNecessary];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.tapSelectionView];
}

- (void)choseView:(UIGestureRecognizer*)gesture {
    UIWindow* window = self.tapSelectionView.window;
    CGPoint location = [window convertPoint:[gesture locationInView:self.tapSelectionView] toView:window];
    [self.tapSelectionView removeFromSuperview];
    UIView* tappedView = [window hitTest:location withEvent:nil];
    if(tappedView != nil) {
        NSDictionary* message = @{EKNViewFrobSentMessageKey: EKNViewFrobMessageSelect, EKNViewFrobSelectedViewID : tappedView.frob_viewID};
        [self enqueueMessage:message];
    }
}


#pragma mark View Operations

- (void)flushMessages {
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageBatch, EKNViewFrobBatchMessagesKey : self.queuedMessages}];
    [self.context sendMessage:archive onChannel:self.channel];
    [self.queuedMessages removeAllObjects];
}

- (void)enqueueMessage:(NSDictionary*)message {
    // TODO: Go through message list and remove redundant messages
    [self.queuedMessages addObject:message];

}

- (NSDictionary*)updatedViewMessage:(UIView*)view {
    return @{EKNViewFrobSentMessageKey : EKNViewFrobMessageUpdatedView, EKNViewFrobUpdatedViewKey : [view frob_info]};
}

- (NSDictionary*)removedViewIDMessage:(NSString*)viewID {
    return @{EKNViewFrobSentMessageKey : EKNViewFrobMessageRemovedView, EKNViewFrobRemovedViewID : viewID};
}

- (void)processUpdatedViews {
    NSMutableSet* removedViewIDs = self.updatedViewIDs.mutableCopy;
    for(UIView* view in self.updatedViews) {
        if(view.window == [UIApplication sharedApplication].keyWindow) {
            [removedViewIDs removeObject:view.frob_viewID];
            [self enqueueMessage:[self updatedViewMessage:view]];
        }
    }
    
    for(NSString* removedViewID in removedViewIDs) {
        [self enqueueMessage:[self removedViewIDMessage:removedViewID]];
    }
    
    [self flushMessages];
    [self.updatedViewIDs removeAllObjects];
    [self.updatedViews removeAllObjects];
}

@end

@implementation EKNViewFrobPlugin (EKNPrivate)

- (void)markViewUpdated:(UIView *)view {
    if(self.updatedViewIDs.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self processUpdatedViews];
        });
    }
    [self.updatedViews addObject:view];
    [self.updatedViewIDs addObject:view.frob_viewID];
    if(view.superview) {
        [self.updatedViews addObject:view.superview];
        [self.updatedViewIDs addObject:view.superview.frob_viewID];
    }
}

@end