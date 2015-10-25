#import "MediaFullScreenAnimator.h"
#import "MediaFullScreenViewController.h"

@implementation MediaFullScreenAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]; // #10
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]; // #11
    
    if (self.presenting) {
        MediaFullScreenViewController *fsNavViewController = (MediaFullScreenViewController *)toViewController; // #12
        
        fromViewController.view.userInteractionEnabled = NO; // #13
        
        [transitionContext.containerView addSubview:toViewController.view]; // #14
        
        CGRect startFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView]; // #15
        CGRect endFrame = fromViewController.view.frame; // #16
        
        toViewController.view.frame = startFrame;
        fsNavViewController.imageView.frame = toViewController.view.bounds;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            
            fsNavViewController.view.frame = endFrame;
            [fsNavViewController centerScrollView];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        MediaFullScreenViewController *fsNavViewController = (MediaFullScreenViewController *)fromViewController;
        
        CGRect endFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
        CGRect imageStartFrame = [fsNavViewController.view convertRect:fsNavViewController.imageView.frame fromView:fsNavViewController.scrollView];
        CGRect imageEndFrame = [transitionContext.containerView convertRect:endFrame toView:fsNavViewController.view];
        
        imageEndFrame.origin.y = 0;
        
        [fsNavViewController.view addSubview:fsNavViewController.imageView];
        fsNavViewController.imageView.frame = imageStartFrame;
        fsNavViewController.imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        
        toViewController.view.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fsNavViewController.view.frame = endFrame;
            fsNavViewController.imageView.frame = imageEndFrame;
            
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
