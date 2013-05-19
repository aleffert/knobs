//
//  EKNLiveKnobsPlugin.m
//  Knobs
//
//  Created by Akiva Leffert on 5/19/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLiveKnobsPlugin.h"

@implementation EKNLiveKnobsPlugin

- (NSString*)name {
    return @"com.knobs.live-knobs";
}

- (NSString*)displayName {
    return @"Live Knobs";
}

- (NSViewController<EKNConsoleController>*)viewControllerWithChannel:(id<EKNChannel>)channel {
    return nil;
}

@end
