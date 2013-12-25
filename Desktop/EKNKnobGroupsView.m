//
//  EKNKnobGroupsView.m
//  Knobs
//
//  Created by Akiva Leffert on 12/22/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobGroupsView.h"

#import "EKNDisclosureView.h"
#import "EKNKnobGeneratorView.h"
#import "EKNNamedGroup.h"

static NSString* const EKNKnobGroupsClosedGroupsKey = @"EKNKnobGroupsClosedGroupsKey";

@interface EKNKnobGroupsView () <EKNKnobGeneratorViewDelegate, EKNDisclosureViewDelegate>

@property (strong, nonatomic) NSMutableArray* closedGroupNames;

@property (strong, nonatomic) IBOutlet NSScrollView* scrollView;
@property (strong, nonatomic) IBOutlet NSStackView* stackView;

/// group views in order
@property (strong, nonatomic) NSMutableArray* groupViews;

/// map from group name to group view
@property (strong, nonatomic) NSMutableDictionary* groupNameMap;

@property (strong, nonatomic) id representedObject;

@end

@implementation EKNKnobGroupsView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self != nil) {
        [[NSBundle mainBundle] loadNibNamed:@"EKNKnobGroupsView" owner:self topLevelObjects:NULL];
        [self addSubview:self.scrollView];
        self.scrollView.frame = self.bounds;
        
        self.groupNameMap = [[NSMutableDictionary alloc] init];
        self.groupViews = [[NSMutableArray alloc] init];
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.stackView setClippingResistancePriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
        
        [self.stackView setHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
        
        [self.stackView setClippingResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationVertical];
        
        NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_scrollView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_scrollView]-0-|" options:0 metrics:nil views:viewsDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_scrollView]-0-|" options:0 metrics:nil views:viewsDict]];
        
        viewsDict = NSDictionaryOfVariableBindings(_stackView);
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_stackView]-0-|" options:0 metrics:nil views:viewsDict]];
        
        self.closedGroupNames = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:EKNKnobGroupsClosedGroupsKey]];
    }
    return self;
}

- (void)representObject:(id)object withGroups:(NSArray *)groups {
    BOOL fullUpdate = ![self.representedObject isEqual: object] || groups.count != self.groupViews.count;
    self.representedObject = object;
    
    if (fullUpdate) {
        [self clearViews];
        
        [groups enumerateObjectsUsingBlock:^(EKNNamedGroup* group, NSUInteger index, BOOL *stop) {
            EKNDisclosureView* container = [[EKNDisclosureView alloc] initWithFrame:CGRectMake(0, 0, self.stackView.frame.size.width, 100)];
            container.title = group.name;
            container.showsTopDivider = index != 0;
            container.delegate = self;
            EKNKnobGeneratorView* knobView = [[EKNKnobGeneratorView alloc] initWithFrame:CGRectMake(0, 0, self.stackView.frame.size.width, 100)];
            container.disclosedView = knobView;
            container.disclosed = ![self.closedGroupNames containsObject:group.name];
            knobView.delegate = self;
            [self.stackView addView:container inGravity:NSStackViewGravityCenter];
            self.groupNameMap[group.name] = knobView;
            [self.groupViews addObject:knobView];
            [knobView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [knobView representObject:object withKnobs:group.items];
        }];
    }
    else {
        for(EKNNamedGroup* group in groups) {
            EKNKnobGeneratorView* knobView = self.groupNameMap[group.name];
            [knobView representObject:object withKnobs:group.items];
        }
    }
}

- (void)clearViews {
    NSArray* stackViews = self.stackView.views;
    for (NSView* view in stackViews) {
        [view removeFromSuperview];
    }
    
    [self.groupViews removeAllObjects];
    [self.groupNameMap removeAllObjects];
}

- (void)clear {
    [self clearViews];
    self.representedObject = nil;
}

- (void)generatorView:(EKNKnobGeneratorView *)view changedKnob:(EKNKnobInfo *)knob {
    [self.delegate knobGroupsView:self changedKnob:knob];
}

#pragma mark Disclosure Defaults

- (void)saveDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:self.closedGroupNames forKey:EKNKnobGroupsClosedGroupsKey];
}

- (void)disclosureViewOpened:(EKNDisclosureView *)disclosureView {
    [self.closedGroupNames removeObject:disclosureView.title];
    [self saveDefaults];
}

- (void)disclosureViewClosed:(EKNDisclosureView *)disclosureView {
    [self.closedGroupNames addObject:disclosureView.title];
    [self saveDefaults];
}

@end
