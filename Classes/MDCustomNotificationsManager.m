//
//  MDCustomNotificationsManager.m
//  BeAdict
//
//  Created by Thecafremo on 21/12/13.
//  Copyright (c) 2013 MagicDealers. All rights reserved.
//

#import "MDCustomNotificationsManager.h"

static CGFloat const kDefaultFontSize = 15;
static CGFloat const kDefaultButtonTitleFontSize = 13;

static CGFloat const kDefaultDisplayTimeInSeconds = 3;

static CGFloat const kDefaultVerticalMarginSize = 10;
static CGFloat const kDefaultHorizontalMarginSize = 10;

static CGFloat const kDefaultVerticalSpaceBetweenElements = 10;
static CGFloat const kDefaultHorizontalSpaceBetweenElements = 10;

static CGFloat const kDefaultPresentAnimationDuration = 0.2;

static CGFloat const kNotificationBackgroundAlpha = 0.9;


@interface MDCustomNotificationsManager ()

@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, strong) NSMutableArray *messagesQueueArray;

@property (nonatomic, strong) NSDictionary *iconImagesDictionary;
@property (nonatomic, strong) NSDictionary *backgroundColoursDictionary;

@property (nonatomic, copy) ActionCompletionBlock actualActionCompletionBlock;

@end

@implementation MDCustomNotificationsManager

#pragma mark LifeCycle.

- (id)init {
    
    if (self = [super init]) {
        
        self.messagesQueueArray = [NSMutableArray new];
        
        self.font = [UIFont boldSystemFontOfSize:kDefaultFontSize];
        self.buttonTitleFont = [UIFont systemFontOfSize:kDefaultButtonTitleFontSize];
        
        self.textColour = [UIColor whiteColor];
        
        self.displayTime = kDefaultDisplayTimeInSeconds;
        self.tapToDismissEnabled = YES;
        
        self.verticalMarginSize = kDefaultVerticalMarginSize;
        self.horizontalMarginSize = kDefaultHorizontalMarginSize;
        
        self.verticalSpaceBetweenElements = kDefaultVerticalSpaceBetweenElements;
        self.horizontalSpaceBetweenElements = kDefaultHorizontalSpaceBetweenElements;
    }
    
    return self;
}


+ (MDCustomNotificationsManager *)sharedInstance {
    
    static MDCustomNotificationsManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MDCustomNotificationsManager new];
    });
    
    return instance;
}


#pragma mark - Setters & Getters.

- (NSDictionary *)iconImagesDictionary {
    
    if (!_iconImagesDictionary) {
        
        _iconImagesDictionary = @{@(MDCustomNotificationTypeError): [UIImage imageNamed:@"icon-error.png"],
                                  @(MDCustomNotificationTypeSuccess): [UIImage imageNamed:@"icon-success.png"],
                                  @(MDCustomNotificationTypeInfo): [UIImage imageNamed:@"icon-info.png"],
                                  @(MDCustomNotificationTypeWarning): [UIImage imageNamed:@"icon-warning.png"]};
    }
    
    return _iconImagesDictionary;
}


- (NSDictionary *)backgroundColoursDictionary {
    
    if (!_backgroundColoursDictionary) {
        
        _backgroundColoursDictionary = @{@(MDCustomNotificationTypeError): [UIColor colorWithRed:0.826 green:0.154 blue:0.188 alpha:kNotificationBackgroundAlpha],
                                         @(MDCustomNotificationTypeSuccess): [UIColor colorWithRed:0.207 green:0.785 blue:0.289 alpha:kNotificationBackgroundAlpha],
                                         @(MDCustomNotificationTypeInfo): [UIColor colorWithWhite:0 alpha:kNotificationBackgroundAlpha],
                                         @(MDCustomNotificationTypeWarning): [UIColor colorWithRed:1.000 green:0.404 blue:0.141 alpha:kNotificationBackgroundAlpha],
                                         @(MDCustomNotificationTypeCustom): [UIColor blackColor]};
    }
    
    return _backgroundColoursDictionary;
}


#pragma mark Actions.

