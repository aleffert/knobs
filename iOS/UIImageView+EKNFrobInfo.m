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

- (void)frob_accumulatePropertiesInto:(id<EKNViewFrobPropertyContext>)context {
    [context addGroup:@"UIImageView" withProperties:
     @[[EKNPropertyDescription imagePropertyWithName:@"image" wrapCG:NO]]
     ];

}


@end
