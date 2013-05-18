//
//  UIImageView+EKNFrobInfo.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "UIImageView+EKNFrobInfo.h"

#import "UIView+EKNFrobInfo.h"
#import "EKNPropertyDescription.h"

@implementation UIImageView (EKNFrobInfo)

+ (NSArray*)frob_propertyInfos {
    NSArray* infos = [super frob_propertyInfos];
    return [@[
            [EKNPropertyDescription imagePropertyWithName:@"image" wrapCG:NO],
            ] arrayByAddingObjectsFromArray:infos];

}


@end
