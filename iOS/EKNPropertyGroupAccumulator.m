//
//  EKNPropertyGroupAccumulator.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 12/22/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyGroupAccumulator.h"

#import "EKNNamedGroup.h"

@interface EKNPropertyGroupAccumulator ()

@property (strong, nonatomic) NSMutableArray* groups;

@end

@implementation EKNPropertyGroupAccumulator

- (id)init {
    self = [super init];
    if(self != nil) {
        self.groups = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addGroup:(NSString *)groupName withProperties:(NSArray *)properties {
    EKNNamedGroup* group = [[EKNNamedGroup alloc] init];
    group.name = groupName;
    group.items = properties;
    [self.groups addObject:group];
}

- (void)enumerateGroups:(void (^)(NSString *, NSArray *))enumerator {
    // Go backwards because we call super at the beginning
    // And we want more specific things visibly first
    for(EKNNamedGroup* group in self.groups.reverseObjectEnumerator) {
        enumerator(group.name, group.items);
    }
}

@end
