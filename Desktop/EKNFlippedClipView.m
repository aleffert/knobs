//
//  EKNFlippedClipView.m
//  Knobs
//
//  Created by Akiva Leffert on 12/22/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNFlippedClipView.h"

@implementation EKNFlippedClipView

- (BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

@end
