//
//  EKNViewFrobViewController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobViewController.h"

#import "EKNViewFrob.h"
#import "EKNViewFrobInfo.h"

#import "NSArray+EKNFunctional.h"

@interface EKNViewFrobViewController ()

@property (strong, nonatomic) id <EKNConsoleControllerContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@property (strong, nonatomic) IBOutlet NSOutlineView* outline;

@property (strong, nonatomic) NSMutableDictionary* viewInfos;
@property (strong, nonatomic) EKNViewFrobInfo* root;

// This SUCKS. NSOutlineView uses pointer comparisons instead of isEqual:
// So canonicalize all of our ids.
// We leak these, but it's just a bunch of small strings so it should be okay :(((
@property (strong, nonatomic) NSMutableDictionary* canonicalKeys;

@end

@implementation EKNViewFrobViewController

- (id)init {
    self = [super initWithNibName:@"EKNViewFrobViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if(self != nil) {
        self.viewInfos = [[NSMutableDictionary alloc] init];
        self.canonicalKeys = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString*)title {
    return @"Views";
}

- (void)loadView {
    [super loadView];
    [self.outline setColumnAutoresizingStyle:NSTableViewLastColumnOnlyAutoresizingStyle];
}

- (void)connectedToDeviceWithContext:(id<EKNConsoleControllerContext>)context onChannel:(id<EKNChannel>)channel {
    self.channel = channel;
    self.context = context;
}

- (void)removeTreeAnchoredAt:(EKNViewFrobInfo*)info {
    [self recurseThroughTree:info withAction:^(EKNViewFrobInfo* info) {
        [self.viewInfos removeObjectForKey:info];
    }];
}

- (void)addTreeAnchoredAt:(EKNViewFrobInfo*)info {
    [self recurseThroughTree:info withAction:^(EKNViewFrobInfo* info) {
        [self.viewInfos setObject:info forKey:info.viewID];
    }];
}

- (void)recurseThroughTree:(EKNViewFrobInfo*)info withAction:(void(^)(EKNViewFrobInfo* info))action {
    action(info);
    for(EKNViewFrobInfo* child in info.children) {
        [self recurseThroughTree:child withAction:action];
    }
}

- (NSString*)canonicalize:(NSString*)key {
    NSString* existingCanon = [self.canonicalKeys objectForKey:key];
    if(existingCanon == nil) {
        [self.canonicalKeys setObject:key forKey:key];
        return key;
    }
    
    return existingCanon;
}

- (void)processMessage:(NSDictionary*)message {
    NSString* messageType = [message objectForKey:EKNViewFrobSentMessageKey];
    // TODO. Dispatch this in a more sane manor
    if([messageType isEqualToString:EKNViewFrobMessageBegin]) {
        NSData* responseData = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey: EKNViewFrobMessageLoadAll}];
        [self.context sendMessage:responseData onChannel:self.channel];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageUpdateAll]) {
        self.root = [message objectForKey:EKNViewFrobUpdateAllRootKey];
        [self.viewInfos removeAllObjects];
        [self addTreeAnchoredAt:self.root];
        [self.outline reloadData];
    }
    else if ([messageType isEqualToString:EKNViewFrobMessageUpdatedView]) {
        EKNViewFrobInfo* updatedInfo = [message objectForKey:EKNViewFrobUpdatedViewSuperviewKey];
        
        EKNViewFrobInfo* oldInfo = [self.viewInfos objectForKey:updatedInfo.viewID];
        if(oldInfo != nil) {
            [self removeTreeAnchoredAt:oldInfo];
        }
        if(updatedInfo.parentID.length > 0 || [updatedInfo.viewID isEqualToString:self.root.viewID]) {
            EKNViewFrobInfo* parent = [self.viewInfos objectForKey:updatedInfo.parentID];
            NSUInteger index = [parent.children indexOfObjectPassingTest:^BOOL(EKNViewFrobInfo* child, NSUInteger idx, BOOL *stop) {
                return [child.viewID isEqualToString:updatedInfo.viewID];
            }];
            if(index != NSNotFound) {
                parent.children = [parent.children arrayByReplacingObjectAtIndex:index withObject:updatedInfo];
            }
            [self addTreeAnchoredAt:updatedInfo];
            [self.outline reloadItem:[self canonicalize: updatedInfo.viewID] reloadChildren:YES];
        }
    }
    else if([messageType isEqualToString:EKNViewFrobMessageRemovedView]) {
        NSString* removedID = [message objectForKey:EKNViewFrobRemovedViewID];
        EKNViewFrobInfo* info = [self.viewInfos objectForKey:removedID];
        if(info != nil) {
            [self removeTreeAnchoredAt:info];
            EKNViewFrobInfo* parent = [self.viewInfos objectForKey:info.parentID];
            parent.children = [parent.children filter:^BOOL(EKNViewFrobInfo* child) {
                return ![child.viewID isEqualToString:removedID];
            }];
            [self.outline reloadItem:[self canonicalize:parent.viewID] reloadChildren:YES];
        }
    }
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self processMessage:message];
}

- (void)disconnectedFromDevice {
}

#pragma mark Outline View

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(NSString*)itemID {
    if(itemID == nil) {
        return self.root == nil ? 0 : 1;
    }
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:itemID];
    return info.children.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(NSString*)itemID {
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:itemID];
    return info.children.count > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(NSString*)itemID {
    if(itemID == nil) {
        return [self canonicalize:self.root.viewID];
    }
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:itemID];
    EKNViewFrobInfo* child = [info.children objectAtIndex:index];
    return [self canonicalize:child.viewID];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(NSString*)itemID {
    EKNViewFrobInfo* info = [self.viewInfos objectForKey:itemID];
    NSTableCellView *view = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if([tableColumn.identifier isEqualToString:@"Class"]) {
        view.textField.stringValue = info.className;
    }
    else if([tableColumn.identifier isEqualToString:@"Address"]) {
        view.textField.stringValue = info.viewID;
    }
    else {
        NSAssert(NO, @"Unexpected table column %@", tableColumn.identifier);
        return nil;
    }
    return view;
}


@end
