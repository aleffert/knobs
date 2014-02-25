//
//  EKNKnobInfo.h
//  Knobs
//
//  Created by Akiva Leffert on 5/19/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNPropertyDescription;

@interface EKNKnobInfo : NSObject <NSCoding>

+ (EKNKnobInfo*)knob;

/// Current value of the knob
@property (strong, nonatomic) id value;
/// Description of the knob
@property (strong, nonatomic) EKNPropertyDescription* propertyDescription;
/// Unique ID for a knob
@property (strong, nonatomic) NSString* knobID;
/// sourcePath can be nil, indicating the source path is unknown
@property (strong, nonatomic) NSString* sourcePath;
/// user visible string to display with the knob. Optional
/// The propertyDescription.name property needs to be unique within a given source file
/// So this is the right way to customize the display
@property (strong, nonatomic) NSString* label;
/// Code string to use when another knob takes the value of this knob
/// Can be nil, in which case we use code for the value of this knob
/// Used to make things point at symbolic constants instead of raw values
@property (strong, nonatomic) NSString* externalCode;
/// If the knob represents a group, then
@property (strong, nonatomic) NSArray* children;
/// The name to use when displaying the name of this knob.
/// Just the .label property, or if that's nil, the propertyDescription's name
@property (readonly, strong, nonatomic) NSString* displayName;
/// Used by derived knobs to point at the root of the group
/// For the base instances this is just the knob itself
/// Using this will always you get to the root of the hierarchy
@property (readonly, weak, nonatomic) EKNKnobInfo* rootKnob;

- (void)updateValueAfterChildChange;
- (void)updateChildrenAfterValueChange;

@end

@interface EKNRootDerivedKnobInfo : EKNKnobInfo

@property (weak, nonatomic) EKNKnobInfo* rootKnob;
@property (copy, nonatomic) NSString* parentKeyPath;

@end