//
//  UIView+EKNFrobInfo.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/16/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "UIView+EKNFrobInfo.h"

#import <QuartzCore/QuartzCore.h>

#import "EKNViewFrobInfo.h"
#import "EKNViewFrobPlugin.h"
#import "EKNPropertyDescription.h"
#import "EKNPropertyInfo.h"

#import <objc/runtime.h>

static NSString* EKNFrobInfoFrobEnabled = @"EKNFrobInfoFrobEnabled";
static NSString* EKNFrobViewIDKey = @"EKNFrobViewIDKey";

static NSMapTable* gFrobViewTable = nil;

@implementation UIView (EKNFrob)

+ (NSString*)frob_IDForView:(UIView*)view {
    if(view == nil) {
        return @""; // Use @"" because we sometimes use these as dictionary values
    }
    else {
        NSString* frobID = objc_getAssociatedObject(view, &EKNFrobViewIDKey);
        if(frobID == nil) {
            frobID = [[NSUUID UUID] UUIDString];
            [gFrobViewTable setObject:view forKey:frobID];
            objc_setAssociatedObject(view, &EKNFrobViewIDKey, frobID, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        return frobID;
    }
}

+ (void)frob_enable {
    gFrobViewTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    
    Method original = class_getInstanceMethod([UIView class], @selector(didMoveToSuperview));
    Method frobbed = class_getInstanceMethod([UIView class], @selector(frob_didMoveToSuperview));
    method_exchangeImplementations(original, frobbed);
}

+ (UIView*)frob_viewWithID:(NSString*)viewID {
    return [gFrobViewTable objectForKey:viewID];
}

+ (NSArray*)frob_propertyInfos {
    static NSArray* viewProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewProperties =
        @[
          [EKNPropertyDescription colorPropertyWithName:@"backgroundColor"],
          [EKNPropertyDescription togglePropertyWithName:@"hidden"],
          [EKNPropertyDescription pointPropertyWithName:@"center"],
          [EKNPropertyDescription togglePropertyWithName:@"clipsToBounds"],
          [EKNPropertyDescription continuousSliderPropertyWithName:@"alpha" min:0 max:1],
          [EKNPropertyDescription rectPropertyWithName:@"frame"],
          [EKNPropertyDescription rectPropertyWithName:@"bounds"],
          [EKNPropertyDescription affineTransformPropertyWithName:@"transform"],
          [EKNPropertyDescription colorPropertyWithName:@"layer.borderColor" wrapCG:YES],
          [EKNPropertyDescription continuousSliderPropertyWithName:@"layer.borderWidth" min:0 max:20],
          [EKNPropertyDescription continuousSliderPropertyWithName:@"layer.cornerRadius" min:0 max:20],
          [EKNPropertyDescription rectPropertyWithName:@"layer.contentsRect"],
          [EKNPropertyDescription rectPropertyWithName:@"layer.contentsCenter"],
          ];
    });
    return viewProperties;
}

- (NSString*)frob_viewID {
    return [UIView frob_IDForView:self];
}

- (void)enableFrobbingIfNecessary {
    if(!self.frob_enabled) {
        self.frob_enabled = YES;
    }
}

- (void)frob_didMoveToSuperview {
    [[EKNViewFrobPlugin sharedFrobber] view:self didMoveToSuperview:self.superview];
    [self frob_didMoveToSuperview];
}

- (void)setFrob_enabled:(BOOL)enabled {
    objc_setAssociatedObject(self, &EKNFrobInfoFrobEnabled, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)frob_enabled {
    return [objc_getAssociatedObject(self, &EKNFrobInfoFrobEnabled) boolValue];
}

- (EKNViewFrobInfo*)frob_info {
    NSMutableArray* children = [NSMutableArray array];
    for(UIView* child in self.subviews) {
        [children addObject:[child frob_info]];
    }
    EKNViewFrobInfo* info = [[EKNViewFrobInfo alloc] init];
    info.children = children;
    info.viewID = [UIView frob_IDForView:self];
    info.className = NSStringFromClass([self class]);
    info.layerClassName = NSStringFromClass([self.layer class]);
    info.parentID = [UIView frob_IDForView:self.superview];
    info.address = [NSString stringWithFormat:@"%p", self];
    return info;
}

- (NSArray*)frob_properties {
    NSMutableArray* properties = [NSMutableArray array];
    for(EKNPropertyDescription* description in [[self class] frob_propertyInfos]) {
        id value = [description getValueFromSource:self];
        EKNPropertyInfo* info = [EKNPropertyInfo infoWithDescription:description value:value];
        [properties addObject:info];
    }
    
    return properties;
}

@end
