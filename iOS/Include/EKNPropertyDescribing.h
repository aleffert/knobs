//
//  EKNPropertyDescribing.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 2/23/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNPropertyDescription.h"

/// Protocol to return a property description from an arbitrary class
/// Typically this will be used to return a group property for some sort of
/// Custom aggregate type
@protocol EKNPropertyDescribing <NSObject>

+ (EKNPropertyDescription*)ekn_propertyDescriptionWithName:(NSString*)name;
/// Returns a value that can be transported between client and app
/// That is, this should be a value that can be archived/unarchived on the Mac and iOS
/// For types that return a property description with a group type, it should be an NSDictionary
- (id <NSCoding>)ekn_transportValue;
+ (id)ekn_unwrapTransportValue:(id)value;

@end

/// Default implemenations for base types
@interface UIColor (EKNProperty) <EKNPropertyDescribing>

@end

@interface NSString (EKNProperty) <EKNPropertyDescribing>

@end

@interface UIImage (EKNProperty) <EKNPropertyDescribing>

@end