//
//  EKNDeviceFinder.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDeviceFinder.h"

#import "EKNDevice.h"
#import "EKNSharedConstants.h"

#import "MYBonjourBrowser.h"
#import "MYBonjourService.h"
#import "NSArray+EKNFunctional.h"

NSString* EKNActiveDeviceListChangedNotification = @"EKNActiveDeviceListChangedNotification";

@interface EKNDeviceFinder ()

@property (strong, nonatomic) MYBonjourBrowser* browser;
@property (copy, nonatomic) NSArray* foundDevices;

@end

@implementation EKNDeviceFinder

- (id)init {
    if(self = [super init]) {
        self.browser = [[MYBonjourBrowser alloc] initWithServiceType:EKNBonjourServiceType];
        self.browser.continuous = YES;
    }
    
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void*)kvoContext {
    return (__bridge void*)[EKNDeviceFinder class];
}

- (void)start {
    if(!self.browser.isRunning) {
        [self.browser addObserver:self forKeyPath:@"services" options:0 context:(__bridge void*)[EKNDeviceFinder class]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceUpdated:) name:EKNDeviceResolvedAddresses object:nil];
        [self.browser start];
        self.foundDevices = self.browser.services.allObjects;
    }
}

- (void)stop {
    if(self.browser.isRunning) {
        [self.browser removeObserver:self forKeyPath:@"services" context:[self kvoContext]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EKNDeviceResolvedAddresses object:nil];
        [self.browser stop];
        self.foundDevices = [NSArray array];
    }
}

- (void)deviceUpdated:(NSNotification*)notification {
    [self updateAvailableServices];
}

- (NSArray*)activeDevices {
    // Bring into an NSSet so we don't end up with duplicates on different ports
    return [[NSSet setWithArray:[self.foundDevices filter:^BOOL(EKNDevice* device) {
        // Strip out the iCloud WAN connections from back to my mac.
        // These cause the same device to show up twice and probably aren't what you want.
        return device.hostName != nil && NSMaxRange([device.hostName rangeOfString:@"icloud.com."]) != device.hostName.length;
    }]] allObjects];
}

- (void)updateAvailableServices {
    self.foundDevices = [self.browser.services.allObjects map:^id(MYBonjourService* service) {
        EKNDevice* device = [[EKNDevice alloc] initWithService:service];
        return device;
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:EKNActiveDeviceListChangedNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == [self kvoContext]) {
        if([keyPath isEqualToString:@"services"]) {
            [self updateAvailableServices];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
