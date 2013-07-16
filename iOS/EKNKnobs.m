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
#import "EKNLoggerPlugin.h"
#import "EKNLiveKnobsPlugin.h"
#import "EKNViewFrobPlugin.h"
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

- (void)registerDefaultPlugins {
    [[EKNKnobs sharedController] registerPlugin:[EKNLoggerPlugin sharedPlugin]];
    
    // These only work on iOS 6. They actually use NSMapTable, not NSPointerArray
    // but NSMapTable is available, but hidden on iOS 5
    if([NSPointerArray class]) {
        [[EKNKnobs sharedController] registerPlugin:[EKNViewFrobPlugin sharedPlugin]];
        [[EKNKnobs sharedController] registerPlugin:[EKNLiveKnobsPlugin sharedPlugin]];
    }
}

- (void)registerPlugin:(id <EKNDevicePlugin>)plugin {
    [self.pluginRegistry setObject:plugin forKey:plugin.name];
    [plugin useContext:self.pluginContext];
}

- (void)start {
    self.enabled = YES;
    
    if(!self.listener.isOpen) {
        [self.listener open];
    }
    if(!self.bonjourBroadcast.isRunning) {
        self.bonjourBroadcast.port = self.listener.port;
        [self.bonjourBroadcast start];
    }
}

- (void)stop {
    self.enabled = NO;
}

- (void)stopBroadcasting {
    if(self.bonjourBroadcast.isRunning) {
        [self.bonjourBroadcast stop];
    }
    // TODO: Fix deadlock and reenable self.listener stop;
}

- (void)listener:(TCPListener *)listener didAcceptConnection:(BLIPConnection *)connection {
    self.connection = connection;
    connection.delegate = self;
    [self stopBroadcasting];
    NSLog(@"OPENING KNOBS CONNECTION");
    for(id <EKNDevicePlugin> plugin in self.pluginRegistry.allValues) {
        [plugin beganConnection];
    }
}

- (void)connectionDidClose:(TCPConnection *)connection {
    NSLog(@"CLOSING KNOBS CONNECTION");
    for(id <EKNDevicePlugin> plugin in self.pluginRegistry.allValues) {
        [plugin endedConnection];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connection = nil;
        if(self.enabled) {
            [self start];
        }
    });
}

- (BOOL)connection:(BLIPConnection *)connection receivedRequest:(BLIPRequest *)request {
    EKNNamedChannel* channel = [[EKNNamedChannel alloc] init];
    channel.name = [request.properties valueOfProperty:@"channelName"];
    channel.ownerName = [request.properties valueOfProperty:@"ownerName"];
    
    id <EKNDevicePlugin> plugin = [self.pluginRegistry objectForKey:channel.ownerName];
    [plugin receivedMessage:request.body onChannel:channel];
    return YES;
}

#pragma mark Plugin Context

- (BOOL)isConnected {
    return self.connection != nil;
}

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
