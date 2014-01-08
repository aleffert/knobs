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

static NSString* const EKNSourceTableRowIndexDragType = @"EKNSourceTableRowIndexDragType";

@interface EKNSourcedKnobTable () <NSTableViewDelegate, NSTableViewDataSource, EKNPropertyEditorDelegate, EKNUpdateSourceCellViewDelegate>

@property (strong, nonatomic) IBOutlet NSTableView* knobTable;
@property (strong, nonatomic) NSMutableArray* knobs;
@property (strong, nonatomic) NSMutableDictionary* externalCodeMap;

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
        
        [self.knobTable registerForDraggedTypes:@[EKNSourceTableRowIndexDragType]];
        
        self.knobTable.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_knobTable]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_knobTable]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        
        [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
        
        [self.editorManager registerPropertyTypesInTableView:self.knobTable];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNUpdateSourceCellView" bundle:Nil] forIdentifier:@"EKNUpdateSourceCellIdentifier"];
        
        self.externalCodeMap = [[NSMutableDictionary alloc] init];
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
    [self.knobTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectGap];
    
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
        }
    }];
    [self.externalCodeMap removeObjectForKey:knobID];
}

- (void)removeKnobWithID:(NSString *)knobID {
    NSIndexSet* set = [self.knobs indexesOfObjectsPassingTest:^BOOL(EKNKnobInfo* knob, NSUInteger idx, BOOL *stop) {
        if([knob.knobID isEqualToString:knobID]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    [self.knobs removeObjectsAtIndexes:set];
    [self.knobTable removeRowsAtIndexes:set withAnimation:NSTableViewAnimationEffectGap];
    [self.externalCodeMap removeObjectForKey:knobID];
}

- (void)clear {
    [self.knobs removeAllObjects];
    [self.knobTable reloadData];
}

- (void)propertyEditor:(id<EKNPropertyEditor>)editor changedKnob:(EKNKnobInfo *)knob {
    [self.delegate knobTable:self changedKnob:knob];
}

#pragma mark Table View

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.knobs.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if(row < self.knobs.count) {
        EKNKnobInfo* info = [self.knobs objectAtIndex:row];
        return [self.editorManager editorHeightOfType:info.propertyDescription.type];
    }
    else {
        // AppKit seems to request this even when the table is empty with row = 0
        // And it also doesn't support zero height cells
        return 1;
    }
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(row < self.knobs.count) {
        if([tableColumn.identifier isEqualToString:@"Editor"]) {
            EKNKnobInfo* info = [self.knobs objectAtIndex:row];
            NSView <EKNPropertyEditor>* view = [tableView makeViewWithIdentifier:info.propertyDescription.typeName owner:self];
            view.info = info;
            return view;
        }
        else if([tableColumn.identifier isEqualToString:@"Source"]) {
            EKNKnobInfo* info = [self.knobs objectAtIndex:row];
            EKNUpdateSourceCellView* view = [tableView makeViewWithIdentifier:@"EKNUpdateSourceCellIdentifier" owner:self];
            view.delegate = self;
            view.info = info;
            return view;
        }
    }
    return nil;
}

- (void)updateSourceCell:(EKNUpdateSourceCellView *)cell shouldSaveKnob:(EKNKnobInfo *)info {
    NSError* error = nil;
    
    NSString* externalCode = self.externalCodeMap[info.knobID];
    
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

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:@[EKNSourceTableRowIndexDragType] owner:self];
    [pboard setData:data forType:EKNSourceTableRowIndexDragType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if(dropOperation == NSTableViewDropOn) {
        NSIndexSet* sourceIndices = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:EKNSourceTableRowIndexDragType]];
        NSAssert(sourceIndices.count == 1, @"Only supports dragging exactly one row");
        NSUInteger index = [sourceIndices firstIndex];
        EKNKnobInfo* sourceKnob = self.knobs[index];
        EKNPropertyType sourceType = sourceKnob.propertyDescription.type;
        EKNKnobInfo* destKnob = self.knobs[row];
        EKNPropertyType destType = destKnob.propertyDescription.type;
        return sourceType == destType ? NSDragOperationCopy : NSDragOperationNone;
    }
    else {
        // TODO: Support row reordering
        return NSDragOperationNone;
    }
}
- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)destRow dropOperation:(NSTableViewDropOperation)op {
    NSAssert(op == NSTableViewDropOn, @"TODO: Support row reordering");
    NSIndexSet* sourceIndices = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:EKNSourceTableRowIndexDragType]];
    NSAssert(sourceIndices.count == 1, @"Only supports dragging exactly one row");
    NSUInteger sourceRow = [sourceIndices firstIndex];
    EKNKnobInfo* sourceKnob = self.knobs[sourceRow];
    EKNKnobInfo* destKnob = self.knobs[destRow];
    
    destKnob.value = sourceKnob.value;
    
    if(sourceKnob.externalCode != nil) {
        self.externalCodeMap[destKnob.knobID] = sourceKnob.externalCode;
    }
    else {
        [self.externalCodeMap removeObjectForKey:destKnob.knobID];
    }
    [self.delegate knobTable:self changedKnob:destKnob];
    
    NSInteger columnIndex = [self.knobTable columnWithIdentifier:@"Editor"];
    id <EKNPropertyEditor> editor = [self.knobTable viewAtColumn:columnIndex row:destRow makeIfNecessary:NO];
    editor.info = destKnob;

    return YES;
}

- (NSSize)intrinsicContentSize {
    return self.knobTable.bounds.size;
}

@end
