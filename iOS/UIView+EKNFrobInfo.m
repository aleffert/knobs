//
//  UIView+EKNFrobInfo.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/16/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "UIView+EKNFrobInfo.h"

@implementation UIView (EKNFrobInfo)

- (NSDictionary*)frobInfo {
    NSMutableArray* children = [NSMutableArray array];
    for(UIView* child in self.subviews) {
        [children addObject:[NSString stringWithFormat:@"%p", child]];
    }
    return @{@"class": NSStringFromClass([self class]),
             @"pointer" : [NSString stringWithFormat:@"%p", self],
             @"children" : children
             };
}

@end
