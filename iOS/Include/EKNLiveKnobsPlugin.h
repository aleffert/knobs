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

/// Add a knob owned by owner. owner shouldn't be nil
/// owner is held weakly
/// knob is removed automatically if owner gets deallocated
/// callback may be nil
/// path is the path to the source file containing the registration. It may be nil.
- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description currentValue:(id)value callback:(void(^)(id owner, id value))callback sourcePath:(NSString*)path;

/// Registers a knob that is just a push button with the given name
- (void)registerPushButtonWithOwner:(id)owner name:(NSString*)name callback:(void(^)(id owner))callback;

/// Notify the listener that the value changed. Optional, but will make ensure the UI matches the actual value
- (void)updateValueWithOwner:(id)owner name:(NSString*)name value:(id)value;

/// cancel early. Pass nil as name to cancel everything from owner
- (void)cancelCallbackWithOwner:(id)owner name:(NSString*)name;

@end
