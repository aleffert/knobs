//
//  EKNPropertyDescription+EKNCodeConstruction.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription.h"

@interface EKNPropertyDescription (EKNCodeConstruction)

- (NSString*)constructorCodeForValue:(id)value;

@end
