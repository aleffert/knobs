//
//  NSArray+EKNFunctional.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (EKNFunctional)

/// Automatically filters out nil objects 
- (NSArray*)map:(id(^)(id o))f;
- (NSArray*)filter:(BOOL(^)(id o))f;
- (NSArray*)filterWithIndex:(BOOL(^)(id o, NSUInteger index))f;

- (NSArray*)arrayByInsertingObject:(id)object atIndex:(NSUInteger)index;
- (NSArray*)arrayByReplacingObjectAtIndex:(NSUInteger)index withObject:(id)object;

- (CGFloat)componentsSummedAsFloats;

@end
