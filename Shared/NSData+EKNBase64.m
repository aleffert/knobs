//
//  NSData+EKNBase64.m
//  Knobs
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

@implementation NSData (EKNBase64)

+ (NSData *)ekn_dataFromBase64String:(NSString *)aString
{
    NSData* result = [NSData alloc];
    if ([result respondsToSelector:@selector(initWithBase64EncodedString:options:)]) {
        return [result initWithBase64EncodedString:aString options:0];
    }
    else {
        return [result initWithBase64Encoding:aString];
    }
}

- (NSString *)ekn_base64EncodedString
{
    if([self respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        return [self base64EncodedStringWithOptions:0];
    }
    else {
        return [self base64Encoding];
    }
}

@end
