//
//  EKNLoggerPlugin.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLoggerPlugin.h"

@implementation EKNLoggerPlugin

- (NSString*)name {
    return @"com.knobs.logger";
}

- (NSString*)displayName {
    return @"Logger";
}

- (NSViewController <EKNConsoleController>*)viewControllerWithChannel:(id<EKNChannel>)channel {
    return nil;
}

@end
