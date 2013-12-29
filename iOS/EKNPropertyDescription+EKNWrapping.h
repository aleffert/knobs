//
//  EKNPropertyDescription+EKNWrapping.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 12/29/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription.h"

@interface EKNPropertyDescription (EKNWrapping)

/// Converts property values to the right objective-c objects
/// Primarily used to wrap up CG values
/// Requires self's .name to be a keypath
- (id)wrappedValueFromSource:(id)source;

/// Unwraps the value and sets it on source
/// Requires self's .name to be a valid keypath for source
- (void)setWrappedValue:(id)wrapped onSource:(id)source;

/// Unwraps the value into its original type
- (id)valueWithWrappedValue:(id)wrappedValue;

@end