- (void)startPresentationProcess {
    
    MDNotificationMessage *notificationMessage = [self.messagesQueueArray objectAtIndex:0];
    self.actualActionCompletionBlock = notificationMessage.actionCompletionBlock;
    
    if (notificationMessage.displayTime) {
        self.displayTime = notificationMessage.displayTime;
    }
    
    self.notificationView = [[MDNotificationView alloc] initWithNotificationMessage:notificationMessage];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressAndHoldGesture:)];
    longPress.minimumPressDuration = 0.01;
    longPress.cancelsTouchesInView = NO;
    
    [self.notificationView addGestureRecognizer:longPress];
    
    [self presentNotification];
}


- (void)presentNotification {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.notificationView];
    self.notificationView.window.windowLevel = UIWindowLevelAlert;
    
    
    CGRect notificationFrame = self.notificationView.frame;
    notificationFrame.origin.y = 0;
    
    [UIView animateWithDuration:kDefaultPresentAnimationDuration animations:^{
        self.notificationView.frame = notificationFrame;
        
    } completion:^(BOOL finished) {
        [self performSelector:@selector(dismissNotification:) withObject:nil afterDelay:self.displayTime];
    }];
}


- (void)dismissNotification:(id)sender {
    
    CGRect notificationFrame = self.notificationView.frame;
    notificationFrame.origin.y -= notificationFrame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.notificationView.frame = notificationFrame;
        
    } completion:^(BOOL finished) {
        
        self.notificationView.window.windowLevel = UIWindowLevelStatusBar - 1;
        [self.notificationView removeFromSuperview];
        [self.messagesQueueArray removeObjectAtIndex:0];
        
        if ([self.messagesQueueArray count] != 0) {
            [self startPresentationProcess];
        }
    }];
    
    if (self.actualActionCompletionBlock) self.actualActionCompletionBlock();
}


- (void)handlePressAndHoldGesture:(UILongPressGestureRecognizer *)pressAndHold {
    
    if (pressAndHold.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
    } else  if (pressAndHold.state == UIGestureRecognizerStateEnded) {
        [self dismissNotification:nil];
    }
}


- (UIColor *)appropriateNotificationViewBackgroundColourForNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    if (notificationMessage.notificationViewBackgroundColour) {
        return notificationMessage.notificationViewBackgroundColour;
    }
    
    return self.backgroundColoursDictionary[@(notificationMessage.notificationType)];
}


- (UIImage *)appropriateIconImageForNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    if (notificationMessage.iconImage) {
        return notificationMessage.iconImage;
    }
    
    return self.iconImagesDictionary[@(notificationMessage.notificationType)];
}


#pragma mark Public Methods.

+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType {
    [self displayNotificationWithMessage:message ofType:notificationType withActionCompletionBlock:nil];
}


+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withActionCompletionBlock:(ActionCompletionBlock)actionCompletionBlock {
    [self displayNotificationWithMessage:message ofType:notificationType withButtonWithTitle:nil buttonActionBlock:nil actionCompletionBlock:actionCompletionBlock];
}


+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withButtonWithTitle:(NSString *)buttonTitle buttonActionBlock:(ButtonActionBlock)buttonActionBlock {
    [self displayNotificationWithMessage:message ofType:notificationType withButtonWithTitle:buttonTitle buttonActionBlock:buttonActionBlock actionCompletionBlock:nil];
}


+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withButtonWithTitle:(NSString *)buttonTitle buttonActionBlock:(ButtonActionBlock)buttonActionBlock actionCompletionBlock:(ActionCompletionBlock)actionCompletionBlock {
    
    MDNotificationMessage *notificationMessage = [MDNotificationMessage new];
    notificationMessage.message = message;
    notificationMessage.notificationType = notificationType;
    notificationMessage.buttonTitle = buttonTitle;
    notificationMessage.buttonActionBlock = buttonActionBlock;
    notificationMessage.actionCompletionBlock = actionCompletionBlock;
    
    [self displayNotificationWithMDNotificationMessage:notificationMessage];
}


+ (void)displayNotificationWithMDNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    [[MDCustomNotificationsManager sharedInstance].messagesQueueArray addObject:notificationMessage];
    
    if ([MDCustomNotificationsManager sharedInstance].messagesQueueArray.count == 1) {
        [[MDCustomNotificationsManager sharedInstance] startPresentationProcess];
    };
}


@end


#pragma mark -

@implementation MDNotificationMessage


@end


