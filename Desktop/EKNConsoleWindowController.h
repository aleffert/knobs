//
//  EKNConsoleWindowController.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EKNConsolePluginRegistry;
@class EKNDeviceConnection;
@class EKNDeviceFinder;

@interface EKNConsoleWindowController : NSWindowController <NSWindowDelegate>

- (id)initWithPluginRegistry:(EKNConsolePluginRegistry*)pluginRegistry;

@end
