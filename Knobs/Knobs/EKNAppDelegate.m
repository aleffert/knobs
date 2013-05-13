//
//  EKNAppDelegate.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNAppDelegate.h"

#import "EKNPanelWindowController.h"

@interface EKNAppDelegate ()

@property (strong, nonatomic) EKNPanelWindowController* windowController;

@end

@implementation EKNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self makeNewWindow];
}

- (void)makeNewWindow {
    self.windowController = [[EKNPanelWindowController alloc] init];
    [self.windowController showWindow:self];
}

@end
