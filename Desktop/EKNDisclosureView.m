//
//  EKNDisclosureView.m
//  Knobs
//
//  Created by Akiva Leffert on 12/23/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDisclosureView.h"

#import <QuartzCore/QuartzCore.h>

@interface EKNDisclosureView ()

@property (strong, nonatomic) IBOutlet NSTextField* titleLabel;
@property (strong, nonatomic) IBOutlet NSButton *disclosureButton;
@property (strong, nonatomic) IBOutlet NSView* headerView;
@property (strong, nonatomic) IBOutlet NSView* divider;

@property (strong, nonatomic) NSLayoutConstraint *closingConstraint;

@property (assign, nonatomic) BOOL isDisclosed;

@end

@implementation EKNDisclosureView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EKNDisclosureView" owner:self topLevelObjects:nil];
        self.headerView.frame = CGRectMake(0, self.frame.size.height - self.headerView.frame.size.height, self.frame.size.width, self.headerView.frame.size.height);
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.headerView];
        self.isDisclosed = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [self.titleLabel setStringValue:title];
}

- (NSString*)title {
    return self.titleLabel.stringValue;
}

- (void)setDisclosedView:(NSView *)disclosedView
{
    if (_disclosedView != disclosedView)
    {
        [self.disclosedView removeFromSuperview];
        _disclosedView = disclosedView;
        [self addSubview:self.disclosedView];
        
        // we want a white background to distinguish between the
        // header portion of this view controller containing the hide/show button
        //
        self.disclosedView.wantsLayer = YES;
        self.disclosedView.layer.backgroundColor = [[NSColor whiteColor] CGColor];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_disclosedView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_disclosedView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_headerView][_disclosedView]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_headerView, _disclosedView)]];
        
        // add an optional constraint (but with a priority stronger than a drag), that the disclosing view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_disclosedView]-(0@600)-|"
                                                                          options:0 metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_disclosedView)]];
    }
}

- (void)setDisclosed:(BOOL)disclosed animated:(BOOL)animated {
    if (!disclosed && self.isDisclosed)
    {
        CGFloat distanceFromHeaderToBottom = NSMinY(self.bounds) - NSMinY(self.headerView.frame);
        
        if (!self.closingConstraint)
        {
            // The closing constraint is going to tie the bottom of the header view to the bottom of the overall disclosure view.
            // Initially, it will be offset by the current distance, but we'll be animating it to 0.
            self.closingConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:distanceFromHeaderToBottom];
        }
        self.closingConstraint.constant = distanceFromHeaderToBottom;
        [self addConstraint:self.closingConstraint];
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            // Animate the closing constraint to 0, causing the bottom of the header to be flush with the bottom of the overall disclosure view.
            if(animated) {
                self.closingConstraint.animator.constant = 0;
            }
            else {
                self.closingConstraint.constant = 0;
            }
            self.disclosureButton.title = @"Show";
        } completionHandler:^{
            self.isDisclosed = NO;
        }];
    }
    else if(disclosed && !self.isDisclosed)
    {
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            // Animate the constraint to fit the disclosed view again
            CGFloat offset = self.disclosedView.frame.size.height;
            if(animated) {
                self.closingConstraint.animator.constant -= offset;
            }
            else {
                self.closingConstraint.constant -= offset;
            }
            self.disclosureButton.title = @"Hide";
        } completionHandler:^{
            // The constraint is no longer needed, we can remove it.
            [self removeConstraint:self.closingConstraint];
            self.isDisclosed = YES;
        }];
    }
}

// The hide/show button was clicked
//
- (IBAction)toggleDisclosure:(id)sender
{
    BOOL nextDisclosure = !self.isDisclosed;
    [self setDisclosed:nextDisclosure animated:YES];

    if(nextDisclosure) {
        [self.delegate disclosureViewOpened:self];
    }
    else {
        [self.delegate disclosureViewClosed:self];
    }
}

- (void)setShowsTopDivider:(BOOL)showsTopDivider {
    [self.divider setHidden:!showsTopDivider];
    _showsTopDivider = showsTopDivider;
}

- (void)setDisclosed:(BOOL)disclosed {
    [self setDisclosed:disclosed animated:NO];
}

- (BOOL)disclosed {
    return self.isDisclosed;
}

@end
