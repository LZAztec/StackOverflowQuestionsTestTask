/*
 * Copyright (c) 2011-2014 Matthijs Hollemans
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "UIViewController+MHSemiModal.h"

@implementation UIViewController (MHSemiModal)

- (UIView *)mh_coverViewForViewController:(UIViewController *)viewController
{
	return [viewController.parentViewController.view viewWithTag:kCoverViewTag];
}

- (void)mh_presentSemiModalViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    CGRect bounds = self.view.bounds;
    
	UIView *coverView = [[UIView alloc] initWithFrame:bounds];
    NSLog(@"boubds: %@", NSStringFromCGRect(self.view.bounds));
	coverView.backgroundColor = [UIColor blackColor];
	coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	coverView.alpha = 0.0;
	coverView.tag = kCoverViewTag;
	[self.view addSubview:coverView];

	CGRect rect = bounds;
	rect.origin.y += rect.size.height;
	viewController.view.frame = rect;
	[self.view addSubview:viewController.view];

	[self addChildViewController:viewController];

	if (animated)
	{
		[UIView animateWithDuration:0.3 animations:^
		{
			[self mh_afterPresentAnimation:viewController];
		}];
	}
	else
	{
		[self mh_afterPresentAnimation:viewController];
	}
}

- (void)mh_afterPresentAnimation:(UIViewController *)viewController
{
    CGRect bounds = self.view.bounds;
    
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        bounds.origin.y -= bounds.origin.y/2;
    }
    
    viewController.view.frame = bounds;

	UIView *coverView = [self mh_coverViewForViewController:viewController];
	coverView.alpha = 0.5;

	[viewController didMoveToParentViewController:self];

    if ([self conformsToProtocol:@protocol(MHDeviceOrientationChangeProtocol)]){
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
    }
}

- (void)mh_dismissSemiModalViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[viewController willMoveToParentViewController:nil];

	if (animated)
	{
		[UIView animateWithDuration:0.3 animations:^
		{
			CGRect rect = viewController.view.bounds;
			rect.origin.y += rect.size.height;
			viewController.view.frame = rect;

			UIView *coverView = [self mh_coverViewForViewController:viewController];
			coverView.alpha = 0.0;
		}
		completion:^(BOOL finished)
		{
			[self mh_afterDismissAnimation:viewController];
		}];
	}
	else
	{
		[self mh_afterDismissAnimation:viewController];
	}
}

- (void)mh_afterDismissAnimation:(UIViewController *)viewController
{
	UIView *coverView = [self mh_coverViewForViewController:viewController];
	[coverView removeFromSuperview];

	[viewController removeFromParentViewController];
	[viewController.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
