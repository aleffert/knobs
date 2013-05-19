//
//  EKNDeviceConnection.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNDevice;
@class EKNNamedChannel;
@protocol EKNDeviceConnectionDelegate;

@interface EKNDeviceConnection : NSObject

@property (readonly, nonatomic) EKNDevice* activeDevice;
@property (weak, nonatomic) id <EKNDeviceConnectionDelegate> delegate;

- (void)connectToDevice:(EKNDevice*)device;
- (void)close;

- (void)sendMessage:(NSData*)data onChannel:(EKNNamedChannel*)channel;

@end


@protocol EKNDeviceConnectionDelegate <NSObject>

- (void)deviceConnection:(EKNDeviceConnection*)connection receivedMessage:(NSData*)data onChannel:(EKNNamedChannel*)channel;
- (void)deviceConnectionClosed:(EKNDeviceConnection *)connection;

@end