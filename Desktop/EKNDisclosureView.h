//
//  EKNDisclosureView.h
//  Knobs
//
//  Created by Akiva Leffert on 12/23/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol EKNDisclosureViewDelegate;

@interface EKNDisclosureView : NSView

@property (strong, nonatomic) id <EKNDisclosureViewDelegate> delegate;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSView* disclosedView;
@property (assign, nonatomic) BOOL showsTopDivider;

@property (assign, nonatomic) BOOL disclosed;

@end

@protocol EKNDisclosureViewDelegate <NSObject>

- (void)disclosureViewOpened:(EKNDisclosureView*)disclosureView;
- (void)disclosureViewClosed:(EKNDisclosureView*)disclosureView;

@end