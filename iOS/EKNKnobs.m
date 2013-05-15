//
//  EKNKnobs.m
//  Knobs-client
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobs.h"

#import "BLIP.h"
#import "MYBonjourRegistration.h"

#import "EKNDevicePluginContextDispatcher.h"
#import "EKNNamedChannel.h"
#import "EKNSharedConstants.h"

@interface EKNKnobs () <TCPListenerDelegate, EKNDevicePluginContextDispatcherDelegate, BLIPConnectionDelegate>

+ (EKNKnobs*)sharedController;

@property (strong, nonatomic) BLIPListener* listener;
@property (strong, nonatomic) BLIPConnection* connection;
@property (strong, nonatomic) MYBonjourRegistration* bonjourBroadcast;
@property (strong, nonatomic) NSMutableDictionary* pluginRegistry;
@property (strong, nonatomic) EKNDevicePluginContextDispatcher* pluginContext;

@property (assign, nonatomic) BOOL enabled;

@end

@implementation EKNKnobs

+ (EKNKnobs*)sharedController {
    static dispatch_once_t onceToken;
    static EKNKnobs* controller = nil;
    dispatch_once(&onceToken, ^{
        controller = [[EKNKnobs alloc] init];
    });
    
    return controller;
}

- (id)init {
    if(self = [super init]) {
        self.listener = [[BLIPListener alloc] initWithPort:0];
        self.listener.delegate = self;
        self.bonjourBroadcast = [[MYBonjourRegistration alloc] initWithServiceType:@"_knobs._tcp" port:0];
        self.bonjourBroadcast.name = [NSString stringWithFormat:@"%@ - %@", [[UIDevice currentDevice] name], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
        self.pluginRegistry = [[NSMutableDictionary alloc] init];
        self.pluginContext = [[EKNDevicePluginContextDispatcher alloc] init];
        self.pluginContext.delegate = self;
    }
    return self;
}

- (void)registerPlugin:(id <EKNDevicePlugin>)plugin {
    [self.pluginRegistry setObject:plugin forKey:plugin.name];
    [plugin useContext:self.pluginContext];
}

- (void)start {
    if(!self.enabled) {
        self.enabled = YES;
        [self.listener open];
        self.bonjourBroadcast.port = self.listener.port;
        [self.bonjourBroadcast start];
    }
}

- (void)stop {
    if(self.enabled) {
        [self.bonjourBroadcast stop];
        [self.listener close];
    }
    self.enabled = NO;
}

- (void)listener:(TCPListener *)listener didAcceptConnection:(BLIPConnection *)connection {
    self.connection = connection;
    connection.delegate = self;
    [self stop];
    NSLog(@"OPENING KNOBS CONNECTION");
}

- (void)connectionDidClose:(TCPConnection *)connection {
    self.connection = nil;
    NSLog(@"CLOSING KNOBS CONNECTION");
    if(self.enabled) {
        [self start];
    }
}

#pragma mark Plugin Context

- (id <EKNChannel>)channelWithName:(NSString *)name fromPlugin:(id<EKNDevicePlugin>)plugin {
    EKNNamedChannel* channel = [[EKNNamedChannel alloc] init];
    channel.name = name;
    channel.ownerName = plugin.name;
    
    return channel;
}

- (void)sendMessage:(NSData *)message onChannel:(EKNNamedChannel*)channel {
    BLIPRequest* request = [BLIPRequest requestWithBody:message properties:@{@"channelName": channel.name, @"ownerName" : channel.ownerName}];
    [self.connection sendRequest:request];
}

@end
