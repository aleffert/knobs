//
//  EKNSourcedKnobTable.m
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNSourcedKnobTable.h"

#import "EKNKnobEditorManager.h"
#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"
#import "EKNPropertyEditor.h"
#import "EKNSourceManager.h"
#import "EKNUpdateSourceCellView.h"
#import "NSArray+EKNFunctional.h"

static NSString* const EKNSourceTableKnobType = @"EKNSourceTableKnobType";

@interface EKNSourcedKnobTable () <NSOutlineViewDataSource, NSOutlineViewDelegate, EKNPropertyEditorDelegate, EKNUpdateSourceCellViewDelegate>

@property (strong, nonatomic) IBOutlet NSOutlineView* knobTable;
@property (strong, nonatomic) NSMutableArray* knobs;
@property (strong, nonatomic) NSMapTable* externalCodeMap;

@property (strong, nonatomic) EKNKnobEditorManager* editorManager;
@property (strong, nonatomic) EKNSourceManager* sourceManager;

@end

@implementation EKNSourcedKnobTable

- (id)initWithFrame:(NSRect)frameRect editorManager:(EKNKnobEditorManager*)editorManager sourceManager:(EKNSourceManager*)sourceManager {
    self = [super initWithFrame:frameRect];
    if(self != nil) {
        self.editorManager = editorManager;
        self.sourceManager = sourceManager;
        [[NSBundle mainBundle] loadNibNamed:@"EKNSourcedKnobTable" owner:self topLevelObjects:NULL];
        
        self.knobs = [[NSMutableArray alloc] init];
        
        [self addSubview:self.knobTable];
        
        [self.knobTable registerForDraggedTypes:@[EKNSourceTableKnobType]];
        
        self.knobTable.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_knobTable]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_knobTable]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        
        [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
        
        [self.editorManager registerPropertyTypesInTableView:self.knobTable];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNUpdateSourceCellView" bundle:Nil] forIdentifier:@"EKNUpdateSourceCellIdentifier"];
        
        self.externalCodeMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isEmpty {
    return self.knobs.count == 0;
}

- (void)addKnob:(EKNKnobInfo *)knob {
    [self.knobs insertObject:knob atIndex:0];
    
    [self.knobTable insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] inParent:nil withAnimation:NSTableViewAnimationEffectGap];
    
    // Force a relayout since just inserting doesn't seem to do that
    [self.knobTable tile];
    [self invalidateIntrinsicContentSize];
}

- (void)updateKnobWithID:(NSString*)knobID toValue:(id)value {
    [self.knobs enumerateObjectsUsingBlock:^(EKNKnobInfo* knob, NSUInteger idx, BOOL *stop) {
        if([knob.knobID isEqualToString:knobID]) {
            knob.value = value;
            id <EKNPropertyEditor> editor = [self.knobTable viewAtColumn:0 row:idx makeIfNecessary:NO];
            editor.info = knob;
            [self.externalCodeMap removeObjectForKey:knob];
        }
    }];
}

- (void)removeKnobWithID:(NSString *)knobID {
    NSIndexSet* set = [self.knobs indexesOfObjectsPassingTest:^BOOL(EKNKnobInfo* knob, NSUInteger idx, BOOL *stop) {
        if([knob.knobID isEqualToString:knobID]) {
            *stop = YES;
            [self.externalCodeMap removeObjectForKey:knob];
            return YES;
        }
        return NO;
    }];
    [self.knobs removeObjectsAtIndexes:set];
    [self.knobTable removeItemsAtIndexes:set inParent:nil withAnimation:NSTableViewAnimationEffectGap];
}

- (void)clear {
    [self.knobs removeAllObjects];
    [self.knobTable reloadData];
}

- (void)propertyEditor:(id<EKNPropertyEditor>)editor changedKnob:(EKNKnobInfo *)knob {
    [self.delegate knobTable:self changedKnob:knob];
}

