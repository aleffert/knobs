//
//  NSValue+EKNAffineTransform.h
//  Knobs
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSValue (EKNAffineTransform)

// This is curiously missing from AppKit.
// Hopefully it will make its way into the standard library at some point
// so definitely use a prefix
+ (NSValue*)ekn_valueWithCGAffineTransform:(CGAffineTransform)transform;
- (CGAffineTransform)ekn_CGAffineTransformValue;

@end