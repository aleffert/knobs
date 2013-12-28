//
//  EKNPropertyDescription.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription.h"

#import "EKNWireImage.h"

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

+ (EKNPropertyDescription*)pushButtonPropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypePushButton parameters:@{}];
}

+ (EKNPropertyDescription*)stringPropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeString parameters:@{}];
}

+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name {
    return [self colorPropertyWithName:name wrapCG:NO];
}

+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG {
    return [self propertyWithName:name type:EKNPropertyTypeColor parameters:@{@(EKNPropertyColorWrapCG) : @(wrapCG)}];
}

+ (EKNPropertyDescription*)imagePropertyWithName:(NSString*)name {
    return [self imagePropertyWithName:name wrapCG:NO];
}

+ (EKNPropertyDescription*)imagePropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG {
    return [self propertyWithName:name type:EKNPropertyTypeImage parameters:@{@(EKNPropertyImageWrapCG) : @(wrapCG)}];
}

+ (EKNPropertyDescription*)togglePropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeToggle parameters:@{}];
}

+ (EKNPropertyDescription*)continuousSliderPropertyWithName:(NSString*)name min:(CGFloat)min max:(CGFloat)max {
    return [self propertyWithName:name type:EKNPropertyTypeSlider parameters:@{@(EKNPropertySliderMin): @(min),@(EKNPropertySliderMax) : @(max), @(EKNPropertySliderContinuous) : @YES}];
}

+ (EKNPropertyDescription*)rectPropertyWithName:(NSString *)name {
    return [self propertyWithName:name
                             type:EKNPropertyTypeFloatQuad
                       parameters:@{
                                    @(EKNPropertyFloatQuadFieldNames) : @[@"x", @"y", @"width", @"height"], @(EKNPropertyFloatQuadKeyOrder) : @(EKNFloatQuadKeyOrderRect), @(EKNPropertyFloatQuadConstructorPrefix) : @"CGRectMake"
                                    }];
}

+ (EKNPropertyDescription*)edgeInsetsPropertyWithName:(NSString*)name {
    return [self propertyWithName:name
                             type:EKNPropertyTypeFloatQuad
                       parameters:@{
                                    @(EKNPropertyFloatQuadFieldNames) : @[@"top", @"left", @"bottom", @"right"], @(EKNPropertyFloatQuadKeyOrder) : @(EKNFloatQuadKeyOrderEdgeInsets), @(EKNPropertyFloatQuadConstructorPrefix) : @"UIEdgeInsetsMake"
                                    }];
}

+ (EKNPropertyDescription*)pointPropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeFloatPair parameters:@{@(EKNPropertyFloatPairFieldNames) : @[@"x", @"y"], @(EKNPropertyFloatPairConstructorPrefix) : @"CGPointMake"}];
}

+ (EKNPropertyDescription*)sizePropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeFloatPair parameters:@{@(EKNPropertyFloatPairFieldNames) : @[@"width", @"height"], @(EKNPropertyFloatPairConstructorPrefix) : @"CGSizeMake"}];
}

+ (EKNPropertyDescription*)affineTransformPropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeAffineTransform parameters:@{}];
}

+ (NSString*)nameForType:(EKNPropertyType)type {
    switch (type) {
        case EKNPropertyTypeAffineTransform: return @"EKNPropertyTypeAffineTransform";
        case EKNPropertyTypeColor: return @"EKNPropertyTypeColor";
        case EKNPropertyTypeFloatPair: return @"EKNPropertyTypeFloatPair";
        case EKNPropertyTypeFloatQuad: return @"EKNPropertyTypeFloatQuad";
        case EKNPropertyTypeImage: return @"EKPropertyTypeImage";
        case EKNPropertyTypePushButton: return @"EKNPropertyTypePushButton";
        case EKNPropertyTypeSlider: return @"EKNPropertyTypeSlider";
        case EKNPropertyTypeString: return @"EKNPropertyTypeString";
        case EKNPropertyTypeToggle: return @"EKNPropertyTypeToggle";
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

- (id)wrappedValueFromSource:(id)source {
    id result = [source valueForKeyPath:self.name];
    if(result == nil) {
        return [NSNull null];
    }
    else {
        if(self.type == EKNPropertyTypeColor) {
#if TARGET_OS_IPHONE
            if([[self.parameters objectForKey:@(EKNPropertyColorWrapCG)] boolValue]) {
                result = [UIColor colorWithCGColor:(CGColorRef)result];
            }
            CGColorSpaceRef space = CGColorGetColorSpace([result CGColor]);
            CGColorSpaceModel model = CGColorSpaceGetModel(space);
            // UIColor only supports archiving of RGB and White colors. So just ignore if we're not using one of those
            if(!(model == kCGColorSpaceModelCMYK || model == kCGColorSpaceModelRGB)) {
                result = [NSNull null];
            }
#else
            result = [NSColor colorWithCGColor:(CGColorRef)result];
#endif
        }
        else if(self.type == EKNPropertyTypeImage) {
            if([[self.parameters objectForKey:@(EKNPropertyImageWrapCG)] boolValue]) {
#if TARGET_OS_IPHONE
                result = [[EKNWireImage alloc] initWithImage:[[UIImage alloc] initWithCGImage:(CGImageRef)result]];
#else
                CGImageRef image = (__bridge CGImageRef)result;
                NSSize size = NSMakeSize(CGImageGetWidth(image), CGImageGetHeight(image));
                result = [[EKNWireImage alloc] initWithImage:[[NSImage alloc] initWithCGImage:image size:size]];
#endif
            }
            else {
#if TARGET_OS_IPHONE
                result = [[EKNWireImage alloc] initWithImage:result];
#else
                result = [[EKNWireImage alloc] initWithImage:result];
#endif
            }
        }
        
        return result;
    }
}

- (id)valueWithWrappedValue:(id)wrappedValue {
    if(self.type == EKNPropertyTypeColor && [[self.parameters objectForKey:@(EKNPropertyColorWrapCG)] boolValue]) {
        return (id)[wrappedValue CGColor];
    }
    else if(self.type == EKNPropertyTypeImage) {
        if([wrappedValue isEqual:[NSNull null]]) {
            return nil;
        }
        else if([[self.parameters objectForKey:@(EKNPropertyImageWrapCG)] boolValue]) {
            return (id)[wrappedValue CGImage];
        }
        else {
            return [wrappedValue image];
        }
    }
    else {
        return wrappedValue;
    }

}

- (void)setWrappedValue:(id)wrappedValue onSource:(id)source {
    id value = [self valueWithWrappedValue:wrappedValue];
    [source setValue:value forKeyPath:self.name];
}


- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p name = %@, type = %@, parameters = %@> ", [self class], self, self.name, self.typeName, self.parameters];
}

@end