#pragma mark -

@interface MDNotificationView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, strong) UIView *notificationView;

@property (nonatomic, copy) ButtonActionBlock buttonActionBlock;

@end


@implementation MDNotificationView

#pragma mark Actions.

- (void)handleButtonAction:(UIButton *)actionButton {
    if (self.buttonActionBlock) self.buttonActionBlock();
}


#pragma mark Utilities.

+ (CGFloat)heightForText:(NSString *)text withFont:(UIFont *)font forWidth:(CGFloat)width {
    
    CGSize boundaries = CGSizeMake(width, CGFLOAT_MAX);
    return ceilf([self sizeForText:text withFont:font forBoundaries:boundaries].height);
}


+ (CGFloat)widthForText:(NSString *)text withFont:(UIFont *)font forHeight:(CGFloat)height {
    
    CGSize boundaries = CGSizeMake(CGFLOAT_MAX, height);
    return ceilf([self sizeForText:text withFont:font forBoundaries:boundaries].width);
}


+ (CGSize)sizeForText:(NSString *)text withFont:(UIFont *)font forBoundaries:(CGSize)boundaries {
    
    NSDictionary *stringAttributesDictionary = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:boundaries options:NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributesDictionary context:nil].size;
}


#pragma mark UIView's LifeCycle.

- (id)initWithNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    CGFloat titleHeight = [MDNotificationView titleHeightForNotificationMessage:notificationMessage];
    CGRect notificationViewInitialFrame = [MDNotificationView notificationViewInitialFrameForNotificationMessage:notificationMessage titleHeight:titleHeight];
    
    if (self = [super initWithFrame:notificationViewInitialFrame]) {
        
        self.iconImageView = [self iconImageViewWithNotificationMessage:notificationMessage];
        self.actionButton = [self actionButtonWithNotificationMessage:notificationMessage];
        self.messageLabel = [self messageLabelWithNotificationMessage:notificationMessage titleHeight:titleHeight];
        
        [self addSubview:self.iconImageView];
        [self addSubview:self.actionButton];
        [self addSubview:self.messageLabel];
        
        self.buttonActionBlock = notificationMessage.buttonActionBlock;

        self.backgroundColor = [[MDCustomNotificationsManager sharedInstance] appropriateNotificationViewBackgroundColourForNotificationMessage:notificationMessage];
    }
    
    return self;
}


#pragma mark - Helper Methods.

+ (CGFloat)titleHeightForNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    CGFloat marginsTotalWidth = [MDCustomNotificationsManager sharedInstance].verticalMarginSize;
    UIImage *iconImage = [[MDCustomNotificationsManager sharedInstance] appropriateIconImageForNotificationMessage:notificationMessage];
    
    if (iconImage) {
        marginsTotalWidth = marginsTotalWidth + iconImage.size.width + [MDCustomNotificationsManager sharedInstance].verticalSpaceBetweenElements;
    }
    
    if (notificationMessage.buttonImage) {
        marginsTotalWidth = marginsTotalWidth + [MDCustomNotificationsManager sharedInstance].verticalSpaceBetweenElements + notificationMessage.buttonImage.size.width + [MDCustomNotificationsManager sharedInstance].verticalMarginSize;
    }
    
    CGFloat notificationViewWidth = [[UIApplication sharedApplication] keyWindow].frame.size.width;
    
    return [self heightForText:notificationMessage.message withFont:[MDCustomNotificationsManager sharedInstance].font forWidth:notificationViewWidth - marginsTotalWidth];
}


+ (CGRect)notificationViewInitialFrameForNotificationMessage:(MDNotificationMessage *)notificationMessage titleHeight:(CGFloat)titleHeight {
    
    UIImage *iconImage = [[MDCustomNotificationsManager sharedInstance] appropriateIconImageForNotificationMessage:notificationMessage];
    
    CGFloat notificationViewWidth = [[UIApplication sharedApplication] keyWindow].frame.size.width;
    CGFloat notificationViewHeight = ([MDCustomNotificationsManager sharedInstance].horizontalMarginSize * 2) + ((titleHeight > iconImage.size.height) ? titleHeight : iconImage.size.height);
    
    if (notificationMessage.buttonTitle) {
        
        CGSize titleSize = [MDNotificationView buttonTitleSizeForNotificationMessage:notificationMessage notificationViewWidth:notificationViewWidth];
        notificationViewHeight = notificationViewHeight + [MDCustomNotificationsManager sharedInstance].horizontalSpaceBetweenElements + titleSize.height + [MDCustomNotificationsManager sharedInstance].horizontalMarginSize;
    }
    
    return CGRectMake(0,
                      -notificationViewHeight,
                      notificationViewWidth,
                      notificationViewHeight);
}


