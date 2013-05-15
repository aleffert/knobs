//
//  EKNDevicePluginContextDispatcher.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDevicePluginContextDispatcher.h"

@implementation EKNDevicePluginContextDispatcher

- (id <EKNChannel>)channelWithName:(NSString *)name fromPlugin:(id<EKNDevicePlugin>)plugin {
    return [self.delegate channelWithName:name fromPlugin:plugin];
}

- (void)sendMessage:(NSData *)message onChannel:(id <EKNChannel>)channel {
    [self.delegate sendMessage:message onChannel:channel];
}

- (BOOL)isConnected {
    return [self.delegate isConnected];
}

@end
