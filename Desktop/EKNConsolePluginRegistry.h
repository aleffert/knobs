//
//  EKNConsolePluginRegistry.h
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EKNConsolePlugin;

@interface EKNConsolePluginRegistry : NSObject

- (void)loadPlugins;

- (id <EKNConsolePlugin>)pluginWithName:(NSString*)name;

@end
