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

- (NSArray*)frob_propertyInfos {
    NSArray* infos = [super frob_propertyInfos];
    return [@[
              [EKNPropertyDescription stringPropertyWithName:@"text"],
              [EKNPropertyDescription colorPropertyWithName:@"textColor"],
              [EKNPropertyDescription colorPropertyWithName:@"shadowColor"]
              ] arrayByAddingObjectsFromArray:infos];
}

@end
