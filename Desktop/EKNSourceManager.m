//
//  EKNSourceManager.m
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNSourceManager.h"

#import "EKNPropertyDescription+EKNCodeConstruction.h"

@implementation EKNSourceManager

// This code is dumb as bricks.
// Long term we should consider picking up libclang
// Or at least write a slightly less dumb lexer
// Though it may not be worth the dependency/potential integration issues
- (BOOL)saveCode:(NSString*)code withKnobName:(NSString*)name toFileAtPath:(NSString*)path error:(__autoreleasing NSError**)error {
    NSString* fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:error];
    if(error && *error) {
        return YES;
    }
    
    NSString* pattern = [NSString stringWithFormat:@"(%@)([ \n\t\r]*)=([ \n\t\r]*)([^;]*)([ \n\t\r]*);", [NSRegularExpression escapedPatternForString:name]];
    
    NSRegularExpression* expression = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:error];
    if(error && *error) {
        return YES;
    }
    // substitute in a sentinal so that we don't have to escape the code when it goes into the template string
    NSString* template = [NSString stringWithFormat:@"$1$2=$3%@$5;", [NSRegularExpression escapedTemplateForString:code]];
    NSString* outContents = [expression stringByReplacingMatchesInString:fileContents options:0 range:NSMakeRange(0, fileContents.length) withTemplate:template];
    [outContents writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:error];
    if(error && *error) {
        return YES;
    }
    return NO;
}
- (BOOL)saveCode:(NSString*)code withDescription:(EKNPropertyDescription*)description toFileAtPath:(NSString*)path error:(__autoreleasing NSError**)error {
    return [self saveCode:code withKnobName:description.name toFileAtPath:path error:error];
}

- (BOOL)saveValue:(id)value withDescription:(EKNPropertyDescription*)description toFileAtPath:(NSString*)path error:(__autoreleasing NSError**)error {
    NSString* code = [description constructorCodeForValue:value];
    return [self saveCode:code withDescription:description toFileAtPath:path error:error];
}

@end
