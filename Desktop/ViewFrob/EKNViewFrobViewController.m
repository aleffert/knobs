//
//  EKNViewFrobViewController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobViewController.h"

#import "EKNKnobGeneratorView.h"
#import "EKNKnobGroupsView.h"
#import "EKNKnobEditorManager.h"
#import "EKNKnobInfo.h"
#import "EKNNamedGroup.h"
#import "EKNPropertyDescription.h"
#import "EKNPropertyInfo.h"
#import "EKNViewFrob.h"
#import "EKNViewFrobInfo.h"

#import "NSArray+EKNFunctional.h"

typedef NS_ENUM(NSUInteger, EKNViewFrobSelectButtonState) {
    EKNViewFrobSelectButtonStateSelect,
    EKNViewFrobSelectButtonStateCancel
};

static NSString* EKNViewFrobShowMarginsKey = @"EKNViewFrobShowMarginsKey";

@interface EKNViewFrobViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate, EKNKnobGeneratorViewDelegate>

@property (strong, nonatomic) id <EKNConsoleControllerContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) IBOutlet NSButton* showMarginsButton;
@property (strong, nonatomic) IBOutlet NSButton* selectFromDeviceButton;
@property (strong, nonatomic) IBOutlet NSOutlineView* outline;
@property (strong, nonatomic) IBOutlet EKNKnobGroupsView* knobEditor;

@property (strong, nonatomic) NSMutableDictionary* viewInfos;
@property (strong, nonatomic) NSArray* roots;

/// group views in order
@property (strong, nonatomic) NSMutableArray* groupViews;

/// map from group name to group view
@property (strong, nonatomic) NSMutableDictionary* groupNameMap;

// This STINKS. NSOutlineView uses pointer comparisons instead of isEqual:
// So canonicalize all of our ids.
@property (strong, nonatomic) NSMapTable* canonicalKeys;

- (IBAction)chooseFromDevice:(id)sender;
- (IBAction)toggleShowMargins:(NSButton*)sender;

@end

@implementation EKNViewFrobViewController

- (id)init {
    self = [super initWithNibName:@"EKNViewFrobViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if(self != nil) {
        self.viewInfos = [[NSMutableDictionary alloc] init];
        self.canonicalKeys = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory capacity:0];
        
        self.groupNameMap = [[NSMutableDictionary alloc] init];
        self.groupViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString*)title {
    return @"Views";
}

- (void)loadView {
    [super loadView];
    [self.outline setColumnAutoresizingStyle:NSTableViewFirstColumnOnlyAutoresizingStyle];
    [self.outline setAllowsMultipleSelection:NO];
    
    self.showMarginsButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:EKNViewFrobShowMarginsKey];
    
    self.knobEditor.disclosureAutosaveName = @"EKNViewFrobDisclosureGroupsKey";
}

- (void)setSelectButtonState:(EKNViewFrobSelectButtonState)state {
    switch(state) {
        case EKNViewFrobSelectButtonStateSelect:
            [self.selectFromDeviceButton setTitle:@"Select From Device"];
            break;
        case EKNViewFrobSelectButtonStateCancel:
            [self.selectFromDeviceButton setTitle:@"Cancel"];
            break;
    }
    self.selectFromDeviceButton.tag = state;
}

- (void)connectedToDeviceWithContext:(id<EKNConsoleControllerContext>)context onChannel:(id<EKNChannel>)channel {
    self.channel = channel;
    self.context = context;
    
    [self.selectFromDeviceButton setEnabled:YES];
    [self.showMarginsButton setEnabled:YES];
    [self setSelectButtonState:EKNViewFrobSelectButtonStateSelect];
    [self sendMarginsState:self.showMarginsButton.state];
}

