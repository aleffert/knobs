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

/// @discussion Adds a new knob
/// @param owner The object owning the knob. When owner gets dealloced the knob will automatically be removed. Cannot be nil
/// @param label Displayed name of the knob. Should be unique per owner. Should be unique per file for live source updating to work properly.
/// @param currentValue The initial value of the knob
/// @param sourcePath Source file this knob resides in. Live source updating won't work unless you go through the EKNMake macros below.
/// @param externalCode Code that should be used by other knobs picking up the value of this one. Can be nil, in which case the value of the knob is used instead. Used to make things point at symbolic constants instead of raw values
/// @param callback Action called when the knob changes. May be nil
- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description label:(NSString*)label currentValue:(id)value externalCode:(NSString*)code sourcePath:(NSString*)path callback:(void(^)(id owner, id value))callback;

/// Convenience for calling -[EKNLiveKnobsPlugin registerOwner:info:label:currentValue:externalCode:sourcePath:callback] where externalCode and sourcePath are nil
- (void)registerOwner:(id)owner info:(EKNPropertyDescription*)description label:(NSString*)label currentValue:(id)value callback:(void(^)(id owner, id value))callback;

/// @description Registers a knob that is just a push button with the given name
/// @param owner The object owning the button. When owner gets dealloced the button will automatically be removed. Cannot be nil
/// @param callback The action to execute when the button is pushed
- (void)registerPushButtonWithOwner:(id)owner name:(NSString*)name callback:(void(^)(id owner))callback;

/// @discussion Notify the listener that the value changed. Optional, but will make ensure the UI matches the actual value
/// @param owner The owner of the knob
/// @param value The updated value
- (void)updateValueWithOwner:(id)owner name:(NSString*)name value:(id)value;

/// @discussion Remove a knob before owner gets dealloced
/// @param owner The owner of the knob. Pass nil to remove all knobs with that owner
- (void)removeKnobWithOwner:(id)owner name:(NSString*)name;

/// @discussion Begins a knob group with the given name
/// If a name is used multiple times, the knobs in those groups are merged
/// @param The name of the group
- (void)beginGroupWithName:(NSString*)groupName;

/// @discussion Ends the current named group
- (void)endGroup;

/// @discussion Creates a named group of knobs then executes the action closing the group at the end
/// Same as calling -beingGroupWithName:, executing action, and then -endGroup
/// @param groupName The name of the knob group to create
/// @param action A block that will be executed immediately
- (void)groupWithName:(NSString *)groupName action:(void(^)(void))action;

@end


/// @discussion Delimiter so our regex based parser can find the right place to update
/// Should be placed after the second argument to the EKNMake*Knob family of macros
/// For example to make a float knob for the self.x property with an initial value of 3,
/// You would do EKMakeFloatKnob(self.x, 3 EKNMarker, @"x", nil)
/// In an ideal world, we'd actually parse your code and figure this out ourselves
#define EKNMarker

/// @discussion Convert a bit of code into a string
#define EKNStringify(symbol) @"" #symbol

#define EKNCodify(codeString) ([(@"" codeString) isEqualToString:@"nil"] ? nil : @"" codeString)
#if DEBUG
/// @discussion Helper macro for creating a knob pointing to the current file
#define EKNMakeKnob(owner, propertyDescription, symbol, labelText, value, wrappedValue, externalCodeText, action) ({\
    [[EKNLiveKnobsPlugin sharedPlugin] \
            registerOwner:owner \
            info:propertyDescription \
            label:labelText \
            currentValue:wrappedValue \
            externalCode:externalCodeText \
            sourcePath:@""__FILE__ \
            callback:^(id innerOwner, id changedValue) { \
            if([innerOwner respondsToSelector:@selector(ekn_knobChangedNamed:withDescription:toValue:)]) { \
                [innerOwner ekn_knobChangedNamed:labelText withDescription:propertyDescription toValue:changedValue];\
            } \
            action(innerOwner, changedValue); \
        }]; \
    symbol = value; \
})
#else
#define EKNMakeKnob(owner, propertyDescription, symbol, labelText, value, wrappedValue, externalCodeText, action) (symbol) = (value)
#endif

#define EKNMakeAffineTransformKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription affineTransformPropertyWithName:EKNStringify(symbol)], symbol, label, value, EKNCodify(#externalCode), [NSValue valueWithCGAffineTransform:value], code, ^(id owner, NSValue* changedValue) {symbol = [changedValue CGAffineTransformValue];})

#define EKNMakeColorKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription colorPropertyWithName:EKNStringify(symbol)], symbol, label, value, value, EKNCodify(#externalCode), ^(id owner, UIColor* color){symbol = color;})

#define EKNMakeContinuousSliderKnob(symbol, value, label, externalCode, minimum, maximum) \
EKNMakeKnob(self, [EKNPropertyDescription continuousSliderPropertyWithName:EKNStringify(symbol) min:minimum max:maximum], symbol, label, value, @(value), EKNCodify(#externalCode), ^(id owner, NSNumber* changedValue){symbol = [changedValue floatValue];})

#define EKNMakeEdgeInsetsKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription edgeInsetsPropertyWithName:EKNStringify(symbol)], symbol, label, value, [NSValue valueWithUIEdgeInsets:value], EKNCodify(#externalCode), ^(id owner, NSValue* changedValue) {symbol = [changedValue UIEdgeInsetsValue];})

#define EKNMakeFloatKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription floatPropertyWithName:EKNStringify(symbol)], symbol, label, value, @(value), EKNCodify(#externalCode), ^(id owner, NSNumber* changedValue){symbol = [changedValue floatValue];})

#define EKNMakeIntKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription intPropertyWithName:EKNStringify(symbol)], symbol, label, value, @(value), EKNCodify(#externalCode), ^(id owner, NSNumber* changedValue){symbol = [changedValue integerValue];})

#define EKNMakePointKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription pointPropertyWithName:EKNStringify(symbol)], symbol, label, value, EKNCodify(#externalCode), [NSValue valueWithCGPoint:value], ^(id owner, NSValue* changedValue) {symbol = [changedValue CGPointValue];})

#define EKNMakePushButtonKnob(label, action) \
[[EKNLiveKnobsPlugin sharedPlugin] registerPushButtonWithOwner:self name:label callback:action]

#define EKNMakeRectKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription rectPropertyWithName:EKNStringify(symbol)], symbol, label, value, [NSValue valueWithCGRect:value], EKNCodify(#externalCode), ^(id owner, NSValue* value) {symbol = [value CGRectValue];})

#define EKNMakeSizeKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription sizePropertyWithName:EKNStringify(symbol)], symbol, label, value, [NSValue valueWithCGSize:value], EKNCodify(#externalCode), ^(id owner, NSValue* changedValue) {symbol = [changedValue CGSizeValue];})

#define EKNMakeStringKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription stringPropertyWithName:EKNStringify(symbol)], symbol, label, value, value, EKNCodify(#externalCode), ^(id owner, NSString* changedValue){symbol = changedValue;})

#define EKNMakeToggleKnob(symbol, value, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription togglePropertyWithName:EKNStringify(symbol)], symbol, label, value, @(value), EKNCodify(#externalCode), ^(id owner, NSValue* changedValue){symbol = [changedValue boolValue];})


/// Simple interface for an owner to receive updates when a knob is changed
@protocol EKNLiveKnobsCallback

/// Will be called on the owner when a knob is updated
- (void)ekn_knobChangedNamed:(NSString*)label withDescription:(EKNPropertyDescription*)description toValue:(id)value;

@end

/// Implementation calls [self setNeedsLayout] and attempts to do the same to its owning view controller if it has one
@interface UIView (EKNLiveKnobsCallback) <EKNLiveKnobsCallback>
@end


/// Implementation calls [self.view setNeedsLayout]
@interface UIViewController (EKNLiveKnobsCallback) <EKNLiveKnobsCallback>
@end
