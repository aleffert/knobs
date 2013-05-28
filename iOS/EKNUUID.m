//
//  EKNUUID.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/28/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNUUID.h"

@implementation EKNUUID

+ (NSString*)UUIDString {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString* uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

@end
