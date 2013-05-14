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

@interface EKNAppDelegate ()

@property (strong, nonatomic) EKNPanelWindowController* windowController;

@property (strong, nonatomic) EKNDeviceFinder* deviceFinder;
@property (strong, nonatomic) EKNDeviceConnection* deviceConnection;

@end

@implementation EKNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.deviceFinder = [[EKNDeviceFinder alloc] init];
    self.deviceConnection = [[EKNDeviceConnection alloc] init];
    [self makeNewWindow];
    [self.deviceFinder start];
}

- (void)makeNewWindow {
    self.windowController = [[EKNPanelWindowController alloc] init];
    self.windowController.deviceFinder = self.deviceFinder;
    self.windowController.deviceConnection = self.deviceConnection;
    [self.windowController showWindow:self];
}

@end
