//
//  EKNPanelWindowController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPanelWindowController.h"

@interface EKNPanelWindowController ()

@end

@implementation EKNPanelWindowController


- (NSString*)windowNibName {
    return @"EKNPanelWindowController";
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"loaded window");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
