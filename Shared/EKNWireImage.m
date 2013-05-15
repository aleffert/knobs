//
//  EKNWireImage.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNWireImage.h"

@interface EKNWireImage ()

@property (nonatomic, strong) NSData* data;

#ifdef TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage* image;
#endif

@end

@implementation EKNWireImage

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self != nil) {
        self.data = [aDecoder decodeObjectForKey:@"data"];
        [self buildImageFromData];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.data forKey:@"data"];
}

#if TARGET_OS_IPHONE

- (void)buildImageFromData {
    self.image = [UIImage imageWithData:self.data];
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if(self != nil) {
        NSData* imageData = UIImagePNGRepresentation(image);
        self.data = imageData;
        self.image = image;
    }
    return self;
}

#endif

@end
