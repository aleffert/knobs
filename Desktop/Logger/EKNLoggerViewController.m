//
//  EKNLoggerViewController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLoggerViewController.h"
#import "EKNWireImage.h"

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
    DOMDocument* document = self.webView.mainFrame.DOMDocument;
    document.body.innerHTML = @"<style type=\"text/css\"> tr:nth-child(even) { background-color: #D2E7FF }</style><table id=\"mainTable\" style=\"width:100%; font-family: Menlo;\"></table>";
}

- (void)addRowToLog:(NSString*)row {
    DOMDocument* document = self.webView.mainFrame.DOMDocument;
    DOMNode *table = [document getElementById:@"mainTable"];
    
    // Create a new element, with a tag name
    DOMHTMLElement *tr = (DOMHTMLElement*)[document createElement:@"tr"];
    DOMHTMLElement* td = (DOMHTMLElement*)[document createElement:@"td"];
    td.innerHTML = row;
    [tr appendChild:td];
    [table appendChild:tr];
    [tr scrollIntoView:YES];
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSString* row = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self addRowToLog:row];
}

- (void)disconnectedFromDevice {
    // TODO. Show something useful
}

@end
