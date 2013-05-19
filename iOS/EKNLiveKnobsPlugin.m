//
//  EKNLiveKnobsPlugin.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLiveKnobsPlugin.h"

#import "EKNDevicePluginContext.h"
#import "EKNKnobListenerInfo.h"
#import "EKNLiveKnobs.h"
#import "EKNPropertyDescription.h"


@interface EKNLiveKnobsPlugin () <EKNListenerInfoDelegate>

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) NSMapTable* listeners;
@property (strong, nonatomic) NSMapTable* listenersByID;

@end

@implementation EKNLiveKnobsPlugin

+ (EKNLiveKnobsPlugin*)sharedPlugin {
    static dispatch_once_t onceToken;
    static EKNLiveKnobsPlugin* plugin = nil;
    dispatch_once(&onceToken, ^{
        plugin = [[EKNLiveKnobsPlugin alloc] init];
    });
    return plugin;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.listeners = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsObjectPersonality capacity:0];
        self.listenersByID = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    }
    return self;
}

- (NSString*)name {
    return @"com.knobs.live-knobs";
}

- (void)useContext:(id<EKNDevicePluginContext>)context {
    self.context = context;
    self.channel = [context channelWithName:@"Knobs" fromPlugin:self];
}

- (void)beganConnection {
    // TODO. Send all existing knobs
}

- (void)endedConnection {
}

- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description currentValue:(id)value callback:(void(^)(id value, id owner))callback {
    NSMutableDictionary* infos = [self.listeners objectForKey:owner];
    if(infos == nil) {
        infos = [NSMutableDictionary dictionary];
        [self.listeners setObject:infos forKey:owner];
    }
    
    EKNKnobListenerInfo* listenerInfo = [[EKNKnobListenerInfo alloc] init];
    listenerInfo.uuid = [[NSUUID UUID] UUIDString];
    listenerInfo.owner = owner;
    listenerInfo.callback = callback;
    listenerInfo.propertyDescription = description;
    listenerInfo.delegate = self;
    [self.listenersByID setObject:listenerInfo forKey:listenerInfo.uuid];
    
    [infos setObject:listenerInfo forKey:listenerInfo.propertyDescription.name];
    NSDictionary* message = @{
      EKNLiveKnobsSentMessageKey : @(EKNLiveKnobsMessageAddKnob),
      @(EKNLiveKnobsAddIDKey) : listenerInfo.uuid,
      @(EKNLiveKnobsAddDescriptionKey) : description,
      @(EKNLiveKnobsAddInitialValueKey) : value,
      };

    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSNumber* messageType = [message objectForKey:EKNLiveKnobsSentMessageKey];
    if([messageType isEqualToNumber:@(EKNLiveKnobsMessageUpdateKnob)]) {
        NSString* uuid = [message objectForKey:@(EKNLiveKnobsUpdateIDKey)];
        id value = [message objectForKey:@(EKNLiveKnobsUpdateCurrentValueKey)];
        EKNKnobListenerInfo* listenerInfo = [self.listeners objectForKey:uuid];
        if(listenerInfo.callback != nil) {
            listenerInfo.callback(listenerInfo.owner, value);
        }
    }
    else {
        NSAssert(NO, @"Live Knobs: Unexpected message type: %@", messageType);
    }
}

- (void)updateValueWithOwner:(id)owner name:(NSString*)name value:(id)value {
    NSMutableDictionary* listeners = [self.listeners objectForKey:owner];
    EKNKnobListenerInfo* info = [listeners objectForKey:name];
    
    NSDictionary* message = @{
                              EKNLiveKnobsSentMessageKey : @(EKNLiveKnobsMessageUpdateKnob),
                              @(EKNLiveKnobsUpdateIDKey) : info.uuid,
                              @(EKNLiveKnobsUpdateCurrentValueKey) : value,
                              };
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
}

- (void)cancelCallbackWithOwner:(id)owner name:(NSString*)name {
    if(name == nil) {
        [self.listeners removeObjectForKey:owner];
    }
    else {
        NSMutableDictionary* listeners = [self.listeners objectForKey:owner];
        EKNKnobListenerInfo* info = [listeners objectForKey:name];
        [self listenerCancelled:info];

    }
}

- (void)listenerCancelled:(EKNKnobListenerInfo *)info {
    info.delegate = nil;
    NSDictionary* message = @{
                              EKNLiveKnobsSentMessageKey : @(EKNLiveKnobsMessageRemoveKnob),
                              @(EKNLiveKnobsRemoveIDKey) : info.uuid,
                              };
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
    
    
    [self.listenersByID removeObjectForKey:info.uuid];
    NSMutableDictionary* listeners = [self.listeners objectForKey:info.owner];
    [listeners removeObjectForKey:info.uuid];
}

@end
