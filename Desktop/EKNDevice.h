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

@property (readonly, strong, nonatomic) NSString* hostname;
@property (readonly, assign, nonatomic) NSUInteger port;
@property (readonly, strong, nonatomic) NSString* name;

@end


extern NSString* EKNDeviceResolvedAddresses;