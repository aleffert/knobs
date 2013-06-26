//
//  EKNPropertyDescription.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription.h"

#import "EKNWireImage.h"

NSString* EKNPropertyTypeColor = @"color";
NSString* EKNPropertyTypeToggle = @"toggle";
NSString* EKNPropertyTypeSlider = @"slider";
NSString* EKNPropertyTypeImage = @"image";
NSString* EKNPropertyTypeFloatQuad = @"floatQuad";
NSString* EKNPropertyTypeFloatPair = @"floatPair";
NSString* EKNPropertyTypeAffineTransform = @"affineTransform";

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
    return [self propertyWithName:name type:EKNPropertyTypeFloatQuad parameters:@{@(EKNPropertyFloatQuadFieldNames) : @[@"x", @"y", @"width", @"height"]}];
}

+ (EKNPropertyDescription*)edgeInsetsPropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeFloatQuad parameters:@{@(EKNPropertyFloatQuadFieldNames) : @[@"top", @"left", @"bottom", @"right"]}];
}

+ (EKNPropertyDescription*)pointPropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeFloatPair parameters:@{@(EKNPropertyFloatPairFieldNames) : @[@"x", @"y"]}];
}

+ (EKNPropertyDescription*)sizePropertyWithName:(NSString *)name {
    return [self propertyWithName:name type:EKNPropertyTypeFloatPair parameters:@{@(EKNPropertyFloatPairFieldNames) : @[@"width", @"height"]}];
}

+ (EKNPropertyDescription*)affineTransformPropertyWithName:(NSString*)name {
    return [self propertyWithName:name type:EKNPropertyTypeAffineTransform parameters:@{}];
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

- (id)wrappedValueFromSource:(id)source {
    id result = [source valueForKeyPath:self.name];
    if(result == nil) {
        return [NSNull null];
    }
    else {
        if([self.type isEqualToString:EKNPropertyTypeColor]) {
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
        else if([self.type isEqualToString:EKNPropertyTypeImage]) {
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
    if([self.type isEqualToString:EKNPropertyTypeColor] && [[self.parameters objectForKey:@(EKNPropertyColorWrapCG)] boolValue]) {
        return (id)[wrappedValue CGColor];
    }
    else if([self.type isEqualToString:EKNPropertyTypeImage]) {
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

- (void)setWrappedValue:(id)wrappedValue ofSource:(id)source {
    id value = [self valueWithWrappedValue:wrappedValue];
    [source setValue:value forKeyPath:self.name];
}


- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p name = %@, type = %@, parameters = %@> ", [self class], self, self.name, self.type, self.parameters];
}

@end
