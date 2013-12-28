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
/// Live source updating won't work unless you go through the EKNMake macros below
/// Even if you pass sourcePath
- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description label:(NSString*)label currentValue:(id)value callback:(void(^)(id owner, id value))callback sourcePath:(NSString*)path;

/// Registers a knob that is just a push button with the given name
- (void)registerPushButtonWithOwner:(id)owner name:(NSString*)name callback:(void(^)(id owner))callback;

/// Notify the listener that the value changed. Optional, but will make ensure the UI matches the actual value
- (void)updateValueWithOwner:(id)owner name:(NSString*)name value:(id)value;

/// cancel early. Pass nil as name to cancel everything from owner
- (void)cancelCallbackWithOwner:(id)owner name:(NSString*)name;

@end


/// Delimiter so our regex based parser can find the right place to update
/// This is pretty sketchy
#define EKNMarker

/// Convert a bit of code into a string
#define EKNSymbolName(symbol) @"" #symbol

/// Create a knob pointing to the current file
#define EKNMakeKnob(owner, propertyDescription, symbol, labelText, value, wrappedValue, action) ({\
    [[EKNLiveKnobsPlugin sharedPlugin] registerOwner:owner info:propertyDescription label:labelText currentValue:wrappedValue callback:^(id innerOwner, id changedValue) { \
            if([innerOwner respondsToSelector:@selector(ekn_knobChangedNamed:withDescription:toValue:)]) { \
                [innerOwner ekn_knobChangedNamed:labelText withDescription:propertyDescription toValue:changedValue];\
            } \
            action(innerOwner, changedValue); \
        } \
    sourcePath:@""__FILE__]; \
    symbol = value; \
})

#define EKNMakeToggleKnob(symbol, value, label) \
EKNMakeKnob(self, [EKNPropertyDescription togglePropertyWithName:EKNSymbolName(symbol)], symbol, label, value, @(value), ^(id owner, NSValue* changedValue){symbol = [changedValue boolValue];})

#define EKNMakeColorKnob(symbol, value, label) \
EKNMakeKnob(self, [EKNPropertyDescription colorPropertyWithName:EKNSymbolName(symbol)], symbol, label, value, value, ^(id owner, UIColor* color){symbol = color;})

#define EKNMakeContinuousSliderKnob(symbol, value, label, minimum, maximum) \
EKNMakeKnob(self, [EKNPropertyDescription continuousSliderPropertyWithName:EKNSymbolName(symbol) min:minimum max:maximum], symbol, label, value, @(value), ^(id owner, NSNumber* changedValue){symbol = [changedValue floatValue];})

#define EKNMakeStringKnob(symbol, value, label) \
EKNMakeKnob(self, [EKNPropertyDescription stringPropertyWithName:EKNSymbolName(symbol)], symbol, label, value, value, ^(id owner, NSString* changedValue){symbol = changedValue;})

#define EKNMakePointKnob(symbol, value, label) \
EKNMakeKnob(self, [EKNPropertyDescription pointPropertyWithName:EKNSymbolName(symbol)], symbol, label, value, [NSValue valueWithCGPoint:value], ^(id owner, NSValue* changedValue) {symbol = [changedValue CGPointValue];})

#define EKNMakeSizeKnob(symbol, value, label) \
EKNMakeKnob(self, [EKNPropertyDescription pointPropertyWithName:EKNSymbolName(symbol)], symbol, label, value, [NSValue valueWithCGSize:value], ^(id owner, NSValue* changedValue) {symbol = [changedValue CGSizeValue];})

#define EKNMakeRectKnob(symbol, value, label) \
EKNMakeKnob(self, [EKNPropertyDescription rectPropertyWithName:EKNSymbolName(symbol)], symbol, label, value, [NSValue valueWithCGRect:value], ^(id owner, NSValue* value) {symbol = [value CGRectValue];})

#define EKNMakeEdgeInsetsKnob(symbol, value, label) \
EKNMakeKnob(self, [EKNPropertyDescription edgeInsetsPropertyWithName:EKNSymbolName(symbol)], symbol, label, value, [NSValue valueWithUIEdgeInsets:value], ^(id owner, NSValue* changedValue) {symbol = [changedValue UIEdgeInsetsValue];})

#define EKNMakeAffineTransformKnob(symbol, value, label) \
EKNMakeKnob(self, [EKNPropertyDescription affineTransformPropertyWithName:EKNSymbolName(symbol)], symbol, label, value, [NSValue valueWithCGAffineTransform:value], ^(id owner, NSValue* changedValue) {symbol = [changedValue CGAffineTransformValue];})


/// Simple interface for an owner to receive updates when a knob is changed
@protocol EKNLiveKnobsCallback

/// Will be called on the owner when a knob is updated
- (void)ekn_knobChangedNamed:(NSString*)label withDescription:(EKNPropertyDescription*)description toValue:(id)value;

@end

/// Implementation calls [self setNeedsLayout]
@interface UIView (EKNLiveKnobsCallback) <EKNLiveKnobsCallback>
@end


/// Implementation calls [self.view setNeedsLayout]
@interface UIViewController (EKNLiveKnobsCallback) <EKNLiveKnobsCallback>
@end
