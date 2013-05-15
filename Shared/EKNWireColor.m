//
//  EKNWireColor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNWireColor.h"

@interface EKNWireColor ()

@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat alpha;

#if TARGET_OS_IPHONE
@property (strong, nonatomic) UIColor* color;
#else
@property (strong, nonatomic) NSColor* color;
#endif

//TODO Figure out how badly this gets color spaces wrong

@end

@implementation EKNWireColor

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self != nil) {
        self.red = [aDecoder decodeFloatForKey:@"r"];
        self.green = [aDecoder decodeFloatForKey:@"g"];
        self.blue = [aDecoder decodeFloatForKey:@"b"];
        self.alpha = [aDecoder decodeFloatForKey:@"a"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeFloat:self.red forKey:@"r"];
    [aCoder encodeFloat:self.green forKey:@"g"];
    [aCoder encodeFloat:self.blue forKey:@"b"];
    [aCoder encodeFloat:self.alpha forKey:@"a"];
}

#if TARGET_OS_IPHONE

- (id)initWithColor:(UIColor *)color {
    self = [super init];
    if(self != nil) {
        self.color = color;
        CGFloat r = 0, g = 0, b = 0, a = 0;
        [color getRed:&r green:&g blue:&b alpha:&a];
        self.red = r;
        self.green = g;
        self.blue = b;
        self.alpha = a;
    }
    return self;
}

#else

- (id)initWithColor:(NSColor *)color {
    self = [super init];
    if(self != nil) {
        self.color = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
        CGFloat r = 0, g = 0, b = 0, a = 0;
        [color getRed:&r green:&g blue:&b alpha:&a];
        self.red = r;
        self.green = g;
        self.blue = b;
        self.alpha = a;
    }
    return self;
}

#endif

@end
