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

#import <objc/runtime.h>

@interface EKNLiveKnobsPlugin () <EKNListenerInfoDelegate>

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

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
        self.listenersByID = [NSMapTable strongToWeakObjectsMapTable];
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

static NSString* EKNObjectListenersKey = @"EKNObjectListenersKey";

- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description currentValue:(id)value callback:(void(^)(id owner, id value))callback {
    NSLog(@"listeners by id is %@", self.listenersByID);
    NSLog(@"listeners is %@", self.listenersByID);
    NSMutableDictionary* infos = objc_getAssociatedObject(owner, &EKNObjectListenersKey);
    if(infos == nil) {
        infos = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(owner, &EKNObjectListenersKey, infos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    EKNKnobListenerInfo* listenerInfo = [[EKNKnobListenerInfo alloc] init];
    listenerInfo.uuid = [[NSUUID UUID] UUIDString];
    NSLog(@"adding %@ with id %@", listenerInfo, listenerInfo.uuid);
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
