//
//  UIScrollView+EKNViewFrob.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "UIScrollView+EKNViewFrobInfo.h"

#import "EKNPropertyDescription.h"
#import "UIView+EKNFrobInfo.h"

@implementation UIScrollView (EKNViewFrobInfo)

+ (NSArray*)frob_propertyInfos {
    NSArray* infos = [super frob_propertyInfos];
    return [@[
            [EKNPropertyDescription pointPropertyWithName:@"contentOffset"],
            [EKNPropertyDescription sizePropertyWithName:@"contentSize"],
            ] arrayByAddingObjectsFromArray:infos];
}

@end
