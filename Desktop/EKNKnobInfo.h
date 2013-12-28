//
//  EKNKnobInfo.h
//  Knobs
//
//  Created by Akiva Leffert on 5/19/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNPropertyDescription;

@interface EKNKnobInfo : NSObject

+ (EKNKnobInfo*)knob;

@property (strong, nonatomic) id value;
@property (strong, nonatomic) EKNPropertyDescription* propertyDescription;
@property (strong, nonatomic) NSString* knobID;
/// sourcePath can be nil, indicating the source path is unknown
@property (strong, nonatomic) NSString* sourcePath;
/// user visible string to display with the knob. Optional
/// The propertyDescription.name property needs to be unique within a given source file
/// So this is the right way to customize the display
@property (strong, nonatomic) NSString* label;

@end