//
//  EKNGroupTransporting.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 2/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNPropertyDescribing.h"

/// You can use these to control how group objects are transmitted over the wire
/// By default, it will objects by creating a dictionary of properties read off of the property description
/// And unwrap properties by calling init on the class, then valueForKey: for each property
@protocol EKNGroupTransporting <EKNPropertyDescribing>

/// Returns a value that can be transported between client and app
/// That is, this should be a value that can be archived/unarchived on the Mac and iOS
/// For types that return a property description with a group type
- (id <NSCoding>)ekn_transportValue;

/// Inverse of ekn_transportValue
+ (id)ekn_unwrapTransportValue:(id)value;


@end
