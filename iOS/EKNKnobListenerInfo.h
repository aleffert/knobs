//
//  EKNKnobListenerInfo.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNPropertyDescription;

@protocol EKNListenerInfoDelegate;

@interface EKNKnobListenerInfo : NSObject

@property (weak, nonatomic) id <EKNListenerInfoDelegate> delegate;
@property (weak, nonatomic) id owner;
@property (copy, nonatomic) NSString* uuid;
@property (copy, nonatomic) void (^callback)(id owner, id value);
@property (strong, nonatomic) EKNPropertyDescription* propertyDescription;
@property (copy, nonatomic) NSString* sourcePath;
@property (copy, nonatomic) NSString* label;
@property (copy, nonatomic) NSString* externalCode;

@end


@protocol EKNListenerInfoDelegate <NSObject>

- (void)listenerCancelled:(EKNKnobListenerInfo*)info;

@end