//
//  EKNPropertyDescription+EKNCodeConstruction.m
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription+EKNCodeConstruction.h"

@implementation EKNPropertyDescription (EKNCodeConstruction)


- (NSString*)constructorCodeForAffineTransform:(NSValue*)value {
    CGAffineTransform transform;
    [value getValue:&transform];
    return [NSString stringWithFormat:@"CGAffineTransformMake(%.2f, %.2f, %.2f, %.2f, %.2f, %2.f)", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty];
}

- (NSString*)constructorCodeForColor:(NSColor*)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"[UIColor colorWithRed:%.2f green:%.2f blue:%.2f alpha:%.2f]", r, g, b, a];
}

- (NSString*)constructorCodeForFloat:(NSNumber*)floatValue {
    return [NSString stringWithFormat:@"%.2f", [floatValue floatValue]];
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

- (NSString*)constructorCodeForInt:(NSNumber*)intValue {
    return [NSString stringWithFormat:@"%ld", [intValue integerValue]];
}

- (NSString*)constructorCodeForSlider:(NSNumber*)value {
    return [NSString stringWithFormat:@"%.2f", value.floatValue];
}

- (NSString*)constructorCodeForToggle:(NSNumber*)toggle {
    return [toggle boolValue] ? @"YES" : @"NO";
}

- (NSString*)constructorCodeForString:(NSString*)string {
    NSMutableString *escapedString = [[NSMutableString alloc] init];
    for(NSUInteger i = 0; i < string.length; i++) {
        // Does this have issues with strings outside of UCS-2?
        unichar c = [string characterAtIndex:i];
        switch (c) {
            case '\\':
                [escapedString appendFormat:@"\\\\"];
                break;
            case '\n':
                [escapedString appendFormat:@"\\n"];
                break;
            case '\"':
                [escapedString appendFormat:@"\\\""];
                break;
            default:
                // TODO: There are probably more cases we need to cover here
                [escapedString appendFormat:@"%c", c];
                break;
        }
    }
    
    return [NSString stringWithFormat:@"@\"%@\"", [escapedString description]];
}

- (NSString*)constructorCodeForValue:(id)value {
    switch (self.type) {
        case EKNPropertyTypeAffineTransform: return [self constructorCodeForAffineTransform:value];
        case EKNPropertyTypeColor: return [self constructorCodeForColor:value];
        case EKNPropertyTypeFloat: return [self constructorCodeForFloat:value];
        case EKNPropertyTypeFloatPair: return [self constructorCodeForFloatPair:value];
        case EKNPropertyTypeFloatQuad: return [self constructorCodeForFloatQuad:value];
        case EKNPropertyTypeInt: return [self constructorCodeForInt:value];
        case EKNPropertyTypeToggle: return [self constructorCodeForToggle:value];
        case EKNPropertyTypeSlider: return [self constructorCodeForSlider:value];
        case EKNPropertyTypeString: return [self constructorCodeForString:value];
        case EKNPropertyTypeGroup:
        case EKNPropertyTypeImage:
        case EKNPropertyTypePushButton:
            NSAssert(NO, @"Attempting to construct code of type %@, which is not possible", self.typeName);
            return @"";
    }
}

- (BOOL)supportsCodeConstruction {
    switch (self.type) {
        case EKNPropertyTypeImage:
        case EKNPropertyTypePushButton:
        case EKNPropertyTypeGroup:
            return NO;
        default:
            return YES;
    }
    return self.type != EKNPropertyTypeImage && self.type != EKNPropertyTypePushButton;
}

@end
