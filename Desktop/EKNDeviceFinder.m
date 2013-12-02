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

#import "NSArray+EKNFunctional.h"

NSString* EKNActiveDeviceListChangedNotification = @"EKNActiveDeviceListChangedNotification";

@interface EKNDeviceFinder () <NSNetServiceBrowserDelegate>

@property (strong, nonatomic) NSMutableArray* foundDevices;
@property (strong, nonatomic) NSNetServiceBrowser* browser;

@property (assign, nonatomic) BOOL isRunning;

@end

@implementation EKNDeviceFinder

- (id)init {
    if(self = [super init]) {
        self.browser = [[NSNetServiceBrowser alloc] init];
        self.browser.delegate = self;
        self.foundDevices = [NSMutableArray array];
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
    if(!self.isRunning) {
        self.isRunning = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceUpdated:) name:EKNDeviceResolvedAddresses object:nil];
        [self.browser searchForServicesOfType:EKNBonjourServiceType inDomain:@"local."];
    }
}

- (void)stop {
    if(self.isRunning) {
        self.isRunning = NO;
        [self.browser removeObserver:self forKeyPath:@"services" context:[self kvoContext]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EKNDeviceResolvedAddresses object:nil];
        [self.browser stop];
        [self.foundDevices removeAllObjects];
    }
}

- (void)deviceUpdated:(NSNotification*)notification {
    [self updateAvailableServices];
}

- (NSArray*)activeDevices {
    return self.foundDevices.copy;
}

- (void)updateAvailableServices {
    [[NSNotificationCenter defaultCenter] postNotificationName:EKNActiveDeviceListChangedNotification object:nil];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    EKNDevice* device = [[EKNDevice alloc] initWithService:aNetService];
    [self.foundDevices addObject:device];
    if(!moreComing) {
        [self updateAvailableServices];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSIndexSet* indexes = [self.foundDevices indexesOfObjectsPassingTest:^BOOL(EKNDevice* device, NSUInteger idx, BOOL *stop) {
        return [device isBackedByService:aNetService];
    }];
    [self.foundDevices removeObjectsAtIndexes:indexes];
    if(!moreComing) {
        [self updateAvailableServices];
    }
}

@end
