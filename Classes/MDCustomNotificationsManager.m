//
//  MDCustomNotificationsManager.m
//  BeAdict
//
//  Created by Thecafremo on 21/12/13.
//  Copyright (c) 2013 MagicDealers. All rights reserved.
//

#import "MDCustomNotificationsManager.h"
#import "MDNotificationMessage.h"
#import "MDNotificationView.h"

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

    if (self.tapToDismissEnabled) {
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressAndHoldGesture:)];
        longPress.minimumPressDuration = 0.01;
        longPress.cancelsTouchesInView = NO;
        
        [self.notificationView addGestureRecognizer:longPress];
    }
        
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


+ (void)configureNotificationOfType:(MDCustomNotificationType)customNotificationType withParameters:(NSDictionary *)parametersDictionary {
    
    UIColor *backgroundColor = parametersDictionary[MDNotificationViewBackgroundColourKey];
    
    if (backgroundColor) {
        
        NSMutableDictionary *backgroundColoursDictionary = [[MDCustomNotificationsManager sharedInstance].backgroundColoursDictionary mutableCopy];
        backgroundColoursDictionary[@(customNotificationType)] = backgroundColor;
        
        [MDCustomNotificationsManager sharedInstance].backgroundColoursDictionary = backgroundColoursDictionary;
    }
    
    UIImage *iconImage = parametersDictionary[MDNotificationViewIconImageKey];
    
    if (iconImage) {
        
        NSMutableDictionary *iconImagesDictionary = [[MDCustomNotificationsManager sharedInstance].iconImagesDictionary mutableCopy];
        iconImagesDictionary[@(customNotificationType)] = iconImage;
        
        [MDCustomNotificationsManager sharedInstance].iconImagesDictionary = iconImagesDictionary;
    }
}


@end


