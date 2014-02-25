//
//  UIView+EKNFrobInfo.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/16/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EKNPropertyDescription.h"

@class EKNViewFrobInfo;

@protocol EKNViewFrobPropertyContext <NSObject>

/// Adds an array of EKNViewFrobPropertyInfo* to a group with the given name
/// Group is typically the class name or an easy to read version thereof
- (void)addGroup:(NSString*)group withProperties:(NSArray*)properties;

@end

/// Implement this on your custom UIView subclasses
/// to return additional properties that can be viewed and edited
@protocol EKNViewFrobPropertyInfo <NSObject>

/// Array of EKNViewFrobPropertyInfo*
/// Should call super at the beginning
- (void)frob_accumulatePropertiesInto:(id <EKNViewFrobPropertyContext>)context;

@end


@interface UIView (EKNFrob) <EKNViewFrobPropertyInfo>

/// Swizzle in our custom methods to watch when certain view properties change
+ (void)frob_enable;
/// Swizzle out our custom methods
+ (void)frob_disable;

/// returns the view with this ID
/// Returns the empty string if the view can't be found
+ (UIView*)frob_viewWithID:(NSString*)viewID;

/// Fills out an EKNViewFrobInfo* for this view
- (EKNViewFrobInfo*)frob_info;

/// Returns a unique id for this view
- (NSString*)frob_viewID;

/// Array of EKNNamedGroup* whose items are of type EKNPropertyInfo*
- (NSArray*)frob_groups;

@end
