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

@end

@interface UIColor (EKNDescription) <EKNPropertyDescribing>

@end

@interface NSString (EKNDescription) <EKNPropertyDescribing>

@end

@interface UIImage (EKNDescription) <EKNPropertyDescribing>

@end

