//
//  EKNConsoleControllerContextDispatcher.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNConsoleControllerContextDispatcher.h"

@implementation EKNConsoleControllerContextDispatcher

- (void)sendMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    [self.delegate sendMessage:data onChannel:channel];
}

@end
