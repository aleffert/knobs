//
//  EKNDeviceConnection.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BLIP.h"

@class EKNDevice;

@interface EKNDeviceConnection : NSObject <BLIPConnectionDelegate>

@property (readonly, nonatomic) EKNDevice* activeDevice;

- (void)connectToDevice:(EKNDevice*)device;

@end
