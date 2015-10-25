#import <UIKit/UIKit.h>

@class CircleSpinnerView;

typedef NS_ENUM(NSInteger, LikeState) {
    LikeStateNotLiked             = 0,
    LikeStateLiking               = 1,
    LikeStateLiked                = 2,
    LikeStateUnliking             = 3
};

@interface LikeButton : UIButton

@property (nonatomic, assign) LikeState likeButtonState;
@property (nonatomic, strong) CircleSpinnerView *spinnerView;

@end
