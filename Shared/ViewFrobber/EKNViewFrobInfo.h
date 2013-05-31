//
//  EKNViewFrobInfo.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/16/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EKNViewFrobInfo : NSObject <NSCoding>

@property (copy, nonatomic) NSString* className;
@property (copy, nonatomic) NSString* layerClassName;
@property (copy, nonatomic) NSString* nextResponderClassName;
@property (copy, nonatomic) NSString* nextResponderAddress;
@property (copy, nonatomic) NSString* viewID;
@property (copy, nonatomic) NSString* parentID;
@property (copy, nonatomic) NSString* address;
@property (copy, nonatomic) NSArray* children;
@property (strong, nonatomic) NSDictionary* properties;

@end
