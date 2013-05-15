//
//  EKNWireImage.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface EKNWireImage : NSObject <NSCoding>


@property (readonly, nonatomic, strong) NSData* data;

#if TARGET_OS_IPHONE

- (id)initWithImage:(UIImage*)image;
@property (readonly, nonatomic, strong) UIImage* image;

#else

- (id)initWithImage:(NSImage*)image;
@property (readonly, nonatomic, strong) NSImage* image;

#endif

@end
