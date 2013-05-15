//
//  EKNDOMRepresentation.h
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WebKit/WebKit.h>

@protocol EKNDOMRepresentation

- (DOMHTMLElement*)DOMRepresentationInDocument:(DOMDocument*)document;

@end

@interface NSObject (EKNDomRepresentation) <EKNDOMRepresentation>

@end

@interface NSString (EKNDOMRepresentation) <EKNDOMRepresentation>

@end