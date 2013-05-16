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

#import <objc/runtime.h>

static NSString* EKNFrobInfoFrobEnabled = @"EKNFrobInfoFrobEnabled";

@implementation UIView (EKNFrob)

+ (NSString*)frobIDForView:(UIView*)view {
    return view == nil ? @"" : [NSString stringWithFormat:@"%p", view];
}

+ (void)enableFrobbing {
    Method original = class_getInstanceMethod([UIView class], @selector(didMoveToSuperview));
    Method frobbed = class_getInstanceMethod([UIView class], @selector(frob_didMoveToSuperview));
    method_exchangeImplementations(original, frobbed);
}

- (void)enableFrobbingIfNecessary {
    if(!self.frobEnabled) {
        self.frobEnabled = YES;
    }
}

- (void)frob_didMoveToSuperview {
    [[EKNViewFrobPlugin sharedFrobber] view:self didMoveToSuperview:self.superview];
    [self frob_didMoveToSuperview];
}

- (void)setFrobEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, &EKNFrobInfoFrobEnabled, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)frobEnabled {
    return [objc_getAssociatedObject(self, &EKNFrobInfoFrobEnabled) boolValue];
}

- (EKNViewFrobInfo*)frobInfo {
    NSMutableArray* children = [NSMutableArray array];
    for(UIView* child in self.subviews) {
        [children addObject:[child frobInfo]];
    }
    EKNViewFrobInfo* info = [[EKNViewFrobInfo alloc] init];
    info.children = children;
    info.viewID = [UIView frobIDForView:self];
    info.className = NSStringFromClass([self class]);
    info.layerClassName = NSStringFromClass([self.layer class]);
    info.parentID = [UIView frobIDForView:self.superview];
    return info;
}

@end
