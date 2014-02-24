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

- (void)registerPropertyTypesInTableView:(NSTableView*)tableView {
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobAffineTransformEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeAffineTransform]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobColorEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeColor]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobImageEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeImage]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobIntEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeInt]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobFloatEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeFloat]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobFloatPairEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeFloatPair]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobFloatQuadEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeFloatQuad]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobPushButtonEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypePushButton]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobSliderEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeSlider]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobStringEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeString]];
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobToggleEditor" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeToggle]];
}

- (CGFloat)editorHeightOfType:(EKNPropertyType)type {
    switch (type) {
        case EKNPropertyTypeAffineTransform: return 131;
        case EKNPropertyTypeColor: return 24;
        case EKNPropertyTypeFloat: return 43;
        case EKNPropertyTypeFloatPair: return 61;
        case EKNPropertyTypeFloatQuad: return 103;
        case EKNPropertyTypeImage: return 236;
        case EKNPropertyTypeInt: return 43;
        case EKNPropertyTypePushButton: return 28;
        case EKNPropertyTypeSlider: return 58;
        case EKNPropertyTypeString: return 46;
        case EKNPropertyTypeToggle: return 24;
    }
}

@end
