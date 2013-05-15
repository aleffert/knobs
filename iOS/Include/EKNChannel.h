//
//  EKNChannel.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EKNChannel <NSObject>

@property (readonly, nonatomic, copy) NSString* name;

@end
