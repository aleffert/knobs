//
//  EKNViewFrobPlugin.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobPlugin.h"

#import "EKNDevicePluginContext.h"
#import "EKNViewFrob.h"
#import "EKNViewFrobInfo.h"

#import "UIView+EKNFrobInfo.h"

@interface EKNViewFrobPlugin ()

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) NSString* focusedViewID;

@property (strong, nonatomic) NSTimer* pushViewTimer;

@end

@implementation EKNViewFrobPlugin

+ (EKNViewFrobPlugin*)sharedFrobber {
    static dispatch_once_t onceToken;
    static EKNViewFrobPlugin* frobber = nil;
    dispatch_once(&onceToken, ^{
        frobber = [[EKNViewFrobPlugin alloc] init];
        [UIView frob_enable];
    });
    return frobber;
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
    [self.pushViewTimer invalidate];
    self.pushViewTimer = nil;
}


- (void)sendInitialInfo {
    UIView* rootView = [[UIApplication sharedApplication] keyWindow];
    
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey: EKNViewFrobMessageUpdateAll, EKNViewFrobUpdateAllRootKey : [rootView frob_info]}];
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
    }
    else {
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
    }
}

#pragma mark View Operations

- (void)view:(UIView*)view didMoveToSuperview:(UIView*)superview {
    if(superview == nil) {
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageRemovedView, EKNViewFrobRemovedViewID : view.frob_viewID }];
        [self.context sendMessage:archive onChannel:self.channel];
    }
    else {
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageUpdatedView, EKNViewFrobUpdatedViewSuperviewKey : [superview frob_info] }];
        [self.context sendMessage:archive onChannel:self.channel];
    }
}

@end
