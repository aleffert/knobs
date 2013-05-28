//
//  EKNUUID.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/28/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

// Ideally we'd just use NSUUID, but that's not available on iOS 5
@interface EKNUUID : NSObject

+ (NSString*)UUIDString;

@end
