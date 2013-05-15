//
//  EKNKnobs.h
//  Knobs-client
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EKNDevicePlugin.h"

@interface EKNKnobs : NSObject

+ (EKNKnobs*)sharedController;
- (void)registerPlugin:(id <EKNDevicePlugin>)plugin;
- (void)start;
- (void)stop;

@end
