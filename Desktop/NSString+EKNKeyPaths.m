//
//  NSString+EKNKeyPaths.m
//  Knobs-Desktop
//
//  Created by Akiva Leffert on 2/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import "NSString+EKNKeyPaths.h"

@implementation NSString (EKNKeyPaths)

- (NSString*)stringByAppendingKeyPath:(NSString *)path {
    return self.length == 0 ? path : [self stringByAppendingFormat:@".%@", path];
}

@end
