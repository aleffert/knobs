//
//  EKNViewFrobInfo.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/16/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobInfo.h"

@implementation EKNViewFrobInfo

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self != nil) {
        self.layerClassName = [aDecoder decodeObjectForKey:@"layerClassName"];
        self.className = [aDecoder decodeObjectForKey:@"className"];
        self.viewID = [aDecoder decodeObjectForKey:@"viewID"];
        self.children = [aDecoder decodeObjectForKey:@"children"];
        self.properties = [aDecoder decodeObjectForKey:@"properties"];
        self.parentID = [aDecoder decodeObjectForKey:@"parentID"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.nextResponderAddress = [aDecoder decodeObjectForKey:@"nextResponderAddress"];
        self.nextResponderClassName = [aDecoder decodeObjectForKey:@"nextResponderClassName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.layerClassName forKey:@"layerClassName"];
    [aCoder encodeObject:self.className forKey:@"className"];
    [aCoder encodeObject:self.viewID forKey:@"viewID"];
    [aCoder encodeObject:self.children forKey:@"children"];
    [aCoder encodeObject:self.properties forKey:@"properties"];
    [aCoder encodeObject:self.parentID forKey:@"parentID"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.nextResponderAddress forKey:@"nextResponderAddress"];
    [aCoder encodeObject:self.nextResponderClassName forKey:@"nextResponderClassName"];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p className = %@, layerClassName = %@, viewID = %@, parentID = %@, children.count = %ld>", [self class], self, self.className, self.layerClassName, self.viewID, self.parentID, (long)self.children.count];
}

- (BOOL)isEqual:(id)object {
    return [super isEqual:object];
}


@end
