//
//  EKNKnobEditorManager.m
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobEditorManager.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"
#import "NSArray+EKNFunctional.h"
#import "NSString+EKNKeyPaths.h"

@implementation EKNKnobEditorManager

- (EKNKnobInfo*)knobInfo {
    return [[EKNKnobInfo alloc] init];
}

- (EKNRootDerivedKnobInfo*)knobWithDescription:(EKNPropertyDescription*)description atPath:(NSString*)path ofRoot:(EKNKnobInfo*)root {
    EKNRootDerivedKnobInfo* info = [[EKNRootDerivedKnobInfo alloc] init];
    info.rootKnob = root;
    info.parentKeyPath = path;
    info.propertyDescription = description;
    NSString* childPath = [path stringByAppendingKeyPath:description.name];
    info.value = [root.value valueForKeyPath:childPath];
    info.children = [self generateChildrenOfKnobRecursively:info atPath:childPath ofRoot:root];
    
    return info;
}

- (NSArray*)generateChildrenOfKnobRecursively:(EKNKnobInfo *)knobInfo atPath:(NSString*)path ofRoot:(EKNKnobInfo*)root {
    if(knobInfo.propertyDescription.type == EKNPropertyTypeGroup) {
        return [knobInfo.propertyDescription.parameters[@(EKNPropertyGroupChildren)] map:^id(EKNPropertyDescription* description) {
            return [self knobWithDescription:description atPath:path ofRoot:root];
        }];
    }
    else {
        return [NSArray array];
    }
}

- (NSArray*)generateChildrenOfKnobRecursively:(EKNKnobInfo*)knobInfo {
    return [self generateChildrenOfKnobRecursively:knobInfo atPath:@"" ofRoot:knobInfo];
}

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
    [tableView registerNib:[[NSNib alloc] initWithNibNamed:@"EKNKnobGroupHeader" bundle:nil] forIdentifier:[EKNPropertyDescription nameForType:EKNPropertyTypeGroup]];
}

- (CGFloat)editorHeightWithDescription:(EKNPropertyDescription*)description {
    switch (description.type) {
        // TODO read these from the relevant classes
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
        case EKNPropertyTypeGroup: return 30;
    }
}

@end