- (void)disconnectedFromDevice {
    [self setSelectButtonState:EKNViewFrobSelectButtonStateSelect];
    [self.selectFromDeviceButton setEnabled:NO];
    [self.showMarginsButton setEnabled:NO];
    
    [self.viewInfos removeAllObjects];
    self.roots = [NSArray array];
    [self.canonicalKeys removeAllObjects];
    [self.outline reloadData];
    [self.knobEditor clear];
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

- (void)showKnobsForInfo:(EKNViewFrobInfo*)info withGroups:(NSArray*)groups {
    NSArray* knobGroups = [groups map:^id(EKNNamedGroup* group) {
        EKNNamedGroup* knobGroup = [[NSClassFromString(@"EKNNamedGroup") alloc] init];
        knobGroup.name = group.name;
        knobGroup.items = [group.items map:^id(EKNPropertyInfo* info) {
            // Reference lazily since this is part of the app itself
            EKNKnobInfo* knob = [NSClassFromString(@"EKNKnobInfo") knob];
            knob.propertyDescription = info.propertyDescription;
            knob.value = info.value;
            knob.knobID = knob.propertyDescription.name;
            knob.label = knob.propertyDescription.name;
            return knob;
        }];
        return knobGroup;
    }];
    [self representObject:info.viewID withGroups:knobGroups];
}

#pragma mark Update Groups


- (void)representObject:(id)object withGroups:(NSArray *)groups {
    BOOL fullUpdate = ![self.representedObject isEqual: object] || groups.count != self.groupViews.count;
    
    if (fullUpdate) {
        [self.knobEditor clear];
        [self.groupViews removeAllObjects];
        [self.groupNameMap removeAllObjects];
        
        self.representedObject = object;
        
        [groups enumerateObjectsUsingBlock:^(EKNNamedGroup* group, NSUInteger index, BOOL *stop) {
            NSView* knobView = [self makeContentViewWithInfos:group.items representingObject:object];
            [self.knobEditor addGroupNamed:group.name contentView:knobView];
            self.groupNameMap[group.name] = knobView;
            [self.groupViews addObject:knobView];
        }];
    }
    else {
        for(EKNNamedGroup* group in groups) {
            EKNKnobGeneratorView* knobView = self.groupNameMap[group.name];
            [knobView representObject:object withKnobs:group.items];
        }
    }
}

- (NSView*)makeContentViewWithInfos:(NSArray*)knobs representingObject:(id)object {
    EKNKnobGeneratorView* knobView = [[EKNKnobGeneratorView alloc] initWithFrame:CGRectMake(0, 0, self.knobEditor.frame.size.width, 100) editorManager:self.context.editorManager];
    knobView.delegate = self;
    [knobView representObject:object withKnobs:knobs];
    return knobView;
}

#pragma mark Actions

- (IBAction)chooseFromDevice:(id)sender {
    if(self.selectFromDeviceButton.tag == EKNViewFrobSelectButtonStateSelect) {
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageActivateTapSelection}];
        [self.context sendMessage:archive onChannel:self.channel];
        [self setSelectButtonState:EKNViewFrobSelectButtonStateCancel];
    }
    else if(self.selectFromDeviceButton.tag == EKNViewFrobSelectButtonStateCancel) {
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageActivateTapSelectionCancel}];
        [self.context sendMessage:archive onChannel:self.channel];
        [self setSelectButtonState:EKNViewFrobSelectButtonStateSelect];
    }
}

- (void)sendMarginsState:(BOOL)state {
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:
                       @{
                         EKNViewFrobSentMessageKey : EKNViewFrobMessageSetShowViewMargins,
                         EKNViewFrobSetShowViewMarginsState : @(state)
                         }];
    [self.context sendMessage:archive onChannel:self.channel];
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:EKNViewFrobShowMarginsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)toggleShowMargins:(NSButton*)sender {
    [self sendMarginsState:sender.state];
}


#pragma mark Message Processing

- (void)processBeginMessage:(NSDictionary*)message {
    NSData* responseData = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey: EKNViewFrobMessageLoadAll}];
    [self.context sendMessage:responseData onChannel:self.channel];
}

- (void)processUpdateAllMessage:(NSDictionary*)message {
    self.roots = [message objectForKey:EKNViewFrobUpdateAllRootsKey];
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
    if(oldParentID != nil) {
        [self.outline reloadItem:[self canonicalize:oldParentID] reloadChildren:YES];
    }
}

