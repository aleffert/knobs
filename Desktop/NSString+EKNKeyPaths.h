//
//  NSString+EKNKeyPaths.h
//  Knobs-Desktop
//
//  Created by Akiva Leffert on 2/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EKNKeyPaths)

- (NSString*)stringByAppendingKeyPath:(NSString*)path;

@end
