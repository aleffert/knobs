//
//  UIView+EKNFrobInfo.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/16/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EKNViewFrobInfo;

@protocol EKNViewFrobPropertyContext <NSObject>

/// Adds an array of EKNViewFrobPropertyInfo* to a group with the given name
/// Group is typically the class name or an easy to read version thereof
- (void)addGroup:(NSString*)group withProperties:(NSArray*)properties;

@end

/// Implement this to return additional properties that can be viewed and edited
@protocol EKNViewFrobPropertyInfo <NSObject>

/// Array of EKNViewFrobPropertyInfo*
/// Should call super
- (void)frob_accumulatePropertiesInto:(id <EKNViewFrobPropertyContext>)context;

@end


@interface UIView (EKNFrob) <EKNViewFrobPropertyInfo>

+ (void)frob_enable;
+ (void)frob_disable;
+ (UIView*)frob_viewWithID:(NSString*)viewID;

- (EKNViewFrobInfo*)frob_info;

/// Unique id for this view
- (NSString*)frob_viewID;

/// Array of EKNNamedGroup* whose items are of type EKNPropertyInfo*
- (NSArray*)frob_groups;

@end
