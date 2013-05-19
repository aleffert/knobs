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

@end