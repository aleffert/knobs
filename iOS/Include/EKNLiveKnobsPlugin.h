//
//  EKNLiveKnobsPlugin.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNDevicePlugin.h"

#import "EKNPropertyDescription.h"

@interface EKNLiveKnobsPlugin : NSObject <EKNDevicePlugin>

+ (EKNLiveKnobsPlugin*)sharedPlugin;

// These are currently not thread safe. Should only be called from the main thread

// owner is held weakly
// knob is removed automatically if owner gets deallocated
- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description currentValue:(id)value callback:(void(^)(id owner, id value))callback;

// Notify the listener that the value changed. Optional, but will make ensure the UI matches the actual value
- (void)updateValueWithOwner:(id)owner name:(NSString*)name value:(id)value;

// cancel early. Pass nil as name to cancel everything from owner
- (void)cancelCallbackWithOwner:(id)owner name:(NSString*)name;

// todo conveniences. Support for multiple channels and a default channel

@end
