//
//  EKNPropertyDescription+EKNCodeConstruction.m
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription+EKNCodeConstruction.h"

@implementation EKNPropertyDescription (EKNCodeConstruction)


- (NSString*)constructorCodeForColor:(NSColor*)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"[UIColor colorWithRed:%.2f green:%.2f blue:%.2f alpha:%.2f]", r, g, b, a];
}

- (NSString*)constructorCodeForSlider:(NSNumber*)value {
    return [NSString stringWithFormat:@"%.2f", value.floatValue];
}

- (NSString*)constructorCodeForFloatPair:(NSValue*)pair {
    NSString* prefix = self.parameters[@(EKNPropertyFloatPairConstructorPrefix)];
    CGPoint point;
    [pair getValue:&point];
    return [NSString stringWithFormat:@"%@(%.2f, %.2f)", prefix, point.x, point.y];
}

- (NSString*)constructorCodeForFloatQuad:(NSValue*)quad {
    NSString* prefix = self.parameters[@(EKNPropertyFloatQuadConstructorPrefix)];
    CGRect rect;
    [quad getValue:&rect];
    return [NSString stringWithFormat:@"%@(%.2f, %.2f, %.2f, %2.f)", prefix, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (NSString*)constructorCodeForAffineTransform:(NSValue*)value {
    CGAffineTransform transform;
    [value getValue:&transform];
    return [NSString stringWithFormat:@"CGAffineTransformMake(%.2f, %.2f, %.2f, %.2f, %.2f, %2.f)", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty];
}

- (NSString*)constructorCodeForToggle:(NSNumber*)toggle {
    return [toggle boolValue] ? @"YES" : @"NO";
}

- (NSString*)constructorCodeForValue:(id)value {
    switch (self.type) {
        case EKNPropertyTypeColor: return [self constructorCodeForColor:value];
        case EKNPropertyTypeFloatPair: return [self constructorCodeForFloatPair:value];
        case EKNPropertyTypeFloatQuad: return [self constructorCodeForFloatQuad:value];
        case EKNPropertyTypeToggle: return [self constructorCodeForToggle:value];
        case EKNPropertyTypeSlider: return [self constructorCodeForSlider:value];
        case EKNPropertyTypeString: return [self constructorCodeForAffineTransform:value];
        default:
            NSAssert(NO, @"Trying to construct unexpected type %@", self.typeName);
            return @"";
    }
}

- (BOOL)supportsCodeConstruction {
    return self.type != EKNPropertyTypeImage && self.type != EKNPropertyTypePushButton;
}

@end
