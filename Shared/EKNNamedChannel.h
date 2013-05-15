//
//  EKNNamedChannel.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNChannel.h"

@interface EKNNamedChannel : NSObject <EKNChannel, NSCopying>

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* ownerName;

@end
