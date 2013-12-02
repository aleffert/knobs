//
//  EKNDevice.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNChunkConnection;

@interface EKNDevice : NSObject

- (id)initWithService:(NSNetService*)service;

@property (readonly, strong, nonatomic) NSString* hostName;
@property (readonly, assign, nonatomic) NSUInteger port;
@property (readonly, strong, nonatomic) NSString* serviceName;
@property (readonly, strong, nonatomic) NSString* displayName;

@property (readonly, assign, nonatomic) BOOL hasAddress;
@property (readonly, assign, nonatomic) NSData* addressData;

- (EKNChunkConnection*)makeConnection;
- (BOOL)isBackedByService:(NSNetService*)service;
- (BOOL)isEqualToDevice:(EKNDevice*)device;

@end


extern NSString* EKNDeviceResolvedAddresses;