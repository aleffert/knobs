//
//  EKNEventTrampolineTableView.m
//  Knobs
//
//  Created by Akiva Leffert on 12/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNEventTrampolineTableView.h"

@implementation EKNEventTrampolineTableView

/// Needed so that NSSteppers can work inside table cell
- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event {
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    NSInteger row = [self selectedRow];
    if(row != -1) {
        for(NSUInteger index = 0; index < self.tableColumns.count; index++) {
            NSView* view = [self viewAtColumn:index row:row makeIfNecessary:NO];
            if([view conformsToProtocol:@protocol(EKNEventTrampolineKeyHandler)]) {
                [view keyDown:theEvent];
            }
        }
    }
    else {
        [super keyDown:theEvent];
    }
}

@end
