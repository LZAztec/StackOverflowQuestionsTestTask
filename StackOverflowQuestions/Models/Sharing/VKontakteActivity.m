//
//  VKontakteActivity.m
//  StackOverflowQuestions
//
//  Created by Aztec on 28.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "VKontakteActivity.h"
#import "SharingController.h"
#import "NSString+HTML.h"
#import "MBProgressHUD.h"
#import <VK-ios-sdk/VKSdk.h>

@interface VKontakteActivity () <VKSdkDelegate, SharingControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, weak) id <VKontakteActivityProtocol> parent;

@end

static NSString * kDefaultAppID= @"4574538";

@implementation VKontakteActivity

#pragma mark - NSObject

- (id)init
{
    NSAssert(false, @"You cannot init this class directly. Instead, use initWithParent");
    return nil;
}

- (id)initWithParent:(id<VKontakteActivityProtocol>)parent;
{
    if ((self = [super init])) {
        self.parent = parent;
        self.appID = kDefaultAppID;
    }

    return self;
}

#pragma mark - UIActivity

- (NSString *)activityType
{
    return @"VKActivityTypeVKontakte";
}

- (NSString *)activityTitle
{
    return @"VK";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:(iOS8) ? @"vk_activity_ios8" : @"vk_activity"];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}
#endif

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        } else if ([item isKindOfClass:[NSString class]]) {
            return YES;
        } else if ([item isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            self.string = self.string ? [NSString stringWithFormat:@"%@ %@", self.string, item] : item;
        } else if ([item isKindOfClass:[UIImage class]]) {
            self.image = item;
        } else if ([item isKindOfClass:[NSURL class]]) {
            self.URL = item;
        }
    }
    self.string = [self.string stringByDecodingHTMLEntities];
}

- (void)performActivity
{
    [VKSdk initializeWithDelegate:self andAppId:self.appID];
    if ([VKSdk wakeUpSession]) {
        [self startComposeViewController];
    } else {
        [VKSdk authorize:@[VK_PER_WALL]];
    }
}

#pragma mark - Upload

-(void)postToWall
{
    if (self.image) {
        [self uploadPhoto];
    } else {
        [self uploadText];
    }
}

- (void)uploadPhoto
{
    NSString *userId = [VKSdk getAccessToken].userId;
    VKRequest *request = [VKApi uploadWallPhotoRequest:self.image parameters:[VKImageParameters jpegImageWithQuality:1.f] userId:[userId integerValue] groupId:0];

    VKontakteActivity *__weak activity = self;

    [request executeWithResultBlock: ^(VKResponse *response) {
        VKPhoto *photoInfo = [(VKPhotoArray*)response.parsedModel objectAtIndex:0];
        NSString *photoAttachment = [NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id];
        [activity postToWall:@{
                VK_API_ATTACHMENTS : photoAttachment,
                VK_API_FRIENDS_ONLY : @(0),
                VK_API_OWNER_ID : userId,
                VK_API_MESSAGE : [NSString stringWithFormat:@"%@ %@",self.string, [self.URL absoluteString]]
        }];
    } errorBlock: ^(NSError *error) {
        NSLog(@"Error: %@", error);
        [activity activityDidFinish:NO];
    }];
}

-(void)uploadText
{
    [self postToWall:@{
            VK_API_FRIENDS_ONLY : @(0),
            VK_API_OWNER_ID : [VKSdk getAccessToken].userId,
            VK_API_MESSAGE : self.string,
            VK_API_ATTACHMENT: [self.URL absoluteString],
    }];
}

-(void)postToWall:(NSDictionary *)params
{
    VKRequest *post = [[VKApi wall] post:params];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self.parent viewForHUD] animated:YES];
    [self.parent enableUserInteraction:NO];

    hud.labelText = @"Processing...";
    hud.dimBackground = YES;

    VKontakteActivity *__weak activity = self;

    [post executeWithResultBlock:^(VKResponse *response) {
                [activity activityDidFinish:YES];
                [hud hide:YES];
                [activity.parent enableUserInteraction:YES];
            }
                      errorBlock:^(NSError *error) {
                          NSLog(@"Error: %@", error);
                          [activity activityDidFinish:NO];
                          [hud hide:YES];

                          if (error.code == -101){
                              [VKSdk forceLogout];
                              [activity showNeedAuthMessage];
                          } else {
                              [activity.parent enableUserInteraction:YES];
                          }
                      }];
}

- (void)showNeedAuthMessage {
    NSString *title = @"Access error.";
    NSString *message = @"Give acceess to post on the wall!";

    UIAlertView *alertMsg = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
    [alertMsg show];
}

#pragma mark - vkSdk

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:[self.parent controllerForVKCaptcha]];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    [VKSdk authorize:@[VK_PER_WALL, VK_PER_PHOTOS] revokeAccess:NO forceOAuth:NO inApp:YES display:VK_DISPLAY_IOS];
}

-(void)vkSdkReceivedNewToken:(VKAccessToken *)newToken
{
    [self startComposeViewController];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [self.parent showVKViewController:controller];
}

- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token
{
    [self startComposeViewController];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Access denied"
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
    [alertView show];

    [self activityDidFinish:NO];
}

-(void) startComposeViewController
{
    NSLog(@"Items to share: string %@, image %@, URL %@", self.string, self.image, self.URL);

    SharingController *sharingController = [[SharingController alloc] initWithNibName:@"SharingController" bundle:nil];
    sharingController.delegate = self;
    sharingController.sharingText = self.string;

    [self.parent enableUserInteraction:NO];
    [self.parent showModalController:sharingController];
}

- (void)sharingDoneButtonPressed:(SharingController *)sender {
    [self.parent dismissVKModalController:sender];
    self.string = sender.sharingTextView.text;
    [self postToWall];
    [self.parent enableUserInteraction:YES];
}

- (void)sharingCancelButtonPressed:(SharingController *)sender {
    [self.parent dismissVKModalController:sender];
    [self activityDidFinish:NO];
    [self.parent enableUserInteraction:YES];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == alertView.cancelButtonIndex){

    } else {
        [self performActivity];
    }
}

#pragma mark - Data manipulation methods
- (void)resetActivityData {
    self.string = nil;
    self.image = nil;
    self.URL = nil;
}
@end
