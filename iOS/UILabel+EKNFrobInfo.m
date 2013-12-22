//
//  UILabel+EKNFrobInfo.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 8/6/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "UILabel+EKNFrobInfo.h"

#import "EKNPropertyDescription.h"
#import "UIView+EKNFrobInfo.h"

@implementation UILabel (EKNFrobInfo)

- (void)frob_accumulatePropertiesInto:(id<EKNViewFrobPropertyContext>)context {
    [super frob_accumulatePropertiesInto:context];
    [context addGroup:@"UILabel" withProperties:@[
              [EKNPropertyDescription stringPropertyWithName:@"text"],
              [EKNPropertyDescription colorPropertyWithName:@"textColor"],
              [EKNPropertyDescription colorPropertyWithName:@"shadowColor"]
              ]];
}

@end
