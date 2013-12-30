//
//  EKNSourceManager.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNPropertyDescription;

@interface EKNSourceManager : NSObject

+ (EKNSourceManager*)sharedManager;

- (BOOL)saveCode:(NSString*)code withDescription:(EKNPropertyDescription*)description toFileAtPath:(NSString*)path error:(__autoreleasing NSError**)error;

/// Returns YES if the save failed
- (BOOL)saveValue:(id)value withDescription:(EKNPropertyDescription*)description toFileAtPath:(NSString*)path error:(__autoreleasing NSError**)error;

@end
