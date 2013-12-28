//
//  EKNEventTrampolineTableView.m
//  Knobs
//
//  Created by Akiva Leffert on 12/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNEventTrampolineTableView.h"

@implementation EKNEventTrampolineTableView

- (void)keyDown:(NSEvent *)theEvent {
    NSInteger row = [self selectedRow];
    if(row != -1) {
        // TODO use a less sketch way of getting the column index
        NSView* view = [self viewAtColumn:0 row:row makeIfNecessary:NO];
        if([view conformsToProtocol:@protocol(EKNEventTrampolineKeyHandler)]) {
            [view keyDown:theEvent];
        }
    }
    else {
        [super keyDown:theEvent];
    }
}

@end
