//
//  EKNLoggerViewController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLoggerViewController.h"
#import "EKNWireImage.h"
#import "EKNDOMRepresentation.h"

#import <WebKit/WebKit.h>

@interface EKNLoggerViewController ()

@property (strong, nonatomic) id <EKNChannel> channel;
@property (strong, nonatomic) IBOutlet WebView* webView;

@end

@implementation EKNLoggerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)connectedToDeviceWithContext:(id<EKNConsoleControllerContext>)context onChannel:(id<EKNChannel>)channel {
    self.channel = channel;
    self.title = channel.name;
}

- (void)loadView {
    [super loadView];
    [self.webView.mainFrame loadHTMLString:@"<html><head></head><body><table id=\"mainTable\"></table></body></html>" baseURL:nil];
}

- (void)addRowToLog:(NSArray*)row {
    DOMDocument* document = self.webView.mainFrame.DOMDocument;
    DOMNode *table = [document getElementById:@"mainTable"];
    
    // Create a new element, with a tag name
    DOMHTMLElement *tr = (DOMHTMLElement*)[document createElement:@"tr"];
    for(id <EKNDOMRepresentation> item in row) {
        DOMHTMLElement* td = (DOMHTMLElement*)[document createElement:@"td"];
        [td appendChild:[item DOMRepresentationInDocument:document]];
        [tr appendChild:td];
    }
    [table appendChild:tr];
    [tr scrollIntoView:YES];
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray* row = [unarchiver decodeObjectForKey:@"root"];
    [self addRowToLog:row];
}

- (void)disconnectedFromDevice {
    // TODO
}

@end
