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
#import "EKNPropertyDescription+EKNWrapping.h"

#import <objc/runtime.h>

@interface EKNLiveKnobsPlugin () <EKNListenerInfoDelegate>

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) NSMapTable* listenersByID;
@property (strong, nonatomic) NSMapTable* valuesByID;

@property (strong, nonatomic) NSMutableArray* groupNameStack;

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
        self.groupNameStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString*)name {
    return @"com.knobs.live-knobs";
}

- (NSString*)defaultGroupName {
    return @"Global";
}

- (NSString*)currentGroupName {
    if(self.groupNameStack.count > 0) {
        return [self.groupNameStack objectAtIndex:0];
    }
    else {
        return self.defaultGroupName;
    }
}

- (void)useContext:(id<EKNDevicePluginContext>)context {
    self.context = context;
    self.channel = [context channelWithName:@"Knobs" fromPlugin:self];
}

- (void)beganConnection {
    for(EKNKnobListenerInfo* info in self.listenersByID.objectEnumerator) {
        id value = [self.valuesByID objectForKey:info.uuid];
        [self sendAddMessageWithInfo:info value:value];
    }
}

- (void)endedConnection {
}

- (void)beginGroupWithName:(NSString *)groupName {
    if(groupName == nil) {
        NSLog(@"Knobs: Can't have a nil groupName. Ignoring");
    }
    else {
        [self.groupNameStack addObject:groupName];
    }
}

- (void)endGroup {
    if(self.groupNameStack.count == 0) {
        NSLog(@"Knobs: Can't have a nil groupName");
    }
    else {
        [self.groupNameStack removeLastObject];
    }
}

- (void)groupWithName:(NSString *)groupName action:(void (^)(void))action {
    [self beginGroupWithName:groupName];
    action();
    [self endGroup];
}

- (void)sendAddMessageWithInfo:(EKNKnobListenerInfo*)info value:(id)value {
    NSMutableDictionary* message = @{
                                     EKNLiveKnobsSentMessageKey : @(EKNLiveKnobsMessageAddKnob),
                                     @(EKNLiveKnobsAddIDKey) : info.uuid,
                                     @(EKNLiveKnobsGroupKey) : info.groupName,
                                     @(EKNLiveKnobsAddDescriptionKey) : info.propertyDescription,
                                     }.mutableCopy;
    if(value) {
        message[@(EKNLiveKnobsAddInitialValueKey)] = [info.propertyDescription wrappedValueFromSource:value];
    }
    if(info.externalCode) {
        message[@(EKNLiveKnobsExternalCodeKey)] = info.externalCode;
    }
    if(info.label) {
        message[@(EKNLiveKnobsLabelKey)] = info.label;
    }
    else {
        message[@(EKNLiveKnobsLabelKey)] = info.propertyDescription.name;
    }
    if(info.sourcePath) {
        message[@(EKNLiveKnobsPathKey)] = info.sourcePath;
    }
    
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
    
}

static NSString* EKNObjectListenersKey = @"EKNObjectListenersKey";

- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description label:(NSString *)label currentValue:(id)value externalCode:(NSString*)externalCode sourcePath:(NSString *)path callback:(void (^)(id, id))callback {
    NSAssert([NSThread isMainThread], @"Must be called from main thread");
    NSAssert(owner != nil, @"Cannot register knob with nil owner");
    NSMutableDictionary* infos = objc_getAssociatedObject(owner, &EKNObjectListenersKey);
    if(infos == nil) {
        infos = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(owner, &EKNObjectListenersKey, infos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    EKNKnobListenerInfo* listenerInfo = [[EKNKnobListenerInfo alloc] init];
    listenerInfo.uuid = [EKNUUID UUIDString];
    listenerInfo.owner = owner;
    listenerInfo.callback = callback;
    listenerInfo.externalCode = externalCode;
    listenerInfo.propertyDescription = description;
    listenerInfo.delegate = self;
    listenerInfo.sourcePath = path;
    listenerInfo.label = label;
    listenerInfo.groupName = self.currentGroupName;
    [self.listenersByID setObject:listenerInfo forKey:listenerInfo.uuid];
    
    [infos setObject:listenerInfo forKey:listenerInfo.propertyDescription.name];
    if([self.context isConnected]) {
        [self sendAddMessageWithInfo:listenerInfo value:value];
    }
    [self.valuesByID setObject:value forKey:listenerInfo.uuid];
}

- (void)registerOwner:(id)owner info:(EKNPropertyDescription *)description label:(NSString *)label currentValue:(id)value callback:(void (^)(id, id))callback {
    [self registerOwner:owner info:description label:label currentValue:value externalCode:nil sourcePath:nil callback:callback];
}

- (void)registerPushButtonWithOwner:(id)owner name:(NSString*)name callback:(void(^)(id owner))callback {
    [self registerOwner:owner info:[EKNPropertyDescription pushButtonPropertyWithName:name] label:name currentValue:@(0) callback:^(id owner, id value) {
        if(callback != nil) {
            callback(owner);
        }
    }];
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSAssert([NSThread isMainThread], @"Must be called from main thread");
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSNumber* messageType = [message objectForKey:EKNLiveKnobsSentMessageKey];
    if([messageType isEqualToNumber:@(EKNLiveKnobsMessageUpdateKnob)]) {
        NSString* uuid = [message objectForKey:@(EKNLiveKnobsUpdateIDKey)];
        id value = [message objectForKey:@(EKNLiveKnobsUpdateCurrentValueKey)];
        EKNKnobListenerInfo* listenerInfo = [self.listenersByID  objectForKey:uuid];
        if(listenerInfo.callback != nil) {
            listenerInfo.callback(listenerInfo.owner, [listenerInfo.propertyDescription valueWithWrappedValue: value]);
        }
    }
    else {
        NSAssert(NO, @"Live Knobs: Unexpected message type: %@", messageType);
    }
}

- (void)updateValueWithOwner:(id)owner name:(NSString*)name value:(id)value {
    NSAssert([NSThread isMainThread], @"Must be called from main thread");
    NSAssert(owner != nil, @"Attempting to update knob with nil owner");
    NSMutableDictionary* listeners = objc_getAssociatedObject(owner, &EKNObjectListenersKey);
    EKNKnobListenerInfo* info = [listeners objectForKey:name];
    
    NSDictionary* message = @{
                              EKNLiveKnobsSentMessageKey : @(EKNLiveKnobsMessageUpdateKnob),
                              @(EKNLiveKnobsUpdateIDKey) : info.uuid,
                              @(EKNLiveKnobsUpdateCurrentValueKey) : [info.propertyDescription wrappedValueFromSource:value],
                              };
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
    
    [self.valuesByID setObject:value forKey:info.uuid];
}

- (void)removeKnobWithOwner:(id)owner name:(NSString*)name {
    NSAssert([NSThread isMainThread], @"Must be called from main thread");
    NSAssert(owner != nil, @"Attempting to remove knob with nil owner");
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
    NSAssert([NSThread isMainThread], @"Must be called from main thread");
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

NSString* EKNDescriptionFromSymbol(NSString* symbol) {
    // TODO break apart camel casing, remove self. and capitalize, do clever things with underscore
    return symbol;
}

#pragma mark Default Callback Actions

@implementation UIViewController (EKNLiveKnobsCallback)

- (void)ekn_knobChangedNamed:(NSString *)label withDescription:(EKNPropertyDescription *)description toValue:(id)value {
    [self.view setNeedsLayout];
}

@end


@implementation UIView (EKNLiveKnobsCallback)

- (void)ekn_knobChangedNamed:(NSString *)label withDescription:(EKNPropertyDescription *)description toValue:(id)value {
    [self setNeedsLayout];
    for(UIResponder* responder = self; responder != nil; responder = responder.nextResponder) {
        UIViewController* controller = [responder isKindOfClass:[UIViewController class]] ? (UIViewController*)responder : nil;
        if(controller && controller.isViewLoaded) {
            [controller.view setNeedsLayout];
            break;
        }
    }
}

@end