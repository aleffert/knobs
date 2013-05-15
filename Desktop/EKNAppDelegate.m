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

@interface EKNAppDelegate ()

@property (strong, nonatomic) EKNPanelWindowController* windowController;
@property (strong, nonatomic) EKNConsolePluginRegistry* pluginRegistry;

@end

@implementation EKNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.pluginRegistry = [[EKNConsolePluginRegistry alloc] init];
    [self.pluginRegistry loadPlugins];
    [self makeNewWindow];
}

- (void)makeNewWindow {
    self.windowController = [[EKNPanelWindowController alloc] initWithPluginRegistry:self.pluginRegistry];
    
//    self.deviceFinder = [[EKNDeviceFinder alloc] init];
//    self.deviceConnection = [[EKNDeviceConnection alloc] init];
//    [self.deviceFinder start];
//    self.windowController.deviceFinder = self.deviceFinder;
//    self.windowController.deviceConnection = self.deviceConnection;
    [self.windowController showWindow:self];
}

@end
