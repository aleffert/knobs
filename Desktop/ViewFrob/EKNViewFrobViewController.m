//
//  EKNViewFrobViewController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobViewController.h"

#import "EKNKnobGeneratorView.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"
#import "EKNPropertyInfo.h"

#import "EKNViewFrob.h"
#import "EKNViewFrobInfo.h"


#import "NSArray+EKNFunctional.h"

@interface EKNViewFrobViewController () <EKNKnobGeneratorViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (strong, nonatomic) id <EKNConsoleControllerContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) IBOutlet NSOutlineView* outline;
@property (strong, nonatomic) IBOutlet EKNKnobGeneratorView* knobEditor;

@property (strong, nonatomic) NSMutableDictionary* viewInfos;
@property (strong, nonatomic) NSString* rootID;

// This SUCKS. NSOutlineView uses pointer comparisons instead of isEqual:
// So canonicalize all of our ids.
@property (strong, nonatomic) NSMapTable* canonicalKeys;

@end

@implementation EKNViewFrobViewController

- (id)init {
    self = [super initWithNibName:@"EKNViewFrobViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if(self != nil) {
        self.viewInfos = [[NSMutableDictionary alloc] init];
        self.canonicalKeys = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory capacity:0];
    }
    return self;
}

- (NSString*)title {
    return @"Views";
}

- (void)loadView {
    [super loadView];
    [self.outline setColumnAutoresizingStyle:NSTableViewLastColumnOnlyAutoresizingStyle];
    [self.outline setAllowsMultipleSelection:NO];
}

- (void)connectedToDeviceWithContext:(id<EKNConsoleControllerContext>)context onChannel:(id<EKNChannel>)channel {
    self.channel = channel;
    self.context = context;
}

- (NSString*)canonicalize:(NSString*)key {
    NSString* existingCanon = [self.canonicalKeys objectForKey:key];
    if(existingCanon == nil) {
        if(key != nil) {
            [self.canonicalKeys setObject:key forKey:key];
        }
        return key;
    }
    
    return existingCanon;
}

- (void)showKnobsForInfo:(EKNViewFrobInfo*)info withProperties:(NSArray*)properties {
    NSArray* knobs = [properties map:^id(EKNPropertyInfo* info) {
        //Reference lazily since this is part of the app itself
        EKNKnobInfo* knob = [NSClassFromString(@"EKNKnobInfo") knob];
        knob.propertyDescription = info.propertyDescription;
        knob.value = info.value;
        knob.knobID = knob.propertyDescription.name;
        return knob;
    }];
    [self.knobEditor representObject:info.viewID withKnobs:knobs];
}
#pragma mark Message Processing

- (void)processBeginMessage:(NSDictionary*)message {
    NSData* responseData = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey: EKNViewFrobMessageLoadAll}];
    [self.context sendMessage:responseData onChannel:self.channel];
}

- (void)processUpdateAllMessage:(NSDictionary*)message {
    self.rootID = [message objectForKey:EKNViewFrobUpdateAllRootKey];
    [self.viewInfos removeAllObjects];
    NSArray* infos = [message objectForKey:EKNViewFrobUpdateAllInfosKey];
    
    for(EKNViewFrobInfo* info in infos) {
        [self.viewInfos setObject:info forKey:[self canonicalize:info.viewID]];
    }
    
    [self.outline reloadData];
}

- (void)processUpdatedViewMessage:(NSDictionary*)message {
    EKNViewFrobInfo* updatedViewInfo = [message objectForKey:EKNViewFrobUpdatedViewKey];
    EKNViewFrobInfo* oldViewInfo = [self.viewInfos objectForKey:updatedViewInfo.viewID];
    NSString* oldParentID = [self.viewInfos objectForKey:updatedViewInfo.parentID];
    EKNViewFrobInfo* oldParent = [self.viewInfos objectForKey:oldParentID];
    
    [self.viewInfos setObject:updatedViewInfo forKey:updatedViewInfo.viewID];
    
    oldParent.children = [oldParent.children filter:^BOOL(NSString* childID) {
        return ![childID isEqualToString:updatedViewInfo.viewID];
    }];
    
    BOOL childrenChanged = ![updatedViewInfo.children isEqualToArray:oldViewInfo.children];
    
    [self.outline reloadItem:[self canonicalize:updatedViewInfo.viewID] reloadChildren:childrenChanged];
    [self.outline reloadItem:[self canonicalize:oldParentID] reloadChildren:YES];
}

- (void)processRemovedViewMessage:(NSDictionary*)message {
    NSString* removedID = [self canonicalize:[message objectForKey:EKNViewFrobRemovedViewID]];
    EKNViewFrobInfo* removedInfo = [self.viewInfos objectForKey:removedID];
    EKNViewFrobInfo* parent = [self.viewInfos objectForKey:removedInfo.parentID];
    parent.children = [parent.children filter:^BOOL(NSString* childID) {
        return ![childID isEqualToString:removedID];
    }];
    [self.outline reloadItem:removedID reloadChildren:YES];
}

- (void)processUpdatedViewProperties:(NSDictionary*)message {
    NSString* updatedID = [message objectForKey:EKNViewFrobUpdatedViewID];
    NSArray* properties = [message objectForKey:EKNViewFrobUpdatedProperties];
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:updatedID];
    if([updatedID isEqual:[self selectedInfo].viewID]) {
        [self showKnobsForInfo:info withProperties:properties];
    }
}

