//
//  EKNDevice.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDevice.h"

#import "MYAddressLookup.h"
#import "MYBonjourService.h"

NSString* EKNDeviceResolvedAddresses = @"EKNDeviceResolvedAddresses";

@interface EKNDevice ()

@property (strong, nonatomic) MYBonjourService* service;
@property (assign, nonatomic) BOOL isObserving;

@end

@implementation EKNDevice

- (id)initWithService:(MYBonjourService *)service {
    if(self = [super init]) {
        self.service = service;
        if(self.service.hostname == nil) {
            [self.service.addressLookup addObserver:self forKeyPath:@"addresses" options:0 context:[self kvoContext]];
            [self.service.addressLookup start];
            self.isObserving = YES;
        }
    }
    return self;
}

- (void)dealloc {
    if(self.isObserving) {
        [self.service.addressLookup removeObserver:self forKeyPath:@"addresses" context:[self kvoContext]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == [self kvoContext]) {
        if([keyPath isEqualToString:@"addresses"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:EKNDeviceResolvedAddresses object:self];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void*)kvoContext {
    return (__bridge void*)[EKNDevice class];
}

- (NSString*)hostName {
    return self.service.hostname;
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

@end
