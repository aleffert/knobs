//
//  EKNDevice.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDevice.h"

#import "EKNChunkConnection.h"

NSString* EKNDeviceResolvedAddresses = @"EKNDeviceResolvedAddresses";

@interface EKNDevice () <NSNetServiceDelegate>

@property (strong, nonatomic) NSNetService* service;
@property (assign, nonatomic) BOOL isObserving;

@end

@implementation EKNDevice

- (id)initWithService:(NSNetService *)service {
    if(self = [super init]) {
        self.service = service;
        self.service.delegate = self;
        if(self.service.hostName == nil) {
            [self.service resolveWithTimeout:60];
        }
    }
    return self;
}

- (BOOL)hasAddress {
    return self.service.addresses.count > 0;
}

- (void*)kvoContext {
    return (__bridge void*)[EKNDevice class];
}

- (NSString*)hostName {
    return self.service.hostName;
}

- (NSString*)serviceName {
    return self.service.name;
}

- (NSString*)displayName {
    return [NSString stringWithFormat:@"%@ - %@", self.serviceName, self.hostName];
}

- (NSUInteger)port {
    return self.service.port;
}

- (NSData*)addressData {
    return [self.service.addresses firstObject];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p serviceName=%@, hostName=%@, port=%ld", [self class], self, self.serviceName, self.hostName, self.port];
}

- (NSUInteger)hash {
    return self.serviceName.hash;
}

- (BOOL)isEqual:(id)device {
    return [device isKindOfClass:[EKNDevice class]] && [self isEqualToDevice:device];
}

- (BOOL)isEqualToDevice:(EKNDevice*)device {
    return [self.hostName isEqual:device.hostName] && [self.serviceName isEqual:device.serviceName];
}

- (BOOL)isBackedByService:(NSNetService *)service {
    return [self.service isEqual:service];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:EKNDeviceResolvedAddresses object:self];
}

- (EKNChunkConnection*)makeConnection {
    EKNChunkConnection* connection = [[EKNChunkConnection alloc] initWithNetService:self.service];
    return connection;
}

@end
