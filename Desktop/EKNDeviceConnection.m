//
//  EKNDeviceConnection.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDeviceConnection.h"

#import "EKNDevice.h"

#import "MYBonjourService.h"

@interface EKNDeviceConnection ()

@property (strong, nonatomic) BLIPConnection* connection;
@property (strong, nonatomic) EKNDevice* activeDevice;

@end

@implementation EKNDeviceConnection

- (void)connectToDevice:(EKNDevice *)device {
    if(![self.activeDevice isEqual:device]) {
        self.activeDevice = device;
        self.connection = [[BLIPConnection alloc] initToBonjourService:device.service];
        self.connection.delegate = self;
        [self.connection open];
    }
}

- (void) connectionDidOpen: (TCPConnection*)connection {
    NSLog(@"opened connection");
}

- (void)connectionDidClose:(TCPConnection *)connection {
    if(connection == self.connection) {
        NSLog(@"closed connection");
        self.activeDevice = nil;
    }
}

- (void)connection:(TCPConnection *)connection failedToOpen:(NSError *)error {
    if(connection == self.connection) {
        NSLog(@"connection failed to open");
        self.activeDevice = nil;
    }
}

@end
