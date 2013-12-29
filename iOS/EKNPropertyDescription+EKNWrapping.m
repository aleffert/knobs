//
//  EKNPropertyDescription+EKNWrapping.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 12/29/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription+EKNWrapping.h"

#import "EKNWireImage.h"

@implementation EKNPropertyDescription (EKNWrapping)

- (id)wrappedValueFromSource:(id)source {
    id result = [source valueForKeyPath:self.name];
    if(result == nil) {
        return [NSNull null];
    }
    else {
        if(self.type == EKNPropertyTypeColor) {
            if([[self.parameters objectForKey:@(EKNPropertyColorWrapCG)] boolValue]) {
                result = [UIColor colorWithCGColor:(CGColorRef)result];
            }
            CGColorSpaceRef space = CGColorGetColorSpace([result CGColor]);
            CGColorSpaceModel model = CGColorSpaceGetModel(space);
            // UIColor only supports archiving of RGB and White colors. So just ignore if we're not using one of those
            if(!(model == kCGColorSpaceModelCMYK || model == kCGColorSpaceModelRGB)) {
                result = [NSNull null];
            }
        }
        else if(self.type == EKNPropertyTypeImage) {
            if([[self.parameters objectForKey:@(EKNPropertyImageWrapCG)] boolValue]) {
                result = [[EKNWireImage alloc] initWithImage:[[UIImage alloc] initWithCGImage:(CGImageRef)result]];
            }
            else {
                result = [[EKNWireImage alloc] initWithImage:result];
            }
        }
        
        return result;
    }
}

- (id)valueWithWrappedValue:(id)wrappedValue {
    if(self.type == EKNPropertyTypeColor && [[self.parameters objectForKey:@(EKNPropertyColorWrapCG)] boolValue]) {
        return (id)[wrappedValue CGColor];
    }
    else if(self.type == EKNPropertyTypeImage) {
        if([wrappedValue isEqual:[NSNull null]]) {
            return nil;
        }
        else if([[self.parameters objectForKey:@(EKNPropertyImageWrapCG)] boolValue]) {
            return (id)[wrappedValue CGImage];
        }
        else {
            return [wrappedValue image];
        }
    }
    else {
        return wrappedValue;
    }
    
}

- (void)setWrappedValue:(id)wrappedValue onSource:(id)source {
    id value = [self valueWithWrappedValue:wrappedValue];
    [source setValue:value forKeyPath:self.name];
}


@end
