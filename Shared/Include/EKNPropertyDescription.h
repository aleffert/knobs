//
//  EKNPropertyDescription.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EKNPropertyType) {
    EKNPropertyTypeGroup,
    EKNPropertyTypeAffineTransform,
    EKNPropertyTypeColor,
    EKNPropertyTypeFloat,
    EKNPropertyTypeFloatPair,
    EKNPropertyTypeFloatQuad,
    EKNPropertyTypeImage,
    EKNPropertyTypeInt,
    EKNPropertyTypePushButton,
    EKNPropertyTypeSlider,
    EKNPropertyTypeString,
    EKNPropertyTypeToggle,
};

typedef NS_ENUM(NSUInteger, EKNPropertyGroupOptions) {
    EKNPropertyGroupChildren,
    EKNPropertyGroupClassName
};

typedef NS_ENUM(NSUInteger, EKPropertyColorOptions) {
    EKNPropertyColorWrapCG
};

typedef NS_ENUM (NSUInteger, EKNPropertyFloatPairOptions) {
    EKNPropertyFloatPairFieldNames,
    EKNPropertyFloatPairConstructorPrefix
};

typedef NS_ENUM(NSUInteger, EKNPropertyFloatQuadOptions) {
    EKNPropertyFloatQuadFieldNames,
    EKNPropertyFloatQuadKeyOrder,
    EKNPropertyFloatQuadConstructorPrefix
};

typedef NS_ENUM(NSUInteger, EKNFloatQuadKeyOrder) {
    EKNFloatQuadKeyOrderRect,
    EKNFloatQuadKeyOrderEdgeInsets,
};

typedef NS_ENUM (NSUInteger, EKPropertyImageOptions) {
    EKNPropertyImageWrapCG
};

typedef NS_ENUM (NSUInteger, EKPropertySliderOptions) {
    EKNPropertySliderMin,
    EKNPropertySliderMax,
    EKNPropertySliderContinuous,
};

@interface EKNPropertyDescription : NSObject <NSCoding>

+ (EKNPropertyDescription*)propertyWithName:(NSString*)name type:(EKNPropertyType)type parameters:(NSDictionary*)parameters;

/// Use this to make an aggregate property
/// @param properties An array of EKNPropertyDescriptions
+ (EKNPropertyDescription*)groupPropertyWithName:(NSString*)name properties:(NSArray*)properties class:(Class)class;

+ (EKNPropertyDescription*)affineTransformPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG;
+ (EKNPropertyDescription*)continuousSliderPropertyWithName:(NSString*)name min:(CGFloat)min max:(CGFloat)max;
+ (EKNPropertyDescription*)edgeInsetsPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)floatPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)imagePropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)imagePropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG;
+ (EKNPropertyDescription*)intPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)pointPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)pushButtonPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)rectPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)sizePropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)stringPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)togglePropertyWithName:(NSString*)name;

/// Returns a string describing the type
+ (NSString*)nameForType:(EKNPropertyType)type;

/// Description of the property
@property (readonly, nonatomic, copy) NSString* name;
/// Property type for editor
@property (readonly, nonatomic, assign) EKNPropertyType type;
/// Same as calling nameForType: on the object's type
@property (readonly, nonatomic, strong) NSString* typeName;
/// Type specific parameters
@property (readonly, nonatomic, copy) NSDictionary* parameters;

- (BOOL)isTypeEquivalentToTypeOfDescription:(EKNPropertyDescription*)description;

@end
