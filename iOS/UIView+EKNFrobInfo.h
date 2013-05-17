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

+ (void)frob_enable;
+ (UIView*)frob_viewWithID:(NSString*)viewID;
+ (NSString*)frob_IDForView:(UIView*)view;
- (EKNViewFrobInfo*)frob_info;

@end