- (void)processRemovedViewMessage:(NSDictionary*)message {
    NSString* removedID = [self canonicalize:[message objectForKey:EKNViewFrobRemovedViewID]];
    EKNViewFrobInfo* removedInfo = [self.viewInfos objectForKey:removedID];
    EKNViewFrobInfo* parent = [self.viewInfos objectForKey:removedInfo.parentID];
    parent.children = [parent.children filter:^BOOL(NSString* childID) {
        return ![childID isEqualToString:removedID];
    }];
    if(parent.viewID != nil) {
        NSInteger selectedIndex = [self.outline selectedRow];
        id selectedItem = [self.outline itemAtRow:selectedIndex];
        [self.outline reloadItem:[self canonicalize:parent.viewID] reloadChildren:YES];
        NSInteger index = [self.outline rowForItem:selectedItem];
        [self.outline selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [self.outline scrollRowToVisible:index];
    }
}

- (void)processUpdatedViewProperties:(NSDictionary*)message {
    NSString* updatedID = [message objectForKey:EKNViewFrobUpdatedViewID];
    NSArray* groups = [message objectForKey:EKNViewFrobUpdatedGroups];
    
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:updatedID];
    if([updatedID isEqual:[self selectedInfo].viewID]) {
        [self showKnobsForInfo:info withGroups:groups];
    }
}

- (void)processSelectViewMessage:(NSDictionary*)message {
    [self setSelectButtonState:EKNViewFrobSelectButtonStateSelect];
    NSString* viewID = [message objectForKey:EKNViewFrobSelectedViewID];
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:viewID];
    [self selectInfoOnDevice:info];
    NSString* item = [self canonicalize:viewID];
    
    NSMutableArray* items = [NSMutableArray array];
    
    for(; info != nil; info = [self.viewInfos objectForKey:info.parentID]) {
        [items addObject:[self canonicalize:info.viewID]];
    }
    for(NSString* item in items.reverseObjectEnumerator) {
        if(![item isEqualToString:viewID]) {
            [self.outline expandItem:item];
        }
        [self.outline reloadItem:item reloadChildren:YES];
    }
    NSInteger index = [self.outline rowForItem:item];
    [self.outline selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [self.outline scrollRowToVisible:index];
}

- (void)processRootsChangedMessage:(NSDictionary*)message {
    self.roots = [message objectForKey:EKNViewFrobChangedRoots];
    EKNViewFrobInfo* info = [self selectedInfo];
    [self.outline reloadItem:nil reloadChildren:YES];
    [self selectItemInOutlineView:info];
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
    else if([messageType isEqualToString:EKNViewFrobMessageSelect]) {
        [self processSelectViewMessage:message];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageChangedRoots]) {
        [self processRootsChangedMessage:message];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageBatch]) {
        NSArray* messages = [message objectForKey:EKNViewFrobBatchMessagesKey];
        for(NSDictionary* childMessage in messages) {
            [self processMessage:childMessage];
        }
    }
    else {
        NSLog(@"unknown view frobber message type: %@", messageType);
    }
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self processMessage:message];
}

#pragma mark Outline View

- (void)selectItemInOutlineView:(EKNViewFrobInfo*)info {
    NSInteger index = [self.outline rowForItem:[self canonicalize:info.viewID]];
    [self.outline selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
}

- (void)selectInfoOnDevice:(EKNViewFrobInfo*)info {
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageFocusView, EKNViewFrobFocusViewID : info.viewID}];
    [self.context sendMessage:archive onChannel:self.channel];
    [self showKnobsForInfo:info withGroups:@[]];
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
        return self.roots.count;
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
        return [self canonicalize:self.roots[index]];
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
        view.textField.stringValue = [NSString stringWithFormat:@"<%@>: %@", info.address, info.className];
    }
    else {
        view.textField.stringValue = [NSString stringWithFormat:@"%@", info.nextResponderClassName];
    }
    return view;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    EKNViewFrobInfo* info = [self selectedInfo];
    [self representObject:nil withGroups:@[]];
    if(info == nil) {
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey : EKNViewFrobMessageFocusView}];
        [self.context sendMessage:archive onChannel:self.channel];
    }
    else {
        [self selectInfoOnDevice:info];
    }

}

#pragma Knob Editor

- (void)generatorView:(EKNKnobGeneratorView *)view changedKnob:(EKNKnobInfo *)knob {
    if(self.selectedInfo != nil) {
        //Reference lazily since this is part of the app itself
        EKNPropertyInfo* info = [NSClassFromString(@"EKNPropertyInfo") infoWithDescription:knob.propertyDescription value:knob.value];
        NSDictionary* message = @{EKNViewFrobSentMessageKey: EKNViewFrobMessageChangedProperty, EKNViewFrobChangedPropertyInfo : info, EKNViewFrobChangedPropertyViewID : self.selectedInfo.viewID};
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
        [self.context sendMessage:archive onChannel:self.channel];
    }
}

@end
