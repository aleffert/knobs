//
//  KTAppDelegate.m
//  KnobsTest
//
//  Created by Akiva Leffert on 2/23/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import "KTAppDelegate.h"

#import <EKNKnobs.h>
#import <EKNLiveKnobsPlugin.h>
#import <UIView+EKNFrobInfo.h>

@interface KTTextStyle : NSObject <EKNPropertyDescribing>

@property (strong, nonatomic) UIColor* color;
@property (assign, nonatomic) CGFloat size;

@end

@implementation KTTextStyle

+ (EKNPropertyDescription*)ekn_propertyDescriptionWithName:(NSString *)name {
    return [EKNPropertyDescription
            groupPropertyWithName:name
            properties:@[
                         [EKNPropertyDescription colorPropertyWithName:@"color"],
                         [EKNPropertyDescription floatPropertyWithName:@"size"]
                         ]
            class:[self class]];
}

@end

@interface KTLabel : UILabel <EKNViewFrobPropertyInfo>

@property (strong, nonatomic) KTTextStyle* textStyle;

@end

@implementation KTLabel

@synthesize textStyle = _textStyle;

- (void)frob_accumulatePropertiesInto:(id<EKNViewFrobPropertyContext>)context {
    [super frob_accumulatePropertiesInto:context];
    [context addGroup:@"KTLabel" withProperties:@[
         [KTTextStyle ekn_propertyDescriptionWithName:@"textStyle"]
     ]];
}

- (void)setTextStyle:(KTTextStyle *)textStyle {
    _textStyle = textStyle;
    self.font = [UIFont systemFontOfSize:textStyle.size];
    self.textColor = textStyle.color;
}

@end

@interface KTAppDelegate () <EKNLiveKnobsCallback>

@property (strong, nonatomic) KTLabel* label;
@property (strong, nonatomic) KTTextStyle* style;

@end

@implementation KTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[EKNKnobs sharedController] registerDefaultPlugins];
    [[EKNKnobs sharedController] start];
    
    KTLabel* label = [[KTLabel alloc] initWithFrame:CGRectZero];
    label.text = @"Foo";
    label.transform = CGAffineTransformMakeTranslation(120, 120);
    [label sizeToFit];
    self.label = label;
    [self.window.rootViewController.view addSubview:label];
    
    EKNMakeObjectKnob(KTTextStyle, self.style);
    
    return YES;
}

- (void)ekn_knobChangedNamed:(NSString *)label withDescription:(EKNPropertyDescription *)description toValue:(id)value {
    self.label.textStyle = self.style;
}

@end
