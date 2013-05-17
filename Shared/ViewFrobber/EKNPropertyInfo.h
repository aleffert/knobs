//
//  EKNPropertyInfo.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNPropertyDescription;

@interface EKNPropertyInfo : NSObject <NSCoding>

+ (EKNPropertyInfo*)infoWithDescription:(EKNPropertyDescription*)description value:(id <NSCoding>)value;

@property (readonly, nonatomic, strong) EKNPropertyDescription* propertyDescription;
@property (readonly, nonatomic, strong) id value;

@end