#pragma mark Table View

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(EKNKnobInfo*)item {
    if(item == nil) {
        return self.knobs.count;
    }
    else {
        return item.children.count;
    }
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(EKNKnobInfo*)info {
    return [self.editorManager editorHeightWithDescription:info.propertyDescription];
}

- (NSView*)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(EKNKnobInfo*)info {
    if([tableColumn.identifier isEqualToString:@"Editor"]) {
        NSView <EKNPropertyEditor>* view = [self.knobTable makeViewWithIdentifier:info.propertyDescription.typeName owner:self];
        view.info = info;
        return view;
    }
    else if([tableColumn.identifier isEqualToString:@"Source"]) {
        EKNUpdateSourceCellView* view = [self.knobTable makeViewWithIdentifier:@"EKNUpdateSourceCellIdentifier" owner:self];
        view.delegate = self;
        view.info = info;
        return view;
    }
    else {
        NSAssert(NO, @"Unkown column %@", tableColumn);
        return nil;
    }
}

- (NSArray*)childrenOfItem:(EKNKnobInfo*)item {
    if(item == nil) {
        return self.knobs;
    }
    else {
        return item.children;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(EKNKnobInfo*)item {
    NSArray* children = [self childrenOfItem:item];
    return children[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [self childrenOfItem:item].count > 0;
}

- (void)updateSourceCell:(EKNUpdateSourceCellView *)cell shouldSaveKnob:(EKNKnobInfo *)info {
    NSError* error = nil;
    
    NSString* externalCode = [self.externalCodeMap objectForKey:info];
    
    if(externalCode) {
        if([self.sourceManager saveCode:externalCode withDescription:info.propertyDescription toFileAtPath:info.sourcePath error:&error]) {
            [[NSAlert alertWithError:error] runModal];
        }
    }
    else {
        if([self.sourceManager saveValue:info.value withDescription:info.propertyDescription toFileAtPath:info.sourcePath error:&error]) {
            [[NSAlert alertWithError:error] runModal];
        }
    }
    
}

#pragma mark Drag and Drop

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:items];
    [pasteboard declareTypes:@[] owner:self];
    [pasteboard setData:data forType:EKNSourceTableKnobType];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    if(index == -1) {
        NSArray* sourceItems = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:EKNSourceTableKnobType]];
        NSAssert(sourceItems.count == 1, @"Only supports dragging exactly one row");
        EKNKnobInfo* sourceKnob = [sourceItems firstObject];
        EKNKnobInfo* destKnob = item;
        [outlineView setDropItem:destKnob dropChildIndex:NSOutlineViewDropOnItemIndex];
        return [sourceKnob.propertyDescription isTypeEquivalentToTypeOfDescription:destKnob.propertyDescription] ? NSDragOperationCopy : NSDragOperationNone;
    }
    else {
        return NSDragOperationNone;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {

    NSArray* sourceInfos = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:EKNSourceTableKnobType]];
    NSAssert(sourceInfos.count == 1, @"Only supports dragging exactly one row");
    EKNKnobInfo* sourceKnob = [sourceInfos firstObject];
    EKNKnobInfo* destKnob = item;
    
    destKnob.value = sourceKnob.value;
    
    if(sourceKnob.externalCode != nil) {
        [self.externalCodeMap setObject:sourceKnob.externalCode forKey:destKnob];
    }
    else {
        [self.externalCodeMap removeObjectForKey:destKnob];
    }
    [self.delegate knobTable:self changedKnob:destKnob];
    
    NSInteger columnIndex = [self.knobTable columnWithIdentifier:@"Editor"];
    NSInteger destRow = [self.knobTable rowForItem:destKnob];
    id <EKNPropertyEditor> editor = [self.knobTable viewAtColumn:columnIndex row:destRow makeIfNecessary:NO];
    editor.info = destKnob;

    return YES;
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    /// This is sort of crappy, but otherwise the table doesn't resize
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self knobTable] tile];
        [self invalidateIntrinsicContentSize];
    });
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    /// This is sort of crappy, but otherwise the table doesn't resize
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self knobTable] tile];
        [self invalidateIntrinsicContentSize];
    });
}

- (NSSize)intrinsicContentSize {
    return self.knobTable.bounds.size;
}

@end
