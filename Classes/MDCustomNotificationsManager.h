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

typedef void(^ActionCompletionBlock)(void);
typedef void(^ButtonActionBlock)(void);

@class MDNotificationMessage;


@interface MDCustomNotificationsManager : NSObject

+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType;
+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withActionCompletionBlock:(ActionCompletionBlock)actionCompletionBlock;
+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withButtonWithTitle:(NSString *)buttonTitle buttonActionBlock:(ButtonActionBlock)buttonActionBlock;
+ (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withButtonWithTitle:(NSString *)buttonTitle buttonActionBlock:(ButtonActionBlock)buttonActionBlock actionCompletionBlock:(ActionCompletionBlock)actionCompletionBlock;
+ (void)displayNotificationWithMDNotificationMessage:(MDNotificationMessage *)notificationMessage;


+ (MDCustomNotificationsManager *)sharedInstance;

@end



@interface MDNotificationMessage : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) MDCustomNotificationType notificationType;
@property (nonatomic, copy) ActionCompletionBlock actionCompletionBlock;
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, copy) ButtonActionBlock buttonActionBlock;
@property (nonatomic, assign) float displayingSeconds;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIColor *backgroundColour;

@end



@interface MDNotificationView : UIView

- (id)initWithNotificationMessage:(MDNotificationMessage *)notificationMessage;

@end
