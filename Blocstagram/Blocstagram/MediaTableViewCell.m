#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "LikeButton.h"
#import "LikesLabelView.h"
#import "ComposeCommentView.h"

@interface MediaTableViewCell () <UIGestureRecognizerDelegate, ComposeCommentViewDelegate>

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *twoFingerPress;
@property (nonatomic, strong) LikeButton *likeButton;
@property (nonatomic,strong) LikesLabelView *likesLabelView;
@property (nonatomic,strong) UILabel *likesLabel;
@property (nonatomic,strong) NSString *testString;

@property (nonatomic, strong) ComposeCommentView *commentView;

@property (nonatomic, strong) NSArray *horizontallyRegularConstraints;
@property (nonatomic, strong) NSArray *horizontallyCompactConstraints;

@end


static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;
static UIColor *orangeText;
static NSParagraphStyle *rightAlignParagraphStyle;


@implementation MediaTableViewCell

// need to do everytime you subclass, designated initializer for tableview cell
// not required, called by default
// but if you have a complex cell this is where you initialize stuff, where layout is created
// if you use Xib you do this in interface builder
//init a good place to add constraints
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    //manually create layout
    if (self) {
        self.mediaImageView = [[UIImageView alloc] init];
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.twoFingerPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPress:)];
        [self.twoFingerPress setNumberOfTouchesRequired:2];
        self.twoFingerPress.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.twoFingerPress];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        self.likesLabelView = [[LikesLabelView alloc] init];
        self.likesLabelView.backgroundColor = usernameLabelGray;
        
        self.likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        self.likesLabel.font = lightFont;
        self.likesLabel.numberOfLines = 0;
        self.likesLabel.textColor = [UIColor blackColor];
        self.likesLabel.backgroundColor = usernameLabelGray;
        
        self.commentView = [[ComposeCommentView alloc] init];
        self.commentView.delegate = self;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.likesLabelView, self.likesLabel, self.commentView]) {
            [self.contentView addSubview:view];
            
            // need to disable when using constraints
            view.translatesAutoresizingMaskIntoConstraints = NO; //causes frames to be ignored
        }
        
        //add constraints
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _likesLabelView, _likesLabel, _commentView);
        
        self.horizontallyCompactConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320];
        NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:0
                                                                               toItem:_mediaImageView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1
                                                                             constant:0];
        
        self.horizontallyRegularConstraints = @[widthConstraint, centerConstraint];
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            /* It's compact! */
            [self.contentView addConstraints:self.horizontallyCompactConstraints];
        } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            /* It's regular! */
            [self.contentView addConstraints:self.horizontallyRegularConstraints];
        }
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likesLabelView(==38)][_likeButton(==38)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentView]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.likesLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.likeButton.spinnerView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.likesLabel
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.likesLabelView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:0]];
        
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        
        self.imageHeightConstraint.identifier = @"Image height constraint";
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
        
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Username and caption label height constraint";
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
        
        self.commentLabelHeightConstraint.identifier = @"Comment label height constraint";
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
    }
    return self;
}

- (NSAttributedString *) likesLabelString {
    
    CGFloat usernameFontSize = 10;
    
    //IG count is an NSNumber that has to be converted to an int in this way, you can't use stringValue method of NSNumber for some reason
    NSString *baseString = [NSString stringWithFormat:@"%@", self.mediaItem.likeCount];
    
    NSMutableAttributedString *labelString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : rightAlignParagraphStyle}];
    
    return labelString;
    
}

- (NSAttributedString *) usernameAndCaptionString {
    
    // #1
    CGFloat usernameFontSize = 15;
    
    //two step process: (1) create simple string (2) use range to style different things differently
    
    // #2 - Make a string that says "username caption"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // #3 - Make an attributed string, with the "username" bold
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    // #4
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    //change caption kerning
    NSRange captionRange = [baseString rangeOfString:self.mediaItem.caption];
    [mutableUsernameAndCaptionString addAttribute:NSKernAttributeName value:@3.0 range:captionRange];
    
    return mutableUsernameAndCaptionString;
}

