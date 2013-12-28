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

@interface EKNSourcedKnobTable () <NSTableViewDelegate, NSTableViewDataSource, EKNPropertyEditorDelegate, EKNUpdateSourceCellViewDelegate>

@property (strong, nonatomic) IBOutlet NSTableView* knobTable;
@property (strong, nonatomic) NSMutableArray* knobs;

@end

@implementation EKNSourcedKnobTable


- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self != nil) {
        [[NSBundle mainBundle] loadNibNamed:@"EKNSourcedKnobTable" owner:self topLevelObjects:NULL];
        
        self.knobs = [[NSMutableArray alloc] init];
        
        [self addSubview:self.knobTable];
        
        self.knobTable.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_knobTable]-0-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_knobTable]-0-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        
        [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
        
        [[EKNKnobEditorManager sharedManager] registerPropertyTypesInTableView:self.knobTable];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNUpdateSourceCellView" bundle:Nil] forIdentifier:@"EKNUpdateSourceCellIdentifier"];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}


- (void)addKnob:(EKNKnobInfo *)knob {
    [self.knobs insertObject:knob atIndex:0];
    [self.knobTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectGap];
}

- (void)updateKnobWithID:(NSString*)knobID toValue:(id)value {
    [self.knobs enumerateObjectsUsingBlock:^(EKNKnobInfo* knob, NSUInteger idx, BOOL *stop) {
        if([knob.knobID isEqualToString:knobID]) {
            knob.value = value;
            id <EKNPropertyEditor> editor = [self.knobTable viewAtColumn:0 row:idx makeIfNecessary:NO];
            editor.info = knob;
        }
    }];
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
        return [[EKNKnobEditorManager sharedManager] editorHeightOfType:info.propertyDescription.type];
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
    if([[EKNSourceManager sharedManager] saveValue:info.value withDescription:info.propertyDescription toFileAtPath:info.sourcePath error:&error]) {
        [[NSAlert alertWithError:error] runModal];
    }
    
}

@end
