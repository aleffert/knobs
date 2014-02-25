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

@interface EKNKnobGeneratorView () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (strong, nonatomic) EKNKnobEditorManager* editorManager;
@property (strong, nonatomic) IBOutlet NSOutlineView* knobTable;
@property (strong, nonatomic) id representedObject;
@property (copy, nonatomic) NSArray* knobs;

@end


@implementation EKNKnobGeneratorView

- (id)initWithFrame:(NSRect)frameRect editorManager:(EKNKnobEditorManager*)manager {
    self = [super initWithFrame:frameRect];
    if(self != nil) {
        self.editorManager = manager;
        [[NSBundle mainBundle] loadNibNamed:@"EKNKnobGeneratorView" owner:self topLevelObjects:NULL];
        
        [self addSubview:self.knobTable];
        
        self.knobTable.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_knobTable]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_knobTable]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_knobTable)]];
        
        [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
        
        [self.editorManager registerPropertyTypesInTableView:self.knobTable];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)recursivelyUpdateEditorsForKnob:(EKNKnobInfo*)knob {
    NSInteger rowIndex = [self.knobTable rowForItem:knob];
    if(rowIndex != -1) {
        NSView <EKNPropertyEditor>* editor = [self.knobTable viewAtColumn:0 row:rowIndex makeIfNecessary:NO];
        editor.info = knob;
    }
    
    for(EKNKnobInfo* child in knob.children) {
        [self recursivelyUpdateEditorsForKnob:child];
    }

}

- (void)representObject:(id)object withKnobs:(NSArray *)knobs {
    BOOL fullUpdate = ![self.representedObject isEqual: object] || knobs.count != self.knobs.count;
    
    if (fullUpdate) {
        self.representedObject = object;
        self.knobs = knobs;
        [self.knobTable reloadData];
    }
    else {
        [self.knobs enumerateObjectsUsingBlock:^(EKNKnobInfo* info, NSUInteger index, BOOL *stop) {
            info.value = [knobs[index] value];
            [info updateChildrenAfterValueChange];
            [self recursivelyUpdateEditorsForKnob:info];
        }];
    }
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
    NSView <EKNPropertyEditor>* view = [self.knobTable makeViewWithIdentifier:info.propertyDescription.typeName owner:self];
    view.info = info;
    return view;
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


#pragma mark Editor Delegate

- (void)propertyEditor:(id<EKNPropertyEditor>)editor changedKnob:(EKNKnobInfo *)knob {
    [self.delegate generatorView:self changedKnob:knob];
}

- (NSSize)intrinsicContentSize {
    return self.knobTable.bounds.size;
}

@end
