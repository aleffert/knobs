//
//  EKNPropertyDescription+EKNCodeConstruction.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription.h"

@interface EKNPropertyDescription (EKNCodeConstruction)

/// Returns Objective-C code that constructs the given value
- (NSString*)constructorCodeForValue:(id)value;

/// Can generate code of this type
@property (readonly, nonatomic, assign) BOOL supportsCodeConstruction;

@end
