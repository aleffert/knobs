//
//  EKNConsolePlugin.h
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNChannel.h"

@protocol EKNConsoleControllerContext <NSObject>

- (void)sendMessage:(NSData*)data onChannel:(id <EKNChannel>)channel;

@end

@protocol EKNConsoleController <NSObject>

- (void)connectedToDeviceWithContext:(id <EKNConsoleControllerContext>)context onChannel:(id <EKNChannel>)channel;
- (void)receivedMessage:(NSData*)data onChannel:(id <EKNChannel>)channel;
- (void)disconnectedFromDevice;

@end

@protocol EKNConsolePlugin <NSObject>

@property (readonly, nonatomic) NSString* name;
@property (readonly, nonatomic) NSString* displayName;

- (NSViewController <EKNConsoleController>*)viewControllerWithChannel:(id <EKNChannel>)channel;

@end
