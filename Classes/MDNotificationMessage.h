//
//  MDNotificationMessage.h
//  MDCustomNotificationsManager
//
//  Created by Jorge Pardo on 1/10/15.
//  Copyright (c) 2015 Magic Dealers. All rights reserved.
//

#import "MDCustomNotificationsManager.h"

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
