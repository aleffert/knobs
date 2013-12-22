//
//  UIScrollView+EKNViewFrob.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "UIScrollView+EKNFrobInfo.h"

#import "EKNPropertyDescription.h"
#import "UIView+EKNFrobInfo.h"

@implementation UIScrollView (EKNViewFrobInfo)

- (void)frob_accumulatePropertiesInto:(id<EKNViewFrobPropertyContext>)context {
    [super frob_accumulatePropertiesInto:context];
    [context addGroup:@"UIScrollView" withProperties:
     @[
       [EKNPropertyDescription pointPropertyWithName:@"contentOffset"],
       [EKNPropertyDescription sizePropertyWithName:@"contentSize"],
       [EKNPropertyDescription edgeInsetsPropertyWithName:@"contentInset"],
       [EKNPropertyDescription edgeInsetsPropertyWithName:@"scrollIndicatorInsets"],
       [EKNPropertyDescription togglePropertyWithName:@"scrollEnabled"],
       ]];
}

@end
