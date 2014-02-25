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

- (UIColor*)ekn_transportValue {
    return self;
}

+ (UIColor*)ekn_unwrapTransportValue:(UIColor*)value {
    return value;
}

@end

@implementation NSString (EKNProperty)

+ (EKNPropertyDescription*)ekn_propertyDescriptionWithName:(NSString *)name {
    return [EKNPropertyDescription stringPropertyWithName:name];
}

- (NSString*)ekn_transportValue {
    return self;
}

+ (NSString*)ekn_unwrapTransportValue:(NSString*)value {
    return value;
}

@end

@implementation UIImage (EKNProperty)

+ (EKNPropertyDescription*)ekn_propertyDescriptionWithName:(NSString *)name {
    return [EKNPropertyDescription imagePropertyWithName:name];
}

- (UIImage*)ekn_transportValue {
    return self;
}

+ (UIImage*)ekn_unwrapTransportValue:(UIImage*)value {
    return value;
}

@end

