//
//  ENKWireImage+ENKDOMRepresentation.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "ENKWireImage+ENKDOMRepresentation.h"

#import "EKNDOMRepresentation.h"
#import "NSData+Base64.h"

#import <openssl/bio.h>

@implementation EKNWireImage (ENKDOMRepresentation)

- (DOMHTMLElement*)DOMRepresentationInDocument:(DOMDocument*)document {
    // TODO deal with html escaping
    DOMHTMLElement* img = (DOMHTMLElement*)[document createElement:@"img"];
    NSString* encodedImageData = [self.data base64EncodedString];
    NSString* dataValue = [NSString stringWithFormat:@"data:image/png;base64,%@", encodedImageData];
    [img setAttribute:@"src" value:dataValue];
    return img;
}

@end
