//
//  EKNConsolePluginRegistry.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNConsolePluginRegistry.h"

#import "EKNConsolePlugin.h"

@interface EKNConsolePluginRegistry ()

@property (strong, nonatomic) NSDictionary* plugins;

@end

@implementation EKNConsolePluginRegistry

- (NSString*)bundlePluginPath {
    return [[NSBundle mainBundle] builtInPlugInsPath];
}

- (NSString*)applicationSupportPluginPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    return [[applicationSupportDirectory stringByAppendingPathComponent:@"Knobs"] stringByAppendingPathComponent:@"PlugIns"];
}

- (NSArray*)defaultPluginPaths {
    return @[[self bundlePluginPath], [self applicationSupportPluginPath]];
}

- (void)loadPlugins {
    NSMutableDictionary* plugins = [[NSMutableDictionary alloc] init];
    NSArray* pluginPaths = [self defaultPluginPaths];
    for(NSString* containerPath in pluginPaths) {
        // TODO: Error handling
        for (NSString* pluginPath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:containerPath error:nil]) {
            NSBundle* bundle = [[NSBundle alloc] initWithPath:pluginPath];
            Class pluginClass = [bundle principalClass];
            id <EKNConsolePlugin> plugin = [[pluginClass alloc] init];
            [plugins setObject:plugin forKey:plugin.name];
        }
    }
}

- (id <EKNConsolePlugin>)pluginWithName:(NSString *)name {
    return nil;
}

@end
