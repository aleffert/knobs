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

/// Create a new channel. This will show up as a new tab in the desktop app
- (id <EKNChannel>)channelWithName:(NSString*)name fromPlugin:(id <EKNDevicePlugin>)plugin;
/// Send a message to the desktop plugin using this channel
- (void)sendMessage:(NSData*)message onChannel:(id <EKNChannel>)channel;

/// Is the connection active
@property (readonly, nonatomic, getter = isConnected) BOOL connected;

@end