- (UIImageView *)iconImageViewWithNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    UIImage *iconImage = [[MDCustomNotificationsManager sharedInstance] appropriateIconImageForNotificationMessage:notificationMessage];
    
    if (!iconImage) {
        return nil;
    }
    
    
    UIImageView *iconImageView = [UIImageView new];
    iconImageView.image = iconImage;
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.frame = CGRectMake([MDCustomNotificationsManager sharedInstance].verticalMarginSize,
                                     self.frame.size.height * 0.5 - iconImage.size.height * 0.5,
                                     iconImage.size.width,
                                     iconImage.size.height);
    return iconImageView;
}


- (UIButton *)actionButtonWithNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    if (notificationMessage.buttonTitle) {
        
        CGSize titleSize = [MDNotificationView buttonTitleSizeForNotificationMessage:notificationMessage notificationViewWidth:self.frame.size.width];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(self.frame.size.width - titleSize.width - [MDCustomNotificationsManager sharedInstance].horizontalMarginSize,
                                  self.frame.size.height - titleSize.height - [MDCustomNotificationsManager sharedInstance].horizontalSpaceBetweenElements,
                                  titleSize.width,
                                  titleSize.height);
        
        [button.titleLabel setFont:[MDCustomNotificationsManager sharedInstance].buttonTitleFont];
        [button setTitle:notificationMessage.buttonTitle forState:UIControlStateNormal];
        [button setTintColor:[UIColor whiteColor]];
        
        [button addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    }
    
    
    if (!notificationMessage.buttonImage) {
        return nil;
    }
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.frame.size.width - notificationMessage.buttonImage.size.width - [MDCustomNotificationsManager sharedInstance].verticalMarginSize,
                              0,
                              notificationMessage.buttonImage.size.width + [MDCustomNotificationsManager sharedInstance].verticalMarginSize,
                            self.frame.size.height);

    
    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [button setImage:notificationMessage.buttonImage forState:UIControlStateNormal];

    return button;
}


- (UILabel *)messageLabelWithNotificationMessage:(MDNotificationMessage *)notificationMessage titleHeight:(CGFloat)titleHeight {
    
    CGFloat actionButtonWidth = (notificationMessage.buttonTitle) ? 0 : self.actionButton.frame.size.width;
    
    CGFloat originX = CGRectGetMaxX(self.iconImageView.frame) + [MDCustomNotificationsManager sharedInstance].verticalSpaceBetweenElements;
    CGFloat originY = self.frame.size.height * 0.5  - titleHeight * 0.5;
    CGFloat width =  self.frame.size.width - originX - actionButtonWidth - [MDCustomNotificationsManager sharedInstance].verticalMarginSize;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, titleHeight)];
    label.numberOfLines = 0;
    label.textColor = [MDCustomNotificationsManager sharedInstance].textColour;
    label.font = [MDCustomNotificationsManager sharedInstance].font;
    label.text = notificationMessage.message;
    
    return label;
}


+ (CGSize)buttonTitleSizeForNotificationMessage:(MDNotificationMessage *)notificationMessage notificationViewWidth:(CGFloat)notificationViewWidth {
    
    CGFloat maxTitleWidth = notificationViewWidth * 0.5 - [MDCustomNotificationsManager sharedInstance].verticalMarginSize;
    CGFloat titleHeight = [MDNotificationView heightForText:notificationMessage.buttonTitle withFont:[MDCustomNotificationsManager sharedInstance].buttonTitleFont forWidth:maxTitleWidth];
    CGFloat titleWidth = [MDNotificationView widthForText:notificationMessage.buttonTitle withFont:[MDCustomNotificationsManager sharedInstance].buttonTitleFont forHeight:titleHeight];
    
    return CGSizeMake(titleWidth, titleHeight);
}


@end
