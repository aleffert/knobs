//
//  EKNDOMRepresentation.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDOMRepresentation.h"


@implementation NSObject (EKNDOMRepresentation)

- (DOMHTMLElement*)DOMRepresentationInDocument:(DOMDocument*)document {
    // TODO deal with html escaping
    DOMHTMLElement* span = (DOMHTMLElement*)[document createElement:@"span"];
    [span setInnerHTML:[self description]];
    return span;
}

@end

@implementation NSString (EKNDOMRepresentation)

- (DOMHTMLElement*)DOMRepresentationInDocument:(DOMDocument*)document {
    // TODO deal with html escaping
    DOMHTMLElement* span = (DOMHTMLElement*)[document createElement:@"span"];
    [span setInnerHTML:self];
    return span;
}

@end