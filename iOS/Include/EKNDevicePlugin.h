//
//  EKNDevicePlugin.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EKNDevicePluginContext;
@protocol EKNChannel;

@protocol EKNDevicePlugin <NSObject>

@property (copy, nonatomic, readonly) NSString* name;

- (void)useContext:(id <EKNDevicePluginContext>)context;
- (void)beganConnection;
- (void)endedConnection;
- (void)receivedMessage:(NSData*)data onChannel:(id <EKNChannel>)channel;

@end
