//
//  EKNKnobs.m
//  Knobs-client
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobs.h"

#import "EKNChunkConnection.h"
#import "EKNDevicePluginContextDispatcher.h"
#import "EKNLoggerPlugin.h"
#import "EKNLiveKnobsPlugin.h"
#import "EKNViewFrobPlugin.h"
#import "EKNNamedChannel.h"
#import "EKNSharedConstants.h"

@interface EKNKnobs () <EKNDevicePluginContextDispatcherDelegate, EKNChunkConnectionDelegate, NSNetServiceDelegate>

+ (EKNKnobs*)sharedController;

@property (strong, nonatomic) EKNChunkConnection* connection;
@property (strong, nonatomic) NSNetService* bonjourBroadcast;
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
        self.pluginRegistry = [[NSMutableDictionary alloc] init];
        self.pluginContext = [[EKNDevicePluginContextDispatcher alloc] init];
        self.pluginContext.delegate = self;
    }
    return self;
}

- (void)registerDefaultPlugins {
    [[EKNKnobs sharedController] registerPlugin:[EKNLoggerPlugin sharedPlugin]];
    
    // These only work on iOS 6. They actually use NSMapTable, not NSPointerArray
    // but NSMapTable is available, but hidden, on iOS 5 so we can't just test for it
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
    [self startBroadcasting];
}

- (void)stop {
    self.enabled = NO;
    [self stopBroadcasting];
    [self.connection close];
}

- (void)startBroadcasting {
    NSString* name = [NSString stringWithFormat:@"%@ - %@", [[UIDevice currentDevice] name], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    self.bonjourBroadcast = [[NSNetService alloc] initWithDomain:@"" type:EKNBonjourServiceType name:name];
    self.bonjourBroadcast.delegate = self;
    [self.bonjourBroadcast publishWithOptions:NSNetServiceListenForConnections];
}

- (void)stopBroadcasting {
    [self.bonjourBroadcast publishWithOptions:NSNetServiceListenForConnections];
    [self.bonjourBroadcast stop];
    self.bonjourBroadcast = nil;
}

- (void)connectionClosed:(EKNChunkConnection *)connection {
    NSLog(@"CLOSING KNOBS CONNECTION");
    dispatch_async(dispatch_get_main_queue(), ^{
        for(id <EKNDevicePlugin> plugin in self.pluginRegistry.allValues) {
            [plugin endedConnection];
        }
        self.connection = nil;
        if(self.enabled) {
            [self start];
        }
    });
}

- (void)connection:(EKNChunkConnection *)connection receivedData:(NSData *)data withHeader:(NSDictionary *)header {
    EKNNamedChannel* channel = [[EKNNamedChannel alloc] init];
    channel.name = header[@"channelName"];
    channel.ownerName = header[@"ownerName"];
    
    id <EKNDevicePlugin> plugin = [self.pluginRegistry objectForKey:channel.ownerName];
    [plugin receivedMessage:data onChannel:channel];
}

#pragma mark NetServices

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    
    EKNChunkConnection* connection = [[EKNChunkConnection alloc] initWithInputStream:inputStream outputStream:outputStream];
    
    self.connection = connection;
    connection.delegate = self;
    
    [connection open];
    
    [self stopBroadcasting];
    NSLog(@"OPENING KNOBS CONNECTION");
    dispatch_async(dispatch_get_main_queue(), ^{
        for(id <EKNDevicePlugin> plugin in self.pluginRegistry.allValues) {
            [plugin beganConnection];
        }
    });
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
    NSDictionary* header = @{@"channelName": channel.name, @"ownerName" : channel.ownerName};
    [self.connection sendData:message withHeader:header];
}

@end
