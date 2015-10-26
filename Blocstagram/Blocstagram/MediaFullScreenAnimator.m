#import "MediaFullScreenAnimator.h"
#import "MediaFullScreenViewController.h"

@implementation MediaFullScreenAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return .5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]; // #10
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]; // #11

	//	it's recommended to use this instead of fetching toViewController.view
	//	because UIKit may have hidden wrapper views are not equal to .view
	//	this viewForKey: methods returns the view UIKit will use in the transition
	UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
	UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];

    if (self.presenting) {
		//	since presenting a VC wrapper in NC, first unwrap that hierarchy
		//	NC
		UINavigationController *toNC = (UINavigationController *)toViewController;
		//	full screen VC
        MediaFullScreenViewController *fsVC = (MediaFullScreenViewController *)toNC.topViewController; // #12

		//	from view is always automatically added to transition container
		//	so now only add toView
        [transitionContext.containerView addSubview:toView];
        
		CGRect startFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
//        CGRect startFrame = [fromView convertRect:self.cellImageView.frame fromView:self.cellImageView.superview]; // #15
		//	end frame is actual ending _to_frame that UIKit has already calculated, so first save that value
		CGRect endFrame = toView.frame;

		//	and then set the calculated start frame
        toView.frame = startFrame;

		//	make sure that imageview is properly shown (if this is not done, it will be 0-rect)
		CGRect f = startFrame;
		fsVC.imageView.frame = f;

		//	hide the navigation bar until transition is over
		[toNC setNavigationBarHidden:YES];

		//	temporary remove the background color for the toView
		fsVC.scrollView.backgroundColor = [UIColor clearColor];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
			toView.frame = endFrame;
			CGRect f = fsVC.imageView.frame;
			f.size.height = endFrame.size.height;
			f.size.width = endFrame.size.height;
			fsVC.imageView.frame = f;

		} completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
			fsVC.scrollView.backgroundColor = [UIColor whiteColor];
			//	reveal navigation bar, with fade-in animation
			[toNC setNavigationBarHidden:NO animated:YES];
			//	center image
			[fsVC centerScrollView];
        }];

	} else {	//	dismissing

		UINavigationController *fromNC = (UINavigationController *)fromViewController;
//		//	full screen VC
		MediaFullScreenViewController *fsVC = (MediaFullScreenViewController *)fromNC.topViewController;

        CGRect endFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];

		[transitionContext.containerView addSubview:toView];
		//	hijack the full screen image view and add it to the transition container
		[transitionContext.containerView addSubview:fsVC.imageView];

		//	hide the navigation bar with animation (it fades out)
		[fromNC setNavigationBarHidden:YES animated:YES];
		//	hide original view, we don't need it since we hijacked the image view we are interested in
		fromView.hidden = YES;

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
			fsVC.imageView.frame = endFrame;
			toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;

		} completion:^(BOOL finished) {
			[fsVC.imageView removeFromSuperview];	//	remove the hijacked image view
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
