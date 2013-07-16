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
#import "EKNConsoleWindowController.h"
#import "EKNConsolePluginRegistry.h"

@interface EKNAppDelegate ()

@property (strong, nonatomic) EKNConsoleWindowController* mainWindow;
@property (strong, nonatomic) EKNConsolePluginRegistry* pluginRegistry;

@end

@implementation EKNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    
    self.pluginRegistry = [[EKNConsolePluginRegistry alloc] init];
    [self.pluginRegistry loadPlugins];
    [self makeMainWindow];
}

- (IBAction)newDocument:(id)sender {
    [self.mainWindow showWindow:self];
}

- (void)makeMainWindow {
    self.mainWindow = [[EKNConsoleWindowController alloc] initWithPluginRegistry:self.pluginRegistry];
    [self.mainWindow showWindow:self];
}

@end
