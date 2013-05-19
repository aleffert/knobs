//
//  EKNWireColor+EKNDOMRepresentation.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNWireColor+EKNDOMRepresentation.h"

@implementation EKNWireColor (EKNDOMRepresentation)

//TODO treat opacity in a less stupid way. e.g. the triangles in the color picker or an underlying grid pattern
- (DOMHTMLElement*)DOMRepresentationInDocument:(DOMDocument *)document {
    DOMHTMLElement* span = (DOMHTMLElement*)[document createElement:@"span"];
    [span setAttribute:@"style" value:[NSString stringWithFormat:@"width:1in; height:1in; display:block; background-color:rgb(%d, %d, %d); opacity : %f;", (int)round(255 * self.red), (int)round(255 * self.green),  (int)round(255 * self.blue), self.alpha]];
    return span;
}

@end
