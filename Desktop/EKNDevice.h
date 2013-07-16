//
//  EKNDevice.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MYBonjourService;

@interface EKNDevice : NSObject

- (id)initWithService:(MYBonjourService*)service;

@property (readonly, strong, nonatomic) NSString* hostName;
@property (readonly, assign, nonatomic) NSUInteger port;
@property (readonly, strong, nonatomic) NSString* serviceName;
@property (readonly, strong, nonatomic) NSString* displayName;

@property (readonly, strong, nonatomic) MYBonjourService* service;

- (BOOL)isEqualToDevice:(EKNDevice*)device;

@end


extern NSString* EKNDeviceResolvedAddresses;