//
//  EKNDeviceFinder.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EKNDeviceFinder : NSObject

// EKNDevice array
@property (readonly, nonatomic, copy) NSArray* activeDevices;

- (void)start;
- (void)stop;

@end


extern NSString* EKNActiveDeviceListChangedNotification;