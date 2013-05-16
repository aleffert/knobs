//
//  UIView+EKNFrobInfo.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/16/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EKNViewFrobInfo;

@interface UIView (EKNFrob)

+ (void)enableFrobbing;
+ (NSString*)frobIDForView:(UIView*)view;
- (EKNViewFrobInfo*)frobInfo;

@end
