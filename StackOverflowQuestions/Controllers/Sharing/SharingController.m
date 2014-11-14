//
// Created by Aztec on 14.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "SharingController.h"


@implementation SharingController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    self.sharingTextView.text = self.sharingText;
}

#pragma mark - Button actions methods

- (IBAction)doneButtonPressed:(id)sender;
{
    if([self.delegate respondsToSelector:@selector(sharingDoneButtonPressed:)]) {
        [self.delegate sharingDoneButtonPressed:self];
    }
}

- (IBAction)cancelButtonPressed:(id)sender;
{
    if([self.delegate respondsToSelector:@selector(sharingCancelButtonPressed:)]) {
        [self.delegate sharingCancelButtonPressed:self];
    }
}

@end