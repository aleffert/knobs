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

/// Protocol that all knobs plugins must implement
@protocol EKNDevicePlugin <NSObject>

/// Reverse DNS style unique ID
/// Must be the same as the EKNConsolePlugin loaded into the Desktop app
@property (copy, nonatomic, readonly) NSString* name;

/// Will be called when the plugin is loaded
/// A plugin should hold onto its context
- (void)useContext:(id <EKNDevicePluginContext>)context;

/// Called by the system when a connection to the desktop client is opened
- (void)beganConnection;

/// Called by the system when a connection to the desktop client is closed
- (void)endedConnection;

/// The format of data is internal to the plugin
- (void)receivedMessage:(NSData*)data onChannel:(id <EKNChannel>)channel;

@end
