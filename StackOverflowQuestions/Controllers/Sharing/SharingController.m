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

- (void)mh_presentSemiModalViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    [super mh_presentSemiModalViewController:viewController animated:animated];
}

- (void)mh_dismissSemiModalViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    [super mh_dismissSemiModalViewController:viewController animated:animated];
}

@end