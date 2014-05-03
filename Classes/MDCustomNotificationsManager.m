//
//  MDCustomNotificationsManager.m
//  BeAdict
//
//  Created by Thecafremo on 21/12/13.
//  Copyright (c) 2013 MagicDealers. All rights reserved.
//

#import "MDCustomNotificationsManager.h"

static UIFont *kMessageFont = nil;
static UIColor *kMessageTextColour = nil;

static float kNotificationBackgroundAlpha = 0.9;

@interface MDCustomNotificationsManager ()

@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, copy) ActionCompletionBlock actualActionCompletionBlock;
@property (nonatomic, assign) float displayingSeconds;
@property (nonatomic, strong) NSMutableArray *messagesQueueArray;

@end

@implementation MDCustomNotificationsManager

#pragma mark Actions.

- (void)startPresentionProcess {
    
    MDNotificationMessage *notificationMessage = [self.messagesQueueArray objectAtIndex:0];
    self.actualActionCompletionBlock = notificationMessage.actionCompletionBlock;
    
    if (notificationMessage.displayingSeconds) self.displayingSeconds = notificationMessage.displayingSeconds;
    
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
    
    [UIView animateWithDuration:0.2 animations:^{
        self.notificationView.frame = notificationFrame;
        
    } completion:^(BOOL finished) {
        [self performSelector:@selector(dismissNotification:) withObject:nil afterDelay:self.displayingSeconds];
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
            [self startPresentionProcess];
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
    
    MDNotificationMessage *notificationMessage = [[MDNotificationMessage alloc] init];
    notificationMessage.message = message;
    notificationMessage.notificationType = notificationType;
    notificationMessage.buttonTitle = buttonTitle;
    notificationMessage.buttonActionBlock = buttonActionBlock;
    notificationMessage.actionCompletionBlock = actionCompletionBlock;
    
    [self displayNotificationWithMDNotificationMessage:notificationMessage];
}


+ (void)displayNotificationWithMDNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    [[MDCustomNotificationsManager sharedInstance].messagesQueueArray addObject:notificationMessage];
    if ([[MDCustomNotificationsManager sharedInstance].messagesQueueArray count] == 1) [[MDCustomNotificationsManager sharedInstance] startPresentionProcess];
}


#pragma mark Singleton's LifeCycle.

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        kMessageFont = [UIFont boldSystemFontOfSize:16.0];
        kMessageTextColour = [UIColor whiteColor];
        
        self.messagesQueueArray = [[NSMutableArray alloc] init];
        self.displayingSeconds = 3;
    }
    
    return self;    
}


+ (MDCustomNotificationsManager *)sharedInstance {
    
    static MDCustomNotificationsManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MDCustomNotificationsManager alloc] init];
    });
    
    return instance;
}

@end


#pragma mark -

@implementation MDNotificationMessage


@end


#pragma mark -

@interface MDNotificationView ()

@property (nonatomic, strong) UIImageView *notificationTypeIcon;
@property (nonatomic, strong) UILabel *titleLabel;
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


- (UIColor *)appropriateColourForNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    MDCustomNotificationType notificationType = notificationMessage.notificationType;
    
    UIColor *colour;
    
    if (notificationType == MDCustomNotificationTypeError) {
        colour = [UIColor colorWithRed:0.826 green:0.154 blue:0.188 alpha:kNotificationBackgroundAlpha];
        
    } else if (notificationType == MDCustomNotificationTypeSuccess) {
        colour = [UIColor colorWithRed:0.207 green:0.785 blue:0.289 alpha:kNotificationBackgroundAlpha];
        
    } else if (notificationType == MDCustomNotificationTypeInfo) {
        colour = [UIColor colorWithWhite:0 alpha:kNotificationBackgroundAlpha];
        
    } else if (notificationType == MDCustomNotificationTypeWarning) {
        colour = [UIColor colorWithRed:1.000 green:0.404 blue:0.141 alpha:kNotificationBackgroundAlpha];
        
    } else {
        
        if (notificationMessage.backgroundColour) {
            colour = notificationMessage.backgroundColour;
            
        } else {
            colour = [UIColor colorWithWhite:0 alpha:kNotificationBackgroundAlpha];
        }
    }
    
    return colour;
}


