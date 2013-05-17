//
//  EKNPropertyInfo.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyInfo.h"

@interface EKNPropertyInfo ()

@property (nonatomic, strong) EKNPropertyDescription* propertyDescription;
@property (nonatomic, strong) id <NSCoding> value;

@end

@implementation EKNPropertyInfo

+ (EKNPropertyInfo*)infoWithDescription:(EKNPropertyDescription*)description value:(id <NSCoding>)value {
    EKNPropertyInfo* result = [[EKNPropertyInfo alloc] init];
    result.propertyDescription = description;
    result.value = value;
    return result;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self != nil) {
        self.propertyDescription = [aDecoder decodeObjectForKey:@"propertyDescription"];
        self.value = [aDecoder decodeObjectForKey:@"value"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.propertyDescription forKey:@"propertyDescription"];
    [aCoder encodeObject:self.value forKey:@"value"];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p desc = %@, value = %@> ", [self class], self, self.propertyDescription, self.value];
}

@end
