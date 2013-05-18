//
//  EKNPropertyDescription.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO decide whether it's actually a good idea to use int keys
NSString* EKNPropertyTypeColor;
enum {
    EKNPropertyColorWrapCG
};

NSString* EKNPropertyTypeToggle;
NSString* EKNPropertyTypeSlider;

enum {
    EKNPropertySliderMin,
    EKNPropertySliderMax,
    EKNPropertySliderContinuous,
};

NSString* EKNPropertyTypeImage;
enum {
    EKNPropertyImageWrapCG
};

NSString* EKNPropertyTypeRect;
NSString* EKNPropertyTypeFloatPair;
NSString* EKNPropertyTypeAffineTransform;

enum {
    EKNPropertyFloatPairFieldNames
};

@interface EKNPropertyDescription : NSObject <NSCoding>

+ (EKNPropertyDescription*)propertyWithName:(NSString*)name type:(NSString*)type parameters:(NSDictionary*)parameters;
+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)colorPropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG;
+ (EKNPropertyDescription*)togglePropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)continuousSliderPropertyWithName:(NSString*)name min:(CGFloat)min max:(CGFloat)max;
+ (EKNPropertyDescription*)imagePropertyWithName:(NSString*)name wrapCG:(BOOL)wrapCG;
+ (EKNPropertyDescription*)rectPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)pointPropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)sizePropertyWithName:(NSString*)name;
+ (EKNPropertyDescription*)affineTransformPropertyWithName:(NSString*)name;

@property (readonly, copy) NSString* name;
@property (readonly, copy) NSString* type;
@property (readonly, copy) NSDictionary* parameters;

- (id)getValueFromSource:(id)source;
- (void)setValue:(id)value ofSource:(id)source;

@end