- (NSAttributedString *) commentString {
    
    //__block NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    int counter = 0;
    
    //    [self.mediaItem.comments enumerateObjectsUsingBlock:^(Comment *comment, NSUInteger counter, BOOL * _Nonnull stop) {
    //
    //    }]
    
    for (Comment *comment in self.mediaItem.comments) {
        // Make a string that says "username comment" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        // Make an attributed string, with the "username" bold
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        if (counter==0) { //color first comment orange
            NSRange orangeTextRange = [baseString rangeOfString:baseString];
            [oneCommentString addAttribute:NSForegroundColorAttributeName value:orangeText range:orangeTextRange];
        }
        
        if (counter%2 == 0) { //right align every other comment
            NSRange rightAlignRange = [baseString rangeOfString:baseString];
            [oneCommentString addAttribute:NSParagraphStyleAttributeName value:rightAlignParagraphStyle range:rightAlignRange];
        }
        
        counter++;
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}

// + class method
// static variales at top, you need to initialize those
// called only once, populate static variables
// do anything here that is needed once for all cells
// if you use interface builder you don't need this
// especially constraints
+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1]; /*#58506d*/
    orangeText = [UIColor colorWithRed:(255/255.0) green:(69/255.0) blue:(0/255.0) alpha:1];
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    //right align paragraph style
    NSMutableParagraphStyle *mutableRightAlignParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableRightAlignParagraphStyle.headIndent = 20.0;
    mutableRightAlignParagraphStyle.firstLineHeadIndent = 20.0;
    mutableRightAlignParagraphStyle.tailIndent = -20.0;
    mutableRightAlignParagraphStyle.paragraphSpacingBefore = 5;
    mutableRightAlignParagraphStyle.alignment = NSTextAlignmentRight;
    
    rightAlignParagraphStyle = mutableRightAlignParagraphStyle;
    
    paragraphStyle = mutableParagraphStyle;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}

// default method to control selecting cell visual display
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // Before layout, calculate the intrinsic size of the labels (the size they "want" to be), and add 20 to the height for some vertical padding.
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height == 0 ? 0 : usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height == 0 ? 0 : commentLabelSize.height + 20;
    
    if (self.mediaItem.image.size.width > 0 && CGRectGetWidth(self.contentView.bounds) > 0) {
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            /* It's compact! */
            self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
        } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            /* It's regular! */
            self.imageHeightConstraint.constant = 320;
        }
    } else {
        self.imageHeightConstraint.constant = 0;
    }
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);
}

- (void) traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        /* It's compact! */
        [self.contentView removeConstraints:self.horizontallyRegularConstraints];
        [self.contentView addConstraints:self.horizontallyCompactConstraints];
    } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        /* It's regular */
        [self.contentView removeConstraints:self.horizontallyCompactConstraints];
        [self.contentView addConstraints:self.horizontallyRegularConstraints];
    }
}

- (void) setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaItem.likeState;
    self.commentView.text = mediaItem.temporaryComment;
    self.likesLabel.attributedText = [self likesLabelString];
}

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width traitCollection:(UITraitCollection *) traitCollection {
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    layoutCell.mediaItem = mediaItem;

    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    layoutCell.overrideTraitCollection = traitCollection;
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.commentView.frame);
}

- (UITraitCollection *) traitCollection {
    if (self.overrideTraitCollection) {
        return self.overrideTraitCollection;
    }
    
    return [super traitCollection];
}

#pragma mark - Liking

- (void) likePressed:(UIButton *)sender {
    [self.delegate cellDidPressLikeButton:self];
}

#pragma mark - Image View

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.isEditing == NO;
}

//long press sharing
- (void) longPressFired:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

//retry image download
- (void) twoFingerPress:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self twoFingerPressImageView:self.mediaImageView];
}

#pragma mark - ComposeCommentViewDelegate

- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender {
    [self.delegate cell:self didComposeComment:self.mediaItem.temporaryComment];
}

- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text {
    self.mediaItem.temporaryComment = text;
}

- (void) commentViewWillStartEditing:(ComposeCommentView *)sender {
    [self.delegate cellWillStartComposingComment:self];
}

- (void) stopComposingComment {
    [self.commentView stopComposingComment];
}

@end