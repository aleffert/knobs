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
#import "EKNChunkConnection.h"

@interface EKNDeviceConnection ()  <EKNChunkConnectionDelegate>

@property (strong, nonatomic) EKNChunkConnection* connection;
@property (strong, nonatomic) EKNDevice* activeDevice;

@end

@implementation EKNDeviceConnection

- (void)connectToDevice:(EKNDevice *)device {
    if(![self.activeDevice isEqualToDevice:device] && (self.activeDevice != device)) {
        self.activeDevice = device;
        
        if(self.connection != nil) {
            [self.connection close];
            [self.delegate deviceConnectionClosed:self];
            self.connection = nil;
        }
        
        if(device != nil) {
            self.connection = [device makeConnection];
            self.connection.delegate = self;
            [self.connection open];
            NSLog(@"opened connection");
            [self.delegate deviceConnectionOpened:self];
        }
    }
}

- (void)connectionClosed:(EKNChunkConnection *)connection {
    if(connection == self.connection) {
        NSLog(@"closed connection");
        self.activeDevice = nil;
        [self.delegate deviceConnectionClosed:self];
        self.connection = nil;
    }
}

- (void)close {
    [self.connection close];
    self.connection = nil;
}

- (void)connection:(EKNChunkConnection *)connection receivedData:(NSData *)data withHeader:(NSDictionary *)header {
    EKNNamedChannel* channel = [[EKNNamedChannel alloc] init];
    channel.name = header[@"channelName"];
    channel.ownerName = header[@"ownerName"];
    [self.delegate deviceConnection:self receivedMessage:data onChannel:channel];
}

- (void)sendMessage:(NSData*)data onChannel:(EKNNamedChannel*)channel {
    NSDictionary* header = @{@"channelName": channel.name, @"ownerName" : channel.ownerName};
    [self.connection sendData:data withHeader:header];
}

@end
