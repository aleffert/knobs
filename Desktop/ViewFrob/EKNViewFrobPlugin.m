//
//  EKNViewFrobPlugin.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobPlugin.h"

#import "EKNViewFrob.h"
#import "EKNViewFrobViewController.h"

@implementation EKNViewFrobPlugin

- (NSString*)name {
    return EKNViewFrobName;
}

- (NSString*)displayName {
    return @"View";
}

- (NSViewController<EKNConsoleController>*)viewControllerWithChannel:(id<EKNChannel>)channel {
    return [[EKNViewFrobViewController alloc] init];
}

@end
