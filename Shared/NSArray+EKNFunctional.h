//
//  NSArray+EKNFunctional.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (EKNFunctional)

// Automatically filters out calls that return nil
- (NSArray*)map:(id(^)(id o))f;
- (NSArray*)filter:(BOOL(^)(id o))f;

@end
