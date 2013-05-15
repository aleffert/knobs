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

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage* image;
#else
@property (nonatomic, strong) NSImage* image;
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



- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p, data = %p, image = %@>", [self class], self, self.data, self.image];
}

#if TARGET_OS_IPHONE


- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if(self != nil) {
        NSData* imageData = UIImagePNGRepresentation(image);
        self.data = imageData;
        self.image = image;
    }
    return self;
}

- (void)buildImageFromData {
    self.image = [UIImage imageWithData:self.data];
}

#else

- (id)initWithImage:(NSImage *)image {
    self = [super init];
    if(self != nil) {
        self.data = [[image representations][0] representationUsingType:NSPNGFileType properties:nil];
        self.image = image;
    }
    return self;
}

- (void)buildImageFromData {
    self.image = [[NSImage alloc] initWithData:self.data];
}

#endif

@end
