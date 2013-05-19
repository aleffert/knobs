//
//  EKNLiveKnobsViewController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/19/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLiveKnobsViewController.h"

#import "EKNLiveKnobs.h"
#import "EKNKnobGeneratorView.h"
#import "EKNKnobInfo.h"

@interface EKNLiveKnobsViewController () <EKNKnobGeneratorViewDelegate>

@property (strong, nonatomic) IBOutlet EKNKnobGeneratorView* knobsView;
@property (strong, nonatomic) id <EKNChannel> channel;
@property (strong, nonatomic) id <EKNConsoleControllerContext> context;

@end

@implementation EKNLiveKnobsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)connectedToDeviceWithContext:(id<EKNConsoleControllerContext>)context onChannel:(id<EKNChannel>)channel {
}

- (void)processAddKnobMessage:(NSDictionary*)message {
    NSString* uuid = [message objectForKey:@(EKNLiveKnobsAddIDKey)];
    id value = [message objectForKey:@(EKNLiveKnobsAddInitialValueKey)];
    EKNPropertyDescription* propertyDescription = [message objectForKey:@(EKNLiveKnobsAddDescriptionKey)];
    // References lazily since it's added by the app itself
    EKNKnobInfo* knob = [NSClassFromString(@"EKNKnobInfo") knob];
    knob.knobID = uuid;
    knob.value = value;
    knob.propertyDescription = propertyDescription;
    
    [self.knobsView addKnob:knob];
}

- (void)processUpdateKnobMessage:(NSDictionary*)message {
    NSString* uuid = [message objectForKey:@(EKNLiveKnobsUpdateIDKey)];
    id value = [message objectForKey:@(EKNLiveKnobsUpdateCurrentValueKey)];
    [self.knobsView updateKnobWithID:uuid toValue:value];
}

- (void)processRemoveKnobMessage:(NSDictionary*)message {
    NSString* knobID = [message objectForKey:@(EKNLiveKnobsRemoveIDKey)];
    [self.knobsView removeKnobWithID:knobID];
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSUInteger messageType = [[message objectForKey:EKNLiveKnobsSentMessageKey] unsignedIntegerValue];
    switch (messageType) {
        case EKNLiveKnobsMessageAddKnob:
            [self processAddKnobMessage:message];
            break;
        case EKNLiveKnobsMessageUpdateKnob:
            [self processUpdateKnobMessage:message];
            break;
        case EKNLiveKnobsMessageRemoveKnob:
            [self processRemoveKnobMessage:message];
            break;
    }
}

- (void)disconnectedFromDevice {
    // TODO
}

- (void)generatorView:(EKNKnobGeneratorView *)view changedKnob:(EKNKnobInfo *)knob {
    NSString* uuid = knob.knobID;
    NSDictionary* message = @{EKNLiveKnobsSentMessageKey: @(EKNLiveKnobsMessageUpdateKnob),
                              @(EKNLiveKnobsUpdateCurrentValueKey) : knob.value,
                              @(EKNLiveKnobsUpdateIDKey) : uuid };
    NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.context sendMessage:archive onChannel:self.channel];
}

@end
