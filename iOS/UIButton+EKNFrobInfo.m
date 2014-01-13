//
//  UIButton+EKNFrobInfo.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 1/10/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import "UIButton+EKNFrobInfo.h"

@implementation UIButton (EKNFrobInfo)

- (void)frob_accumulatePropertiesInto:(id<EKNViewFrobPropertyContext>)context {
    [super frob_accumulatePropertiesInto:context];
    [context addGroup:@"UIButton" withProperties:
     @[
       [EKNPropertyDescription edgeInsetsPropertyWithName:@"titleEdgeInsets"],
       [EKNPropertyDescription edgeInsetsPropertyWithName:@"imageEdgeInsets"],
       [EKNPropertyDescription edgeInsetsPropertyWithName:@"contentEdgeInsets"],
       [EKNPropertyDescription togglePropertyWithName:@"adjustsImageWhenHighlighted"],
       [EKNPropertyDescription togglePropertyWithName:@"adjustsImageWhenDisabled"],
       [EKNPropertyDescription togglePropertyWithName:@"showsTouchWhenHighlighted"],
       [EKNPropertyDescription togglePropertyWithName:@"reversesTitleShadowWhenHighlighted"],
       ]];
}

@end
