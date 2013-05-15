//
//  EKNAppDelegate.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNAppDelegate.h"

#import "EKNDeviceConnection.h"
#import "EKNDeviceFinder.h"
#import "EKNPanelWindowController.h"
#import "EKNConsolePluginRegistry.h"

@interface EKNAppDelegate () <EKNPanelWindowControllerDelegate>

@property (strong, nonatomic) NSMutableArray* activeWindows;
@property (strong, nonatomic) EKNConsolePluginRegistry* pluginRegistry;

@end

@implementation EKNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.pluginRegistry = [[EKNConsolePluginRegistry alloc] init];
    [self.pluginRegistry loadPlugins];
    self.activeWindows = [NSMutableArray array];
    [self makeNewWindow];
}

- (IBAction)newDocument:(id)sender {
    [self makeNewWindow];
}

- (void)makeNewWindow {
    EKNPanelWindowController* controller = [[EKNPanelWindowController alloc] initWithPluginRegistry:self.pluginRegistry];
    controller.delegate = self;
    [self.activeWindows addObject:controller];
    [controller showWindow:self];
}

- (void)willCloseWindowWithController:(EKNPanelWindowController *)windowController {
    [self.activeWindows removeObject:windowController];
}

@end
