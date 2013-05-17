//
//  EKNPropertyEditor.h
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNPropertyInfo;
@class EKNPropertyDescription;

@protocol EKNPropertyEditor;

@protocol EKNPropertyEditorDelegate <NSObject>

- (void)propertyEditor:(id <EKNPropertyEditor>)editor changedProperty:(EKNPropertyDescription*)property toValue:(id)value;

@end

@protocol EKNPropertyEditor <NSObject>

@property (weak, nonatomic) id <EKNPropertyEditorDelegate> delegate;
@property (strong, nonatomic) EKNPropertyInfo* info;

@end
