//
//  EKNKnobListenerInfo.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobListenerInfo.h"

@implementation EKNKnobListenerInfo

- (void)dealloc {
    [self.delegate listenerCancelled:self];
}

@end
