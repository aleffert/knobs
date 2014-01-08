//
//  EKNLiveKnobsViewController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/19/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLiveKnobsViewController.h"

#import "EKNKnobGroupsView.h"
#import "EKNLiveKnobs.h"
#import "EKNPropertyDescription.h"
#import "EKNSourcedKnobTable.h"
#import "EKNKnobInfo.h"

@interface EKNLiveKnobsViewController () <EKNSourcedKnobTableDelegate>

@property (strong, nonatomic) IBOutlet EKNKnobGroupsView* knobEditor;

@property (strong, nonatomic) id <EKNChannel> channel;
@property (strong, nonatomic) id <EKNConsoleControllerContext> context;

@property (strong, nonatomic) NSMutableDictionary* groupViews;

@end

@implementation EKNLiveKnobsViewController

- (id)init {
    if(self = [super initWithNibName:@"EKNLiveKnobsViewController" bundle:[NSBundle bundleForClass:[self class]]]) {
        self.title = @"Knobs";
        self.groupViews = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.knobEditor.disclosureAutosaveName = @"EKNLiveKnobsDisclosureGroupsKey";
}

- (void)connectedToDeviceWithContext:(id<EKNConsoleControllerContext>)context onChannel:(id<EKNChannel>)channel {
    self.context = context;
    self.channel = channel;
    [self.groupViews removeAllObjects];
}

- (void)disconnectedFromDevice {
    [self.knobEditor clear];
    [self.groupViews removeAllObjects];
}

- (EKNSourcedKnobTable*)addGroupNamed:(NSString*)groupName {
    EKNSourcedKnobTable* table = [[EKNSourcedKnobTable alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) editorManager:self.context.editorManager sourceManager:self.context.sourceManager];
    table.delegate = self;
    [self.knobEditor addGroupNamed:groupName contentView:table];
    self.groupViews[groupName] = table;
    return table;
}

- (void)processAddKnobMessage:(NSDictionary*)message {
    NSString* uuid = message[@(EKNLiveKnobsAddIDKey)];
    id value = message[@(EKNLiveKnobsAddInitialValueKey)];
    EKNPropertyDescription* propertyDescription = [message objectForKey:@(EKNLiveKnobsAddDescriptionKey)];
    // References lazily since it's added by the app itself
    EKNKnobInfo* knob = [NSClassFromString(@"EKNKnobInfo") knob];
    knob.knobID = uuid;
    knob.value = value;
    knob.propertyDescription = propertyDescription;
    knob.sourcePath = message[@(EKNLiveKnobsPathKey)];
    knob.externalCode = message[@(EKNLiveKnobsExternalCodeKey)];
    knob.label = message[@(EKNLiveKnobsLabelKey)] ?: knob.propertyDescription.name;
    
    NSString* groupName = message[@(EKNLiveKnobsGroupKey)];
    EKNSourcedKnobTable* table = self.groupViews[groupName];
    if(!table) {
        table = [self addGroupNamed:groupName];
    }
    [table addKnob:knob];
}

- (void)processUpdateKnobMessage:(NSDictionary*)message {
    NSString* uuid = [message objectForKey:@(EKNLiveKnobsUpdateIDKey)];
    id value = [message objectForKey:@(EKNLiveKnobsUpdateCurrentValueKey)];
    for(EKNSourcedKnobTable* table in self.groupViews) {
        [table updateKnobWithID:uuid toValue:value];
    }
}

- (void)processRemoveKnobMessage:(NSDictionary*)message {
    NSString* knobID = [message objectForKey:@(EKNLiveKnobsRemoveIDKey)];
    for(EKNSourcedKnobTable* table in self.groupViews.allValues) {
        [table removeKnobWithID:knobID];
    }
    
    NSArray* keys = self.groupViews.allKeys;
    for(NSString* key in keys) {
        EKNSourcedKnobTable* table = self.groupViews[key];
        if(table.isEmpty) {
            [self.knobEditor removeGroupWithContentView:table];
            [self.groupViews removeObjectForKey:key];
        }
    }
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSUInteger messageType = [[message objectForKey:EKNLiveKnobsSentMessageKey] unsignedIntegerValue];
    switch (messageType) {
        case EKNLiveKnobsMessageAddKnob:
            [self processAddKnobMessage:message];
            break;
        case EKNLiveKnobsMessageUpdateKnob:
            [self processUpdateKnobMessage:message];
            break;
        case EKNLiveKnobsMessageRemoveKnob:
            [self processRemoveKnobMessage:message];
            break;
    }
}

- (void)knobTable:(EKNSourcedKnobTable *)table changedKnob:(EKNKnobInfo *)knob {
    NSString* uuid = knob.knobID;
    NSDictionary* message = @{EKNLiveKnobsSentMessageKey: @(EKNLiveKnobsMessageUpdateKnob),
                              @(EKNLiveKnobsUpdateCurrentValueKey) : knob.value,
                              @(EKNLiveKnobsUpdateIDKey) : uuid };
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
}

@end
