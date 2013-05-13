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

- (NSString*)hostname {
    return self.service.hostname;
}

- (NSString*)name {
    return self.service.name;
}

- (NSUInteger)port {
    return self.service.port;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p name=%@, hostname=%@, port=%ld", [self class], self, self.name, self.hostname, self.port];
}

- (NSUInteger)hash {
    return self.name.hash;
}

- (BOOL)isEqual:(EKNDevice*)device {
    if([device isKindOfClass:[EKNDevice class]]) {
        return [self.hostname isEqual:device.hostname] && [self.name isEqual:device.name];
    }
    else {
        return NO;
    }
}

@end
