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

@interface EKNKnobGroupsView () <EKNDisclosureViewDelegate>

@property (strong, nonatomic) NSMutableArray* closedGroupNames;

@property (strong, nonatomic) IBOutlet NSScrollView* scrollView;
@property (strong, nonatomic) IBOutlet NSStackView* stackView;

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
    }
    return self;
}

- (void)loadClosedGroupsIfNecessary {
    if(self.closedGroupNames == nil) {
        self.closedGroupNames = [[NSMutableArray alloc] init];
        if(self.disclosureAutosaveName != nil) {
            [self.closedGroupNames addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:self.disclosureAutosaveName]];
        }
    }
}

- (void)updateDividers {
    [self.stackView.views enumerateObjectsUsingBlock:^(EKNDisclosureView* view, NSUInteger idx, BOOL *stop) {
        view.showsTopDivider = idx != 0;
    }];
}

- (void)addGroupNamed:(NSString*)groupName contentView:(NSView*)contentView {
    [self loadClosedGroupsIfNecessary];
    EKNDisclosureView* container = [[EKNDisclosureView alloc] initWithFrame:CGRectMake(0, 0, self.stackView.frame.size.width, 100)];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    container.title = groupName;
    container.delegate = self;
    container.disclosedView = contentView;
    container.disclosed = ![self.closedGroupNames containsObject:groupName];
    [self.stackView addView:container inGravity:NSStackViewGravityCenter];
    
    [self updateDividers];
}

- (void)removeGroupWithContentView:(NSView *)contentView {
    EKNDisclosureView* parentView = nil;
    for(EKNDisclosureView* view in self.stackView.views) {
        if(view.disclosedView == contentView) {
            parentView = view;
            break;
        }
    }
    if(parentView) {
        [self.stackView removeView:parentView];
    }
    [self updateDividers];
}

- (void)clear {
    NSArray* stackViews = self.stackView.views;
    for (NSView* view in stackViews) {
        [self.stackView removeView:view];
    }
}

#pragma mark Disclosure Defaults

- (void)saveDefaults {
    if(self.disclosureAutosaveName) {
        [[NSUserDefaults standardUserDefaults] setObject:self.closedGroupNames forKey:self.disclosureAutosaveName];
    }
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
