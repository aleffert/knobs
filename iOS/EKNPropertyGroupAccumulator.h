//
//  EKNPropertyGroupAccumulator.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 12/22/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIView+EKNFrobInfo.h"

@interface EKNPropertyGroupAccumulator : NSObject <EKNViewFrobPropertyContext>

/// Enumerates the currently accumulated groups.
/// The second argument to the enumerator is an EKNPropertyDescription* array
- (void)enumerateGroups:(void(^)(NSString* groupName, NSArray* properties))enumerator;

@end
