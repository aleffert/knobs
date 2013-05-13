//
//  EKNKnobs.m
//  Knobs-client
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobs.h"

@interface EKNKnobs ()

+ (EKNKnobs*)sharedController;

@end

@implementation EKNKnobs

+ (EKNKnobs*)sharedController {
    static dispatch_once_t onceToken;
    static EKNKnobs* controller = nil;
    dispatch_once(&onceToken, ^{
        controller = [[EKNKnobs alloc] init];
    });
    
    return controller;
}

+ (void)start {
    [[self sharedController] start];
}

+ (void)stop {
    [[self sharedController] stop];
}

- (void)start {
}

- (void)stop {
}

@end
