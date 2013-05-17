//
//  EKNKnobGeneratorView.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobGeneratorView.h"

#import "EKNPropertyEditor.h"
#import "EKNPropertyInfo.h"
#import "EKNPropertyDescription.h"

@interface EKNKnobGeneratorView () <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) IBOutlet NSScrollView* scrollView;
@property (strong, nonatomic) IBOutlet NSTableView* knobTable;
@property (strong, nonatomic) id representedObject;
@property (copy, nonatomic) NSArray* properties;

@end


@implementation EKNKnobGeneratorView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self != nil) {
        [[NSBundle mainBundle] loadNibNamed:@"EKNKnobGeneratorView" owner:self topLevelObjects:NULL];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobColorEditor" bundle:nil] forIdentifier:EKNPropertyTypeColor];
        self.scrollView.frame = self.bounds;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)representObject:(id)object withProperties:(NSArray *)properties {
    BOOL fullUpdate = [self.representedObject isEqualToString: object] || properties.count != self.properties.count;
    self.representedObject = object;
    self.properties = properties;
    
    if (fullUpdate) {
        [self.knobTable reloadData];
    }
    else {
        // TODO: Update visible cells
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.properties.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    EKNPropertyInfo* info = [self.properties objectAtIndex:row];
    if([info.propertyDescription.type isEqualToString:EKNPropertyTypeColor]) {
        return 57;
    }
    else {
        return 40;
    }
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    EKNPropertyInfo* info = [self.properties objectAtIndex:row];
    NSView <EKNPropertyEditor>* view = [tableView makeViewWithIdentifier:info.propertyDescription.type owner:self];
    view.info = info;
    return view;
}

@end
