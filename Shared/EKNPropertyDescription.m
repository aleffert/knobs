//
//  EKNPropertyDescription.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription.h"

@interface EKNPropertyDescription ()

@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) EKNPropertyType type;
@property (nonatomic, copy) NSDictionary* parameters;

@end

@implementation EKNPropertyDescription

+ (EKNPropertyDescription*)propertyWithName:(NSString*)name type:(EKNPropertyType)type parameters:(NSDictionary*)parameters {
    EKNPropertyDescription* result = [[EKNPropertyDescription alloc] init];
    result.name = name;
    result.type = type;
    result.parameters = parameters;
    return result;
}

+ (EKNPropertyDescription*)groupPropertyWithName:(NSString *)name properties:(NSArray *)properties {
    return [self propertyWithName:name type:EKNPropertyTypeGroup parameters:@{@(EKNPropertyGroupChildren) : properties}];
}

+ (EKNPropertyDescription*)affineTransformPropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeAffineTransform parameters:@{}];
}

+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name {
    return [self colorPropertyWithName:name wrapCG:NO];
}

+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG {
    return [self propertyWithName:name type:EKNPropertyTypeColor parameters:@{@(EKNPropertyColorWrapCG) : @(wrapCG)}];
}

+ (EKNPropertyDescription*)continuousSliderPropertyWithName:(NSString*)name min:(CGFloat)min max:(CGFloat)max {
    return [self propertyWithName:name type:EKNPropertyTypeSlider parameters:@{@(EKNPropertySliderMin): @(min),@(EKNPropertySliderMax) : @(max), @(EKNPropertySliderContinuous) : @YES}];
}

+ (EKNPropertyDescription*)edgeInsetsPropertyWithName:(NSString*)name {
    return [self propertyWithName:name
                             type:EKNPropertyTypeFloatQuad
                       parameters:@{
                                    @(EKNPropertyFloatQuadFieldNames) : @[@"top", @"left", @"bottom", @"right"], @(EKNPropertyFloatQuadKeyOrder) : @(EKNFloatQuadKeyOrderEdgeInsets), @(EKNPropertyFloatQuadConstructorPrefix) : @"UIEdgeInsetsMake"
                                    }];
}

+ (EKNPropertyDescription*)floatPropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeFloat parameters:@{}];
}

+ (EKNPropertyDescription*)imagePropertyWithName:(NSString*)name {
    return [self imagePropertyWithName:name wrapCG:NO];
}

+ (EKNPropertyDescription*)imagePropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG {
    return [self propertyWithName:name type:EKNPropertyTypeImage parameters:@{@(EKNPropertyImageWrapCG) : @(wrapCG)}];
}

+ (EKNPropertyDescription*)intPropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeInt parameters:@{}];
}

+ (EKNPropertyDescription*)pointPropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeFloatPair parameters:@{@(EKNPropertyFloatPairFieldNames) : @[@"x", @"y"], @(EKNPropertyFloatPairConstructorPrefix) : @"CGPointMake"}];
}

+ (EKNPropertyDescription*)pushButtonPropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypePushButton parameters:@{}];
}

+ (EKNPropertyDescription*)rectPropertyWithName:(NSString *)name {
    return [self propertyWithName:name
                             type:EKNPropertyTypeFloatQuad
                       parameters:@{
                                    @(EKNPropertyFloatQuadFieldNames) : @[@"x", @"y", @"width", @"height"], @(EKNPropertyFloatQuadKeyOrder) : @(EKNFloatQuadKeyOrderRect), @(EKNPropertyFloatQuadConstructorPrefix) : @"CGRectMake"
                                    }];
}

+ (EKNPropertyDescription*)sizePropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeFloatPair parameters:@{@(EKNPropertyFloatPairFieldNames) : @[@"width", @"height"], @(EKNPropertyFloatPairConstructorPrefix) : @"CGSizeMake"}];
}

+ (EKNPropertyDescription*)stringPropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeString parameters:@{}];
}

+ (EKNPropertyDescription*)togglePropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeToggle parameters:@{}];
}

#define EKNNameForTypeArm(name) case name: return @"" #name;
+ (NSString*)nameForType:(EKNPropertyType)type {
    switch (type) {
            EKNNameForTypeArm(EKNPropertyTypeGroup);
            EKNNameForTypeArm(EKNPropertyTypeAffineTransform);
            EKNNameForTypeArm(EKNPropertyTypeColor);
            EKNNameForTypeArm(EKNPropertyTypeFloat);
            EKNNameForTypeArm(EKNPropertyTypeFloatPair);
            EKNNameForTypeArm(EKNPropertyTypeFloatQuad);
            EKNNameForTypeArm(EKNPropertyTypeImage);
            EKNNameForTypeArm(EKNPropertyTypeInt);
            EKNNameForTypeArm(EKNPropertyTypePushButton);
            EKNNameForTypeArm(EKNPropertyTypeSlider);
            EKNNameForTypeArm(EKNPropertyTypeString);
            EKNNameForTypeArm(EKNPropertyTypeToggle);
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self != nil) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.parameters = [aDecoder decodeObjectForKey:@"parameters"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.parameters forKey:@"parameters"];
}

- (NSString*)typeName {
    return [EKNPropertyDescription nameForType:self.type];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p name = %@, type = %@, parameters = %@> ", [self class], self, self.name, self.typeName, self.parameters];
}

- (BOOL)isTypeEquivalentToTypeOfDescription:(EKNPropertyDescription*)description {
    if(description == nil) {
        return NO;
    }
    switch (self.type) {
        case EKNPropertyTypeGroup: {
            if(description.type == EKNPropertyTypeGroup) {
                NSArray* children = self.parameters[@(EKNPropertyGroupChildren)];
                NSArray* compChildren = description.parameters[@(EKNPropertyGroupChildren)];
                if(children.count != compChildren.count) {
                    return NO;
                }
                __block BOOL equivalent = YES;
                [children enumerateObjectsUsingBlock:^(EKNPropertyDescription* child, NSUInteger idx, BOOL *stop) {
                    EKNPropertyDescription* compChild = [compChildren objectAtIndex:idx];
                    equivalent = equivalent && [child isTypeEquivalentToTypeOfDescription:compChild];
                }];
                return equivalent;
            }
            else {
                return NO;
            }
        default:
            return self.type == description.type;
        }
    }
}

@end
    
