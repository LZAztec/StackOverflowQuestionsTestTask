//
// Created by Aztec on 14.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MHSemiModal.h"

@protocol SharingControllerDelegate;

@interface SharingController : UIViewController

@property (strong, nonatomic) NSString *sharingText;
@property (weak, nonatomic) IBOutlet UITextView *sharingTextView;
@property (weak) id<SharingControllerDelegate> delegate;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@protocol SharingControllerDelegate <NSObject>

@required
- (void)sharingDoneButtonPressed:(SharingController *)sender;
- (void)sharingCancelButtonPressed:(SharingController *)sender;

@end
