//
//  EKNKnobInfo.m
//  Knobs
//
//  Created by Akiva Leffert on 5/19/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobInfo.h"

#import "EKNPropertyDescription.h"
#import "NSString+EKNKeyPaths.h"

@implementation EKNKnobInfo

+ (EKNKnobInfo*)knob {
    return [[EKNKnobInfo alloc] init];
}

- (NSString*)displayName {
    return self.label ?: self.propertyDescription.name;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self != nil) {
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.propertyDescription = [aDecoder decodeObjectForKey:@"propertyDescription"];
        self.knobID = [aDecoder decodeObjectForKey:@"knobID"];
        self.sourcePath = [aDecoder decodeObjectForKey:@"sourcePath"];
        self.label = [aDecoder decodeObjectForKey:@"label"];
        self.externalCode = [aDecoder decodeObjectForKey:@"externalCode"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.propertyDescription forKey:@"propertyDescription"];
    [aCoder encodeObject:self.knobID forKey:@"knobID"];
    [aCoder encodeObject:self.sourcePath forKey:@"sourcePath"];
    [aCoder encodeObject:self.label forKey:@"label"];
    [aCoder encodeObject:self.externalCode forKey:@"externalCode"];
}

- (EKNKnobInfo*)rootKnob {
    return self;
}

- (void)updateValueAfterChildChange {
    if(self.propertyDescription.type == EKNPropertyTypeGroup) {
        NSMutableDictionary* value = [[NSMutableDictionary alloc] init];
        for(EKNKnobInfo* info in self.children) {
            [info updateValueAfterChildChange];
            if(info.value != nil) {
                [value setObject:info.value forKey:info.propertyDescription.name];
            }
        }
        self.value = value;
    }
    else {
        // base value so do nothing
    }
}

- (void)updateChildrenAfterValueChange {
    if(self.propertyDescription.type == EKNPropertyTypeGroup) {
        for(EKNKnobInfo* info in self.children) {
            info.value = [self.value valueForKeyPath:info.propertyDescription.name];
            [info updateChildrenAfterValueChange];
        }
    }
    else {
        // base value so do nothing
    }
}

@end

@implementation EKNRootDerivedKnobInfo

@synthesize rootKnob = _rootKnob;

- (NSString*)sourcePath {
    return self.rootKnob.sourcePath;
}

@end