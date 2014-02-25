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

@interface KTTestGroup : NSObject <EKNPropertyDescribing>

@property (strong, nonatomic) UIColor* color;
@property (assign, nonatomic) CGFloat size;

@end

@implementation KTTestGroup

+ (EKNPropertyDescription*)ekn_propertyDescriptionWithName:(NSString *)name {
    return [EKNPropertyDescription
            groupPropertyWithName:name
            properties:@[
                         [EKNPropertyDescription colorPropertyWithName:@"color"],
                         [EKNPropertyDescription floatPropertyWithName:@"size"]
                         ]];
}

+ (KTTestGroup*)ekn_unwrapTransportValue:(NSDictionary*)value {
    KTTestGroup* group = [[KTTestGroup alloc] init];
    group.size = [[value objectForKey:@"size"] floatValue];
    group.color = [value objectForKey:@"color"];
    
    return group;
}

- (id <NSCoding>)ekn_transportValue {
    NSMutableDictionary* dictionary = @{@"size": @(self.size)}.mutableCopy;
    if(self.color) {
        [dictionary setObject:self.color forKey:@"color"];
    }
    return dictionary;
}

@end

@interface KTAppDelegate () <EKNLiveKnobsCallback>

@property (strong, nonatomic) KTTestGroup* testGroup;

@end

@implementation KTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[EKNKnobs sharedController] registerDefaultPlugins];
    [[EKNKnobs sharedController] start];
    
    self.testGroup = [[KTTestGroup alloc] init];
    self.testGroup.color = [UIColor redColor];
    EKNMakeObjectKnob(KTTestGroup, self.testGroup);
    
    EKNMakeColorKnob(self.window.rootViewController.view.backgroundColor);
    
    return YES;
}

- (void)ekn_knobChangedNamed:(NSString *)label withDescription:(EKNPropertyDescription *)description toValue:(id)value {
    self.window.rootViewController.view.backgroundColor = self.testGroup.color;
}

@end
