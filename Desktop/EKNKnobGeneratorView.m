//
//  EKNKnobGeneratorView.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobGeneratorView.h"

#import "EKNKnobEditorManager.h"
#import "EKNKnobInfo.h"
#import "EKNPropertyEditor.h"
#import "EKNPropertyDescription.h"

#import "NSArray+EKNFunctional.h"

@interface EKNKnobGeneratorView () <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) IBOutlet NSTableView* knobTable;
@property (strong, nonatomic) id representedObject;
@property (copy, nonatomic) NSArray* knobs;

@end


@implementation EKNKnobGeneratorView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self != nil) {
        [[NSBundle mainBundle] loadNibNamed:@"EKNKnobGeneratorView" owner:self topLevelObjects:NULL];

        
        [self addSubview:self.knobTable];
        
        self.knobTable.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_knobTable]-0-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_knobTable]-0-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        
        [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
        
        [[EKNKnobEditorManager sharedManager] registerPropertyTypesInTableView:self.knobTable];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)representObject:(id)object withKnobs:(NSArray *)knobs {
    BOOL fullUpdate = ![self.representedObject isEqual: object] || knobs.count != self.knobs.count;
    self.representedObject = object;
    self.knobs = knobs;
    
    if (fullUpdate) {
        [self.knobTable reloadData];
    }
    else {
        [self.knobs enumerateObjectsUsingBlock:^(EKNKnobInfo* info, NSUInteger index, BOOL *stop) {
            NSView <EKNPropertyEditor>* editor = [self.knobTable viewAtColumn:0 row:index makeIfNecessary:NO];
            editor.info = info;
        }];
    }
}

- (void)addKnob:(EKNKnobInfo *)knob {
    self.knobs = [@[knob] arrayByAddingObjectsFromArray:self.knobs];
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
    NSMutableIndexSet* set = [[NSMutableIndexSet alloc] init];
    [self.knobs filterWithIndex:^BOOL(EKNKnobInfo* knob, NSUInteger index) {
        if([knob.knobID isEqualToString:knobID]) {
            [set addIndex:index];
            return NO;
        }
        return YES;
    }];
    [self.knobTable removeRowsAtIndexes:set withAnimation:NSTableViewAnimationEffectGap];
}

- (void)clear {
    self.knobs  = [NSArray array];
    self.representedObject = nil;
    [self.knobTable reloadData];
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
        EKNKnobInfo* info = [self.knobs objectAtIndex:row];
        NSView <EKNPropertyEditor>* view = [tableView makeViewWithIdentifier:info.propertyDescription.type owner:self];
        view.info = info;
        return view;
    }
    return nil;
}

#pragma mark Editor Delegate

- (void)propertyEditor:(id<EKNPropertyEditor>)editor changedKnob:(EKNKnobInfo *)knob {
    [self.delegate generatorView:self changedKnob:knob];
}

- (NSSize)intrinsicContentSize {
    return self.knobTable.bounds.size;
}

@end
