//
//  MDCustomNotificationsManager.h
//  BeAdict
//
//  Created by Thecafremo on 21/12/13.
//  Copyright (c) 2013 MagicDealers. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MDCustomNotificationTypeCustom,
    MDCustomNotificationTypeError,
    MDCustomNotificationTypeSuccess,
    MDCustomNotificationTypeInfo,
    MDCustomNotificationTypeWarning
} MDCustomNotificationType;

static NSString * const MDNotificationViewBackgroundColourKey = @"backgroundColourKey";
static NSString * const MDNotificationViewIconImageKey = @"iconImageKey";

typedef void(^ButtonActionBlock)(void);
typedef void(^ActionCompletionBlock)(void);


@class MDNotificationMessage;

@interface MDCustomNotificationsManager : NSObject

@property (nonatomic, assign) CGFloat verticalMarginSize;
@property (nonatomic, assign) CGFloat horizontalMarginSize;
@property (nonatomic, assign) CGFloat verticalSpaceBetweenElements;
@property (nonatomic, assign) CGFloat horizontalSpaceBetweenElements;

@property (nonatomic, assign) CGFloat displayTime;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColour;
@property (nonatomic, strong) UIFont *buttonTitleFont;

@property (nonatomic, assign) BOOL tapToDismissEnabled;


+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType;
+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withActionCompletionBlock:(ActionCompletionBlock)actionCompletionBlock;

+ (void)displayNotificationWithMDNotificationMessage:(MDNotificationMessage *)notificationMessage;

+ (void)configureNotificationOfType:(MDCustomNotificationType)customNotificationType withParameters:(NSDictionary *)parametersDictionary;

+ (MDCustomNotificationsManager *)sharedInstance;

@end

