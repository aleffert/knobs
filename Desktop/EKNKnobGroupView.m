//
//  EKNKnobGroupView.m
//  Knobs
//
//  Created by Akiva Leffert on 12/22/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobGroupView.h"

@interface EKNKnobGroupView ()

@property (strong, nonatomic) IBOutlet NSScrollView* scrollView;
@property (strong, nonatomic) IBOutlet NSStackView* stackView;

@end

@implementation EKNKnobGroupView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self != nil) {
    }
    return self;
}

@end
