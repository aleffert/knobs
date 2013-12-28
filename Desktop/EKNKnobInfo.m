//
//  EKNKnobInfo.m
//  Knobs
//
//  Created by Akiva Leffert on 5/19/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobInfo.h"

#import "EKNPropertyDescription.h"

@implementation EKNKnobInfo

+ (EKNKnobInfo*)knob {
    return [[EKNKnobInfo alloc] init];
}

- (NSString*)displayName {
    return self.label ?: self.propertyDescription.name;
}

@end