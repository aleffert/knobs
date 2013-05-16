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

#import "UIView+EKNFrobInfo.h"

@interface EKNViewFrobPlugin ()

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@end

@implementation EKNViewFrobPlugin

+ (EKNViewFrobPlugin*)sharedFrobber {
    static dispatch_once_t onceToken;
    static EKNViewFrobPlugin* frobber = nil;
    dispatch_once(&onceToken, ^{
        frobber = [[EKNViewFrobPlugin alloc] init];
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
}

- (void)accumulateView:(UIView*)view infoInto:(NSMutableDictionary*)result {
    NSDictionary* viewInfo = [view frobInfo];
    [result setObject:viewInfo forKey:[NSString stringWithFormat:@"%p", view]];
    for(UIView* child in view.subviews) {
        [self accumulateView:child infoInto:result];
    }
}

- (void)sendInitialInfo {
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    
    UIView* rootView = [[UIApplication sharedApplication] keyWindow];
    [self accumulateView:rootView infoInto:info];
    
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey: EKNViewFrobMessageLoadAll, EKNViewFrobLoadAllViewInfosKey : info}];
    [self.context sendMessage:archive onChannel:self.channel];
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString* messageType = [message objectForKey:EKNViewFrobSentMessageKey];
    if([messageType isEqualToString:EKNViewFrobMessageLoadAll]) {
        [self sendInitialInfo];
    }
}

@end
