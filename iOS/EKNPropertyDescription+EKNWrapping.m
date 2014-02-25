//
//  EKNPropertyDescription+EKNWrapping.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 12/29/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPropertyDescription+EKNWrapping.h"
#import "EKNPropertyDescribing.h"
#import "EKNGroupTransporting.h"

#import "EKNWireImage.h"

@implementation EKNPropertyDescription (EKNWrapping)

- (id)wrappedValueFromSource:(id)source {
    id result = [source valueForKeyPath:self.name];
    if(result == nil) {
        return nil;
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
                return nil;
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
        else if(self.type == EKNPropertyTypeGroup) {
            if([result conformsToProtocol:@protocol(EKNGroupTransporting)]) {
                result = [result ekn_transportValue];
            }
            else {
                NSMutableDictionary* fields = [NSMutableDictionary dictionary];
                for (EKNPropertyDescription* description in self.parameters[@(EKNPropertyGroupChildren)]) {
                    fields[description.name] = [description valueWithWrappedValue:[result valueForKey:description.name]];
                }
                result = fields;
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
        if([self.parameters[@(EKNPropertyImageWrapCG)] boolValue]) {
            return (id)[wrappedValue CGImage];
        }
        else {
            return [wrappedValue image];
        }
    }
    else if(self.type == EKNPropertyTypeGroup) {
        NSString* className = self.parameters[@(EKNPropertyGroupClassName)];
        Class class = NSClassFromString(className);
        if([class conformsToProtocol:@protocol(EKNGroupTransporting)]) {
            return [NSClassFromString(className) ekn_unwrapTransportValue:wrappedValue];
        }
        else {
            id object = [[class alloc] init];
            for(EKNPropertyDescription* child in self.parameters[@(EKNPropertyGroupChildren)]) {
                id childValue = [child valueWithWrappedValue:wrappedValue[child.name]];
                if(childValue != nil) {
                    [object setValue:childValue forKey:child.name];
                }
            }
            return object;
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
