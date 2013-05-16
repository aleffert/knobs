//
//  NSArray+EKNFunctional.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "NSArray+EKNFunctional.h"

@implementation NSArray (EKNFunctional)

- (NSArray*)map:(id(^)(id o))f {
    NSMutableArray* result = [NSMutableArray array];
    for(id o in self) {
        id r = f(o);
        [result addObject:r];
    }
    return result;
}

- (NSArray*)filter:(BOOL(^)(id o))f {
    NSMutableArray* result = [NSMutableArray array];
    for(id o in self) {
        if(f(o)) {
            [result addObject:o];
        }
    }
    return result;
}

- (NSArray*)arrayByInsertingObject:(id)object atIndex:(NSUInteger)index {
    NSMutableArray* result = [self mutableCopy];
    [result insertObject:object atIndex:index];
    
    return result;
}


- (NSArray*)arrayByReplacingObjectAtIndex:(NSUInteger)index withObject:(id)object {
    NSMutableArray* result = [self mutableCopy];
    [result replaceObjectAtIndex:index withObject:object];
    return result;
}

@end
