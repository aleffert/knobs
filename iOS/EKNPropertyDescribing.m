//
//  EKNPropertyDescribing.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 2/23/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescribing.h"

@implementation UIColor (EKNProperty)

+ (EKNPropertyDescription*)ekn_propertyDescriptionWithName:(NSString *)name {
    return [EKNPropertyDescription colorPropertyWithName:name];
}

@end

@implementation NSString (EKNProperty)

+ (EKNPropertyDescription*)ekn_propertyDescriptionWithName:(NSString *)name {
    return [EKNPropertyDescription stringPropertyWithName:name];
}

@end

@implementation UIImage (EKNProperty)

+ (EKNPropertyDescription*)ekn_propertyDescriptionWithName:(NSString *)name {
    return [EKNPropertyDescription imagePropertyWithName:name];
}

@end

