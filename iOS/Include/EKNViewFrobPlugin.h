//
//  EKNViewFrobPlugin.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNDevicePlugin.h"

/// Allows you to visually manipulate assorted view properties
/// To add additional manipulable properties for your custom views
/// Implement the <EKNViewFrobPropertyInfo> protocol found in UIView+EKNFrobInfo.h
/// For an example see UIScrollView+EKNFrobInfo.m
@interface EKNViewFrobPlugin : NSObject <EKNDevicePlugin>

+ (EKNViewFrobPlugin*)sharedPlugin;

@end


@interface EKNViewFrobPlugin (EKNPrivate)

- (void)markViewUpdated:(UIView*)view;

@end