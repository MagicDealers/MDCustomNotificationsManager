//
//  ViewController.m
//  MDCustomNotificationsManager
//
//  Created by Jorge Pardo on 13/02/14.
//  Copyright (c) 2014 Magic Dealers. All rights reserved.
//

#import "ViewController.h"
#import "MDCustomNotificationsManager.h"
#import "MDNotificationMessage.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark IBActions.

- (IBAction)displayWarning:(id)sender {
    [MDCustomNotificationsManager displayNotificationWithMessage:@"Notifications are queued and delivered in order" ofType:MDCustomNotificationTypeWarning];
}


- (IBAction)displaySuccess:(id)sender {
    
    [MDCustomNotificationsManager displayNotificationWithMessage:@"You can add Completion Blocks" ofType:MDCustomNotificationTypeSuccess withActionCompletionBlock:^{
        [[[UIAlertView alloc] initWithTitle:@"Notification disappeared" message:@"The notification has disappeared and, thus, the completion block has been executed" delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles:nil, nil] show];
    }];
}


- (IBAction)displayError:(id)sender {
    
    [MDCustomNotificationsManager displayNotificationWithMessage:@"A button can be added, too, so the user can be prompted to do something" ofType:MDCustomNotificationTypeError withButtonWithTitle:@"Forgot password?" buttonActionBlock:^{
        [[[UIAlertView alloc] initWithTitle:@"Button Pressed" message:@"Notification's button has been pressed. The block is executed." delegate:nil cancelButtonTitle:@"Super Cool" otherButtonTitles:nil, nil] show];
    }];
}


- (IBAction)displayInfo:(id)sender {
    
    [MDCustomNotificationsManager displayNotificationWithMessage:@"This notification is just a notification" ofType:MDCustomNotificationTypeInfo];
}


- (IBAction)displayCustom:(id)sender {
    
    MDNotificationMessage *message = [[MDNotificationMessage alloc] init];
    message.message = @"You can customize the notification to fit your needs: Colour, Icon, Displaying Time, Button Image, etc.";
    message.displayTime = 5;
    message.iconImage = [UIImage imageNamed:@"custom"];
    message.buttonImage = [UIImage imageNamed:@"close-cross"];
    message.notificationViewBackgroundColour = [UIColor colorWithRed:0.45 green:0.22 blue:0.98 alpha:1];
    message.buttonActionBlock = ^{
        [[[UIAlertView alloc] initWithTitle:@"Button Pressed" message:@"Notification's button has been pressed. The block is executed." delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles:nil, nil] show];
    };
    
    [MDCustomNotificationsManager displayNotificationWithMDNotificationMessage:message];
}


@end
