//
//  EKNPropertyDescription.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription.h"

NSString* EKNPropertyTypeColor = @"color";
NSString* EKNPropertyTypeToggle = @"toggle";
NSString* EKNPropertyTypeSlider = @"slider";

@interface EKNPropertyDescription ()

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSDictionary* parameters;

@end

@implementation EKNPropertyDescription

+ (EKNPropertyDescription*)propertyWithName:(NSString*)name type:(NSString*)type parameters:(NSDictionary*)parameters {
    EKNPropertyDescription* result = [[EKNPropertyDescription alloc] init];
    result.name = name;
    result.type = type;
    result.parameters = parameters;
    return result;
}

+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeColor parameters:@{}];
}

+ (EKNPropertyDescription*)togglePropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeToggle parameters:@{}];
}

+ (EKNPropertyDescription*)continuousSliderPropertyWithName:(NSString*)name min:(CGFloat)min max:(CGFloat)max {
    return [self propertyWithName:name type:EKNPropertyTypeSlider parameters:@{@(EKNPropertySliderMin): @(min),@(EKNPropertySliderMax) : @(max), @(EKNPropertySliderContinuous) : @YES}];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self != nil) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.parameters = [aDecoder decodeObjectForKey:@"parameters"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.parameters forKey:@"parameters"];
}

- (id)getValueFromSource:(id)source {
    id result = [source valueForKeyPath:self.name];
    if(result == nil) {
        return [NSNull null];
    }
    else {
        return result;
    }
}

- (void)setValue:(id)value ofSource:(id)source {
    [source setValue:value forKeyPath:self.name];
}


- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p name = %@, type = %@, parameters = %@> ", [self class], self, self.name, self.type, self.parameters];
}

@end
