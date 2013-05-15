//
//  EKNWireColor.h
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EKNWireColor : NSObject <NSCoding>

@property (readonly, assign, nonatomic) CGFloat red;
@property (readonly, assign, nonatomic) CGFloat green;
@property (readonly, assign, nonatomic) CGFloat blue;
@property (readonly, assign, nonatomic) CGFloat alpha;

#if TARGET_OS_IPHONE
- (id)initWithColor:(UIColor*)color;
@property (readonly, nonatomic) UIColor* color;
#else
- (id)initWithColor:(NSColor*)color;
@property (readonly, strong, nonatomic) NSColor* color;
#endif

@end
