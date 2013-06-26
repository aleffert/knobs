//
//  UIView+EKNFrobInfo.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/16/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EKNViewFrobInfo;

// Implement this to return additional properties that can be viewed and edited
// Should call super and merge the results from there.
@protocol EKNViewFrobPropertyInfo <NSObject>

// Array of EKNViewFrobPropertyInfo*
- (NSArray*)frob_propertyInfos;

@end


@interface UIView (EKNFrob) <EKNViewFrobPropertyInfo>

+ (void)frob_enable;
+ (UIView*)frob_viewWithID:(NSString*)viewID;


- (EKNViewFrobInfo*)frob_info;
- (NSArray*)frob_properties;
- (NSString*)frob_viewID;

@end
