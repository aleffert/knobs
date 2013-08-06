//
//  EKNViewFrobFocusOverlay.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 8/6/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobFocusOverlay.h"

@implementation EKNViewFrobFocusOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [self lineColor].CGColor;
        self.layer.borderWidth = 2;
    }
    return self;
}

- (UIColor*)lineColor {
    return [UIColor colorWithRed:0 green:.5 blue:1. alpha:1.];
}

@end