- (UIImage *)appropriateImageForNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    MDCustomNotificationType notificationType = notificationMessage.notificationType;
    
    UIImage *image;
    
    if (notificationType == MDCustomNotificationTypeError) {
        image = [UIImage imageNamed:@"icon-error.png"];
        
    } else if (notificationType == MDCustomNotificationTypeSuccess) {
        image = [UIImage imageNamed:@"icon-success.png"];
        
    } else if (notificationType == MDCustomNotificationTypeInfo) {
        image = [UIImage imageNamed:@"icon-info.png"];
        
    } else if (notificationType == MDCustomNotificationTypeWarning) {
        image = [UIImage imageNamed:@"icon-warning.png"];
        
    } else {
        
        if (notificationMessage.iconImage) {
            image = notificationMessage.iconImage;
            
        } else {
            image = [UIImage imageNamed:@"icon-info.png"];
        }
    }
    
    return image;
}


#pragma mark Utilities.

- (CGFloat)heightForText:(NSString *)text withFont:(UIFont *)font forWidth:(CGFloat)width {
    
    CGSize boundaries = CGSizeMake(width, CGFLOAT_MAX);
    return [self sizeForText:text withFont:font forBoundaries:boundaries].height + 20;
}


- (CGFloat)widthForText:(NSString *)text withFont:(UIFont *)font forHeight:(CGFloat)height {
    
    CGSize boundaries = CGSizeMake(CGFLOAT_MAX, height);
    return [self sizeForText:text withFont:font forBoundaries:boundaries].width;
}


- (CGSize)sizeForText:(NSString *)text withFont:(UIFont *)font forBoundaries:(CGSize)boundaries {
    
    NSDictionary *stringAttributesDictionary = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:boundaries options:NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributesDictionary context:nil].size;
}


#pragma mark UIView's LifeCycle.

- (id)initWithNotificationMessage:(MDNotificationMessage *)notificationMessage {
    
    float notificationViewWidth = [[UIApplication sharedApplication] keyWindow].frame.size.width;
    float titleHeight = [self heightForText:notificationMessage.message withFont:kMessageFont forWidth:notificationViewWidth - 10 - 36 - 10];
    
    float notificationViewHeight = 10 + titleHeight + 10;
    
    if (notificationMessage.buttonTitle) notificationViewHeight = notificationViewHeight + 10 + 10;
    
    self = [super initWithFrame:CGRectMake(0, -notificationViewHeight, notificationViewWidth, notificationViewHeight)];
    
    if (self) {
        
        self.backgroundColor = [self appropriateColourForNotificationMessage:notificationMessage];
        
        
        self.notificationTypeIcon = [[UIImageView alloc] init];
        self.notificationTypeIcon.image = [self appropriateImageForNotificationMessage:notificationMessage];
        self.notificationTypeIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.notificationTypeIcon.frame = CGRectMake(10, notificationViewHeight * 0.5 - 36 * 0.5, 36, 36);
        
        [self addSubview:self.notificationTypeIcon];
        
        
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.notificationTypeIcon.frame) + 10,
                                                                      (notificationViewHeight * 0.5) - (titleHeight * 0.5),
                                                                      notificationViewWidth - (10 + CGRectGetMaxX(self.notificationTypeIcon.frame) + 10),
                                                                      titleHeight)];
        
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.textColor = kMessageTextColour;
        self.messageLabel.font = kMessageFont;
        self.messageLabel.text = notificationMessage.message;
        
        [self addSubview:self.messageLabel];
        
        
                
        if (notificationMessage.buttonTitle) {
            
            self.buttonActionBlock = notificationMessage.buttonActionBlock;
            
            UIFont *buttonFont = [UIFont boldSystemFontOfSize:13];
            float titleHeight = 20;
            float titleWidth = [self widthForText:notificationMessage.buttonTitle withFont:buttonFont forHeight:titleHeight];
            
            self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
            self.actionButton.frame = CGRectMake(notificationViewWidth - titleWidth - 10,
                                                 notificationViewHeight - titleHeight - 10,
                                                 titleWidth,
                                                 titleHeight);
            
            self.actionButton.titleLabel.font = buttonFont;
            [self.actionButton setTitle:notificationMessage.buttonTitle forState:UIControlStateNormal];
            self.actionButton.tintColor = [UIColor whiteColor];
            [self.actionButton addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchDown];
            
            [self addSubview:self.actionButton];            
        }
    }
    
    return self;
}

@end
