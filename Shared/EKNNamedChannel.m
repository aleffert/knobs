//
//  EKNNamedChannel.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNNamedChannel.h"

@implementation EKNNamedChannel

- (NSUInteger)hash {
    return self.ownerName.hash;
}

- (BOOL)isEqual:(EKNNamedChannel*)channel {
    return [channel isKindOfClass:[EKNNamedChannel class]] && [self.ownerName isEqualToString:channel.ownerName] && [self.name isEqualToString:channel.name];
}

@end
