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

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) NSString* focusedViewID;

@property (strong, nonatomic) NSTimer* pushViewTimer;

@property (strong, nonatomic) NSMutableArray* queuedMessages;

@end

@implementation EKNViewFrobPlugin

+ (EKNViewFrobPlugin*)sharedPlugin {
    static dispatch_once_t onceToken;
    static EKNViewFrobPlugin* frobber = nil;
    dispatch_once(&onceToken, ^{
        frobber = [[EKNViewFrobPlugin alloc] init];
        [UIView frob_enable];
        frobber.focusOverlayWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        frobber.focusOverlayWindow.layer.borderWidth = 3;
        frobber.focusOverlayWindow.layer.borderColor = [UIColor colorWithRed:0 green:.5 blue:1. alpha:1.].CGColor;
        frobber.focusOverlayWindow.userInteractionEnabled = NO;
        frobber.focusOverlayWindow.windowLevel = UIWindowLevelAlert;
        frobber.focusOverlayWindow.hidden = YES;
    });
    return frobber;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.queuedMessages = [NSMutableArray array];
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
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageBegin}];
    [self.context sendMessage:data onChannel:self.channel];
}

- (void)endedConnection {
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

- (void)pushFocusedView:(NSTimer*)timer {
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
}

#pragma mark View Operations

- (void)flushMessages {
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageBatch, EKNViewFrobBatchMessagesKey : self.queuedMessages}];
    [self.context sendMessage:archive onChannel:self.channel];
}

- (void)enqueueMessage:(NSDictionary*)message {
    // TODO: Go through message list and remove redundant messages
    [self.queuedMessages addObject:message];
    if(self.queuedMessages.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self flushMessages];
        });
    }
}

@end

@implementation EKNViewFrobPlugin (EKNPrivate)

- (void)view:(UIView *)view didMoveToWindow:(UIWindow *)window {
    if(window == [UIApplication sharedApplication].keyWindow) {
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageUpdatedView, EKNViewFrobUpdatedViewKey : [view frob_info], EKNViewFrobUpdatedSuperviewKey : [view.superview frob_info]}];
        [self.context sendMessage:archive onChannel:self.channel];
    }
    else {
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageRemovedView, EKNViewFrobRemovedViewID : view.frob_viewID }];
        [self.context sendMessage:archive onChannel:self.channel];
    }
}


- (void)view:(UIView*)view didMoveToSuperview:(UIView*)superview {
    if(superview == nil) {
        [self enqueueMessage:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageRemovedView, EKNViewFrobRemovedViewID : view.frob_viewID}];
    }
    else {
        [self enqueueMessage:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageUpdatedView, EKNViewFrobUpdatedViewKey : [view frob_info], EKNViewFrobUpdatedSuperviewKey : [view.superview frob_info]}];
    }
}

- (void)viewUpdated:(UIView *)view {
    [self sendFullViewInfo:view];
}

@end