//
//  EKNNamedGroup.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 12/22/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EKNNamedGroup : NSObject <NSCoding>

@property (copy, nonatomic) NSString* name;
@property (copy, nonatomic) NSArray* items;

@end
