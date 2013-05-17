//
//  EKNPropertyDescription.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* EKNPropertyTypeColor;
NSString* EKNPropertyTypeToggle;

@interface EKNPropertyDescription : NSObject <NSCoding>

+ (EKNPropertyDescription*)propertyWithName:(NSString*)name type:(NSString*)type parameters:(NSDictionary*)parameters;
+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)togglePropertyWithName:(NSString*)name;

@property (readonly, copy) NSString* name;
@property (readonly, copy) NSString* type;
@property (readonly, copy) NSDictionary* parameters;

- (id)getValueFrom:(id)source;

@end
