//
//  NSValue+EKNAffineTransform.m
//  Knobs
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "NSValue+EKNAffineTransform.h"

@implementation NSValue (EKNAffineTransform)

+ (NSValue*)ekn_valueWithCGAffineTransform:(CGAffineTransform)transform {
    return [NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)];
}

- (CGAffineTransform)ekn_CGAffineTransformValue {
    CGAffineTransform result;
    [self getValue:&result];
    return result;
}

@end
