//
//  EKNPropertyDescription.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EKNPropertyType) {
    EKNPropertyTypeAffineTransform,
    EKNPropertyTypeColor,
    EKNPropertyTypeImage,
    EKNPropertyTypeFloatPair,
    EKNPropertyTypeFloatQuad,
    EKNPropertyTypePushButton,
    EKNPropertyTypeSlider,
    EKNPropertyTypeString,
    EKNPropertyTypeToggle,
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
+ (EKNPropertyDescription*)pushButtonPropertyWithName:(NSString*)name;
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

/// Returns a string describing the type
+ (NSString*)nameForType:(EKNPropertyType)type;

@property (readonly, nonatomic, copy) NSString* name;
@property (readonly, nonatomic, assign) EKNPropertyType type;
/// Same as calling nameForType: on the object's type
@property (readonly, nonatomic, strong) NSString* typeName;
/// Type specific parameters
@property (readonly, nonatomic, copy) NSDictionary* parameters;

/// Converts property values to the right objective-c objects
/// Primarily used to wrap up CG values
- (id)wrappedValueFromSource:(id)source;

///
- (void)setWrappedValue:(id)wrapped ofSource:(id)source;
- (id)valueWithWrappedValue:(id)wrappedValue;

@end
