//
//  EKNLiveKnobsPlugin.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLiveKnobsPlugin.h"

#import "EKNDevicePluginContext.h"
#import "EKNUUID.h"
#import "EKNKnobListenerInfo.h"
#import "EKNLiveKnobs.h"
#import "EKNPropertyDescription.h"

#import <objc/runtime.h>

@interface EKNLiveKnobsPlugin () <EKNListenerInfoDelegate>

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) NSMapTable* listenersByID;
@property (strong, nonatomic) NSMapTable* valuesByID;

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
        self.listenersByID = [NSMapTable strongToWeakObjectsMapTable];
        self.valuesByID = [NSMapTable strongToStrongObjectsMapTable];
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
    for(EKNKnobListenerInfo* info in self.listenersByID.objectEnumerator) {
        id value = [self.valuesByID objectForKey:info.uuid];
        if(value != nil) {
            [self sendAddMessageWithInfo:info value:value];
        }
    }
}

- (void)endedConnection {
}

- (void)sendAddMessageWithInfo:(EKNKnobListenerInfo*)info value:(id)value {
    NSDictionary* message = @{
                              EKNLiveKnobsSentMessageKey : @(EKNLiveKnobsMessageAddKnob),
                              @(EKNLiveKnobsAddIDKey) : info.uuid,
                              @(EKNLiveKnobsAddDescriptionKey) : info.propertyDescription,
                              @(EKNLiveKnobsAddInitialValueKey) : value,
                              };
    
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];

}

static NSString* EKNObjectListenersKey = @"EKNObjectListenersKey";

- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description currentValue:(id)value callback:(void(^)(id owner, id value))callback {
    NSMutableDictionary* infos = objc_getAssociatedObject(owner, &EKNObjectListenersKey);
    if(infos == nil) {
        infos = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(owner, &EKNObjectListenersKey, infos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    EKNKnobListenerInfo* listenerInfo = [[EKNKnobListenerInfo alloc] init];
    listenerInfo.uuid = [EKNUUID UUIDString];
    listenerInfo.owner = owner;
    listenerInfo.callback = callback;
    listenerInfo.propertyDescription = description;
    listenerInfo.delegate = self;
    [self.listenersByID setObject:listenerInfo forKey:listenerInfo.uuid];
    
    [infos setObject:listenerInfo forKey:listenerInfo.propertyDescription.name];
    if([self.context isConnected]) {
        [self sendAddMessageWithInfo:listenerInfo value:value];
    }
    [self.valuesByID setObject:value forKey:listenerInfo.uuid];
}

- (void)registerPushButtonWithOwner:(id)owner name:(NSString*)name callback:(void(^)(id owner))callback {
    [self registerOwner:owner info:[EKNPropertyDescription pushButtonPropertyWithName:name] currentValue:@(0) callback:^(id owner, id value) {
        callback(owner);
    }];
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSNumber* messageType = [message objectForKey:EKNLiveKnobsSentMessageKey];
    if([messageType isEqualToNumber:@(EKNLiveKnobsMessageUpdateKnob)]) {
        NSString* uuid = [message objectForKey:@(EKNLiveKnobsUpdateIDKey)];
        id value = [message objectForKey:@(EKNLiveKnobsUpdateCurrentValueKey)];
        EKNKnobListenerInfo* listenerInfo = [self.listenersByID  objectForKey:uuid];
        if(listenerInfo.callback != nil) {
            listenerInfo.callback(listenerInfo.owner, value);
        }
    }
    else {
        NSAssert(NO, @"Live Knobs: Unexpected message type: %@", messageType);
    }
}

- (void)updateValueWithOwner:(id)owner name:(NSString*)name value:(id)value {
    NSMutableDictionary* listeners = objc_getAssociatedObject(owner, &EKNObjectListenersKey);
    EKNKnobListenerInfo* info = [listeners objectForKey:name];
    
    NSDictionary* message = @{
                              EKNLiveKnobsSentMessageKey : @(EKNLiveKnobsMessageUpdateKnob),
                              @(EKNLiveKnobsUpdateIDKey) : info.uuid,
                              @(EKNLiveKnobsUpdateCurrentValueKey) : value,
                              };
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
    
    [self.valuesByID setObject:value forKey:info.uuid];
}

- (void)cancelCallbackWithOwner:(id)owner name:(NSString*)name {
    if(name == nil) {
        objc_setAssociatedObject(owner, &EKNObjectListenersKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        NSMutableDictionary* listeners = objc_getAssociatedObject(owner, &EKNObjectListenersKey);
        EKNKnobListenerInfo* info = [listeners objectForKey:name];
        [self listenerCancelled:info];
    }
}

- (void)listenerCancelled:(EKNKnobListenerInfo *)info {
    info.delegate = nil;
    [self.valuesByID removeObjectForKey:info.uuid];
    NSDictionary* message = @{
                              EKNLiveKnobsSentMessageKey : @(EKNLiveKnobsMessageRemoveKnob),
                              @(EKNLiveKnobsRemoveIDKey) : info.uuid,
                              };
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
    
    NSMutableDictionary* listeners = objc_getAssociatedObject(info.owner, &EKNObjectListenersKey);
    [listeners removeObjectForKey:info.uuid];
}

@end
