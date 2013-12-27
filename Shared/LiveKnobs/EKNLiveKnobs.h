//
//  EKNLiveKnobs.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* EKNLiveKnobsSentMessageKey;

enum {
    EKNLiveKnobsMessageAddKnob,
    EKNLiveKnobsMessageUpdateKnob,
    EKNLiveKnobsMessageRemoveKnob,
};

// EKNLiveKnobsMessageAddKnob
enum {
    EKNLiveKnobsAddIDKey,
    EKNLiveKnobsAddDescriptionKey,
    EKNLiveKnobsAddInitialValueKey,
    EKNLiveKnobsPathKey,
};

// EKNLiveKnobsMessageUpdateKnob
enum {
    EKNLiveKnobsUpdateIDKey,
    EKNLiveKnobsUpdateCurrentValueKey,
};

// EKNLiveKnobsMessageRemoveKnob
enum {
    EKNLiveKnobsRemoveIDKey
};