- (void)processSelectViewMessage:(NSDictionary*)message {
    NSString* viewID = [message objectForKey:EKNViewFrobSelectedViewID];
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:viewID];
    [self selectInfo:info];
    NSString* item = [self canonicalize:viewID];
    
    NSMutableArray* items = [NSMutableArray array];
    
    for(; info != nil; info = [self.viewInfos objectForKey:info.parentID]) {
        [items addObject:info.viewID];
    }
    for(NSString* item in items.reverseObjectEnumerator) {
        [self.outline expandItem:item];
    }
    [self.outline selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.outline rowForItem:item]] byExtendingSelection:NO];
}

- (void)processMessage:(NSDictionary*)message {
    NSString* messageType = [message objectForKey:EKNViewFrobSentMessageKey];

    if([messageType isEqualToString:EKNViewFrobMessageBegin]) {
        [self processBeginMessage:message];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageUpdateAll]) {
        [self processUpdateAllMessage:message];
    }
    else if ([messageType isEqualToString:EKNViewFrobMessageUpdatedView]) {
        [self processUpdatedViewMessage:message];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageRemovedView]) {
        [self processRemovedViewMessage:message];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageUpdateProperties]) {
        [self processUpdatedViewProperties:message];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageBatch]) {
        NSArray* messages = [message objectForKey:EKNViewFrobBatchMessagesKey];
        for(NSDictionary* childMessage in messages) {
            [self processMessage:childMessage];
        }
    }
    else if([messageType isEqualToString:EKNViewFrobMessageSelect]) {
        [self processSelectViewMessage:message];
    }
    else {
        NSLog(@"unknown view frobber message type: %@", messageType);
    }
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self processMessage:message];
}

- (void)disconnectedFromDevice {
    [self.viewInfos removeAllObjects];
    self.rootID = nil;
    [self.canonicalKeys removeAllObjects];
    [self.outline reloadData];
    [self.knobEditor clear];
}

#pragma mark Outline View

- (void)selectInfo:(EKNViewFrobInfo*)info {
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageFocusView, EKNViewFrobFocusViewID : info.viewID}];
    [self.context sendMessage:archive onChannel:self.channel];
    [self showKnobsForInfo:info withProperties:[NSArray array]];
}

- (EKNViewFrobInfo*)selectedInfo {
    NSInteger selectedRow = [self.outline selectedRow];
    if(selectedRow == -1) {
        return nil;
    }
    else {
        return [self.viewInfos objectForKey:[self.outline itemAtRow:selectedRow]];
    }
}

- (NSArray*)childrenOfInfo:(EKNViewFrobInfo*)info {
    return [info.children map:^id(NSString* viewID) {
        return [self.viewInfos objectForKey:viewID];
    }];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(NSString*)itemID {
    if(itemID == nil) {
        return self.rootID == nil ? 0 : 1;
    }
    else {
        EKNViewFrobInfo* info = [self.viewInfos objectForKey:itemID];
        
        NSArray* children = [self childrenOfInfo:info];
        return children.count;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(NSString*)itemID {
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:itemID];
    return [self childrenOfInfo:info].count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(NSString*)itemID {
    if(itemID == nil) {
        return [self canonicalize:self.rootID];
    }
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:itemID];
    NSArray* children = [self childrenOfInfo:info];
    EKNViewFrobInfo* child = [children objectAtIndex:index];
    return [self canonicalize:child.viewID];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(NSString*)itemID {
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:itemID];
    NSTableCellView *view = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if([tableColumn.identifier isEqualToString:@"Class"]) {
        view.textField.stringValue = info.className;
    }
    else if([tableColumn.identifier isEqualToString:@"Address"]) {
        view.textField.stringValue = info.address;
    }
    else if([tableColumn.identifier isEqualToString:@"NextResponderClass"]) {
        view.textField.stringValue = info.nextResponderClassName;
    }
    else {
        NSAssert(NO, @"Unexpected table column %@", tableColumn.identifier);
        return nil;
    }
    return view;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    EKNViewFrobInfo* info = [self selectedInfo];
    [self.knobEditor representObject:nil withKnobs:@[]];
    if(info == nil) {
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageFocusView}];
        [self.context sendMessage:archive onChannel:self.channel];
    }
    else {
        [self selectInfo:info];
    }

}

- (IBAction)chooseFromDevice:(id)sender {
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageActivateTapSelection}];
    [self.context sendMessage:archive onChannel:self.channel];
}

#pragma Knob Editor

- (void)generatorView:(EKNKnobGeneratorView *)view changedKnob:(EKNKnobInfo *)knob {
    //Reference lazily since this is part of the app itself
    EKNPropertyInfo* info = [NSClassFromString(@"EKNPropertyInfo") infoWithDescription:knob.propertyDescription value:knob.value];
    NSDictionary* message = @{EKNViewFrobSentMessageKey: EKNViewFrobMessageChangedProperty, EKNViewFrobChangedPropertyInfo : info, EKNViewFrobChangedPropertyViewID : self.selectedInfo.viewID};
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
}

@end
