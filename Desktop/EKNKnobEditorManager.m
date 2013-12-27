//
//  EKNKnobEditorManager.m
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobEditorManager.h"

#import "EKNPropertyDescription.h"

@implementation EKNKnobEditorManager

+ (EKNKnobEditorManager*)sharedManager {
    static dispatch_once_t onceToken;
    static EKNKnobEditorManager* sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[EKNKnobEditorManager alloc] init];
    });
    return sharedManager;
}

- (void)registerPropertyTypesInTableView:(NSTableView*)tableView {
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobColorEditor" bundle:nil] forIdentifier:EKNPropertyTypeColor];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobToggleEditor" bundle:nil] forIdentifier:EKNPropertyTypeToggle];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobSliderEditor" bundle:nil] forIdentifier:EKNPropertyTypeSlider];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobImageEditor" bundle:nil] forIdentifier:EKNPropertyTypeImage];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobFloatQuadEditor" bundle:nil] forIdentifier:EKNPropertyTypeFloatQuad];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobFloatPairEditor" bundle:nil] forIdentifier:EKNPropertyTypeFloatPair];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobAffineTransformEditor" bundle:nil] forIdentifier:EKNPropertyTypeAffineTransform];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobStringEditor" bundle:nil] forIdentifier:EKNPropertyTypeString];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobPushButtonEditor" bundle:nil] forIdentifier:EKNPropertyTypePushButton];
}

- (CGFloat)editorHeightOfType:(NSString*)type {
    NSDictionary* sizes = @{
                            EKNPropertyTypeColor : @24,
                            EKNPropertyTypeToggle : @24,
                            EKNPropertyTypePushButton : @28,
                            EKNPropertyTypeSlider : @58,
                            EKNPropertyTypeImage : @236,
                            EKNPropertyTypeFloatQuad : @103,
                            EKNPropertyTypeFloatPair : @61,
                            EKNPropertyTypeAffineTransform : @131,
                            EKNPropertyTypeString : @46,
                            };
    
    return [sizes[type] floatValue];
}

@end
