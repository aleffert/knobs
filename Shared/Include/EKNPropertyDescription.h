//
//  EKNPropertyDescription.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* EKNPropertyTypeString;

extern NSString* EKNPropertyTypeColor;
enum {
    EKNPropertyColorWrapCG
};

extern NSString* EKNPropertyTypeToggle;
extern NSString* EKNPropertyTypeSlider;

enum {
    EKNPropertySliderMin,
    EKNPropertySliderMax,
    EKNPropertySliderContinuous,
};

extern NSString* EKNPropertyTypeImage;
enum {
    EKNPropertyImageWrapCG
};

extern NSString* EKNPropertyTypeFloatQuad;
enum {
    EKNPropertyFloatQuadFieldNames,
    EKNPropertyFloatQuadKeyOrder
};

enum {
    EKNFloatQuadKeyOrderRect,
    EKNFloatQuadKeyOrderEdgeInsets,
};

extern NSString* EKNPropertyTypeFloatPair;
enum {
    EKNPropertyFloatPairFieldNames
};

extern NSString* EKNPropertyTypeAffineTransform;

@interface EKNPropertyDescription : NSObject <NSCoding>

+ (EKNPropertyDescription*)propertyWithName:(NSString*)name type:(NSString*)type parameters:(NSDictionary*)parameters;
+ (EKNPropertyDescription*)stringPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG;
+ (EKNPropertyDescription*)togglePropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)continuousSliderPropertyWithName:(NSString*)name min:(CGFloat)min max:(CGFloat)max;
+ (EKNPropertyDescription*)imagePropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG;
+ (EKNPropertyDescription*)rectPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)edgeInsetsPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)pointPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)sizePropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)affineTransformPropertyWithName:(NSString*)name;

@property (readonly, copy) NSString* name;
@property (readonly, copy) NSString* type;
@property (readonly, copy) NSDictionary* parameters;

- (id)wrappedValueFromSource:(id)source;
- (void)setWrappedValue:(id)wrapped ofSource:(id)source;
- (id)valueWithWrappedValue:(id)wrappedValue;

@end
