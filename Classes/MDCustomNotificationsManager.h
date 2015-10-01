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
+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withButtonWithTitle:(NSString *)buttonTitle buttonActionBlock:(ButtonActionBlock)buttonActionBlock;
+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withButtonWithTitle:(NSString *)buttonTitle buttonActionBlock:(ButtonActionBlock)buttonActionBlock actionCompletionBlock:(ActionCompletionBlock)actionCompletionBlock;
+ (void)displayNotificationWithMDNotificationMessage:(MDNotificationMessage *)notificationMessage;


+ (MDCustomNotificationsManager *)sharedInstance;

@end



@interface MDNotificationMessage : NSObject

@property (nonatomic, assign) MDCustomNotificationType notificationType;

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIImage *buttonImage;
@property (nonatomic, strong) UIColor *notificationViewBackgroundColour;

@property (nonatomic, assign) CGFloat displayTime;

@property (nonatomic, copy) ButtonActionBlock buttonActionBlock;
@property (nonatomic, copy) ActionCompletionBlock actionCompletionBlock;

@end



@interface MDNotificationView : UIView

- (id)initWithNotificationMessage:(MDNotificationMessage *)notificationMessage;

@end
