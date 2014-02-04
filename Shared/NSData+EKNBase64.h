//
//  NSData+EKNBase64.h
//  Knobs
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (EKNBase64)

+ (NSData *)ekn_dataFromBase64String:(NSString *)aString;
- (NSString *)ekn_base64EncodedString;

@end
