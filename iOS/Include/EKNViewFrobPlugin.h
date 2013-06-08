//
//  EKNViewFrobPlugin.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNDevicePlugin.h"

@interface EKNViewFrobPlugin : NSObject <EKNDevicePlugin>

+ (EKNViewFrobPlugin*)sharedPlugin;

@end


@interface EKNViewFrobPlugin (EKNPrivate)

- (void)markViewUpdated:(UIView*)view;

@end