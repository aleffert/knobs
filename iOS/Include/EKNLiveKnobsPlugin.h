//
//  EKNLiveKnobsPlugin.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNDevicePlugin.h"

#import "EKNGroupTransporting.h"
#import "EKNPropertyDescription.h"
#import "EKNPropertyDescribing.h"

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

NSString* EKNDescriptionFromSymbol(NSString* symbol);

/// @discussion Convert a bit of code into a string
#define EKNStringify(symbol) @"" #symbol

#define EKNCodify(codeString) ([(@"" codeString) isEqualToString:@"nil"] ? nil : @"" codeString)
#if DEBUG
/// @discussion Helper macro for creating a knob pointing to the current file
#define EKNMakeKnob(owner, propertyDescription, symbol, labelText, wrappedValue, externalCodeText, action) ({\
[[EKNLiveKnobsPlugin sharedPlugin] \
registerOwner:owner \
info:propertyDescription \
label:labelText \
currentValue:wrappedValue \
externalCode:externalCodeText \
sourcePath:@""__FILE__ \
callback:^(id innerOwner, id changedValue) { \
action(innerOwner, changedValue); \
if([innerOwner respondsToSelector:@selector(ekn_knobChangedNamed:withDescription:toValue:)]) { \
[innerOwner ekn_knobChangedNamed:labelText withDescription:propertyDescription toValue:changedValue];\
} \
}]; \
})
#else
#define EKNMakeKnob(owner, propertyDescription, symbol, labelText, wrappedValue, externalCodeText, action) 0
#endif

/// @param klass The class of the object. Must conform to <EKNPropertyDescribing>
#define EKNMakeObjectKnobWithOptions(klass, symbol, label, externalCode) \
EKNMakeKnob(self, [klass ekn_propertyDescriptionWithName:EKNStringify(symbol)], symbol, label, symbol, EKNCodify(#externalCode), ^(id owner, klass* changedValue){symbol = changedValue;})
/// @param klass The class of the object. Must conform to <EKNPropertyDescribing>
#define EKNMakeObjectKnob(klass, symbol) \
EKNMakeObjectKnobWithOptions(klass, symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakeAffineTransformKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription affineTransformPropertyWithName:EKNStringify(symbol)], symbol, label, [NSValue valueWithCGAffineTransform:symbol], EKNCodify(#externalCode), ^(id owner, NSValue* changedValue) { \
symbol = [changedValue CGAffineTransformValue]; \
})
#define EKNMakeAffineTransformKnob(symbol) \
EKNMakeAffineTransformKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakeColorKnobWithOptions(symbol, label, externalCode) \
EKNMakeObjectKnobWithOptions(UIColor, symbol, label, externalCode)
#define EKNMakeColorKnob(symbol) \
EKNMakeObjectKnob(UIColor, symbol)

#define EKNMakeContinuousSliderKnobWithOptions(symbol, label, externalCode, minimum, maximum) \
EKNMakeKnob(self, [EKNPropertyDescription continuousSliderPropertyWithName:EKNStringify(symbol) min:minimum max:maximum], symbol, label, @(symbol), EKNCodify(#externalCode), ^(id owner, NSNumber* changedValue){symbol = [changedValue floatValue];})
#define EKNMakeContinuousSliderKnob(symbol, minimum, maximum) \
EKNMakeContinuousSliderKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil, minimum, maximum)

#define EKNMakeEdgeInsetsKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription edgeInsetsPropertyWithName:EKNStringify(symbol)], symbol, label, [NSValue valueWithUIEdgeInsets:symbol], EKNCodify(#externalCode), ^(id owner, NSValue* changedValue) {symbol = [changedValue UIEdgeInsetsValue];})
#define EKNMakeEdgeInsetsKnob(symbol) \
EKNMakeEdgeInsetsKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakeFloatKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription floatPropertyWithName:EKNStringify(symbol)], symbol, label, @(symbol), EKNCodify(#externalCode), ^(id owner, NSNumber* changedValue){symbol = [changedValue floatValue];})
#define EKNMakeFloatKnob(symbol) \
EKNMakeFloatKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakeIntKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription intPropertyWithName:EKNStringify(symbol)], symbol, label, @(symbol), EKNCodify(#externalCode), ^(id owner, NSNumber* changedValue){symbol = [changedValue integerValue];})
#define EKNMakeIntKnob(symbol) \
EKNMakeIntKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakePointKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription pointPropertyWithName:EKNStringify(symbol)], symbol, label, [NSValue valueWithCGPoint:symbol], EKNCodify(#externalCode), ^(id owner, NSValue* changedValue) {symbol = [changedValue CGPointValue];})
#define EKNMakePointKnob(symbol) \
EKNMakePointKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakeRectKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription rectPropertyWithName:EKNStringify(symbol)], symbol, label, [NSValue valueWithCGRect:symbol], EKNCodify(#externalCode), ^(id owner, NSValue* value) {symbol = [value CGRectValue];})
#define EKNMakeRectKnob(symbol) \
EKNMakeRectKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakeSizeKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription sizePropertyWithName:EKNStringify(symbol)], symbol, label, [NSValue valueWithCGSize:symbol], EKNCodify(#externalCode), ^(id owner, NSValue* changedValue) {symbol = [changedValue CGSizeValue];})
#define EKNMakeSizeKnob(symbol) \
EKNMakeSizeKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakeStringKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription stringPropertyWithName:EKNStringify(symbol)], symbol, label, symbol, EKNCodify(#externalCode), ^(id owner, NSString* changedValue){symbol = changedValue;})
#define EKNMakeStringKnob(symbol) \
EKNMakeStringKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakeToggleKnobWithOptions(symbol, label, externalCode) \
EKNMakeKnob(self, [EKNPropertyDescription togglePropertyWithName:EKNStringify(symbol)], symbol, label, @(symbol), EKNCodify(#externalCode), ^(id owner, NSNumber* changedValue){symbol = [changedValue boolValue];})
#define EKNMakeToggleKnob(symbol) \
EKNMakeToggleKnobWithOptions(symbol, EKNDescriptionFromSymbol(EKNStringify(symbol)), nil)

#define EKNMakePushButtonKnob(label, action) \
[[EKNLiveKnobsPlugin sharedPlugin] registerPushButtonWithOwner:self name:label callback:action]


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
