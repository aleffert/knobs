//
//  EKNDeviceConnection.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDeviceConnection.h"

#import "EKNDevice.h"
#import "EKNNamedChannel.h"

#import "MYAddressLookup.h"
#import "MYBonjourService.h"
#import "BLIP.h"

@interface EKNDeviceConnection ()  <BLIPConnectionDelegate>

@property (strong, nonatomic) BLIPConnection* connection;
@property (strong, nonatomic) EKNDevice* activeDevice;

@end

@implementation EKNDeviceConnection

- (void)connectToDevice:(EKNDevice *)device {
    if(![self.activeDevice isEqual:device]) {
        self.activeDevice = device;
        self.connection = [[BLIPConnection alloc] initToAddress:device.service.addressLookup.addresses.anyObject];
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
        [self.delegate deviceConnectionClosed:self];
    }
}

- (void)connection:(TCPConnection *)connection failedToOpen:(NSError *)error {
    if(connection == self.connection) {
        NSLog(@"connection failed to open");
        self.activeDevice = nil;
    }
}

- (void)close {
    [self.connection close];
}

- (BOOL)connection:(BLIPConnection *)connection receivedRequest:(BLIPRequest *)request {
    EKNNamedChannel* channel = [[EKNNamedChannel alloc] init];
    channel.name = [request.properties valueOfProperty:@"channelName"];
    channel.ownerName = [request.properties valueOfProperty:@"ownerName"];
    [self.delegate deviceConnection:self receivedMessage:request.body onChannel:channel];
    return YES;
}

- (void)sendMessage:(NSData*)data onChannel:(EKNNamedChannel*)channel {
    BLIPRequest* request = [BLIPRequest requestWithBody:data properties:@{@"channelName": channel.name, @"ownerName" : channel.ownerName}];
    [self.connection sendRequest:request];
}

@end
