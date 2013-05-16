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

@protocol EKNConsoleWindowControllerDelegate;

@interface EKNConsoleWindowController : NSWindowController <NSWindowDelegate>

- (id)initWithPluginRegistry:(EKNConsolePluginRegistry*)pluginRegistry;

@property (weak, nonatomic) id <EKNConsoleWindowControllerDelegate> delegate;

@end

@protocol EKNConsoleWindowControllerDelegate <NSObject>

- (void)willCloseWindowWithController:(EKNConsoleWindowController*)windowController;

@end