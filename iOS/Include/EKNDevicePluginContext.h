//
//  EKNDevicePluginContext.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EKNChannel;
@protocol EKNDevicePlugin;

@protocol EKNDevicePluginContext <NSObject>

- (id <EKNChannel>)channelWithName:(NSString*)name fromPlugin:(id <EKNDevicePlugin>)plugin;
- (void)sendMessage:(NSData*)message onChannel:(id <EKNChannel>)channel;
@property (readonly, nonatomic, getter = isConnected) BOOL connected;

@end
