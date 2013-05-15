//
//  EKNDevicePluginContextDispatcher.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNDevicePluginContext.h"

// This is a trampoline up to its delegate to make sure that plugins never need to have
// a strong pointer to the plugin system, but give them something they can hold onto however they choose
@protocol EKNDevicePluginContextDispatcherDelegate;

@interface EKNDevicePluginContextDispatcher : NSObject <EKNDevicePluginContext>

@property (weak, nonatomic) id <EKNDevicePluginContextDispatcherDelegate> delegate;

@end


@protocol EKNDevicePluginContextDispatcherDelegate <NSObject, EKNDevicePluginContext>

@end