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
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobToggleEditor" bundle:nil] forIdentifier:EKNPropertyTypeToggle];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobSliderEditor" bundle:nil] forIdentifier:EKNPropertyTypeSlider];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobImageEditor" bundle:nil] forIdentifier:EKNPropertyTypeImage];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobRectEditor" bundle:nil] forIdentifier:EKNPropertyTypeRect];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobFloatPairEditor" bundle:nil] forIdentifier:EKNPropertyTypeFloatPair];
        [self.knobTable registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobAffineTransformEditor" bundle:nil] forIdentifier:EKNPropertyTypeAffineTransform];
        self.scrollView.frame = self.bounds;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)representObject:(id)object withProperties:(NSArray *)properties {
    BOOL fullUpdate = ![self.representedObject isEqualToString: object] || properties.count != self.properties.count;
    self.representedObject = object;
    self.properties = properties;
    
    if (fullUpdate) {
        [self.knobTable reloadData];
    }
    else {
        [self.properties enumerateObjectsUsingBlock:^(EKNPropertyInfo* info, NSUInteger index, BOOL *stop) {
            NSView <EKNPropertyEditor>* editor = [self.knobTable viewAtColumn:0 row:index makeIfNecessary:NO];
            editor.info = info;
        }];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.properties.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    EKNPropertyInfo* info = [self.properties objectAtIndex:row];
    NSDictionary* sizes = @{
                            EKNPropertyTypeColor : @57,
                            EKNPropertyTypeToggle : @57,
                            EKNPropertyTypeSlider : @71,
                            EKNPropertyTypeImage : @236,
                            EKNPropertyTypeRect : @122,
                            EKNPropertyTypeFloatPair : @90,
                            EKNPropertyTypeAffineTransform : @154,
                            };
    return [[sizes objectForKey:info.propertyDescription.type] floatValue];
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    EKNPropertyInfo* info = [self.properties objectAtIndex:row];
    NSView <EKNPropertyEditor>* view = [tableView makeViewWithIdentifier:info.propertyDescription.type owner:self];
    view.info = info;
    return view;
}

#pragma mark Editor Delegate

- (void)propertyEditor:(id<EKNPropertyEditor>)editor changedProperty:(EKNPropertyDescription *)property toValue:(id)value {
    [self.delegate generatorView:self changedProperty:property toValue:value];
}

@end
