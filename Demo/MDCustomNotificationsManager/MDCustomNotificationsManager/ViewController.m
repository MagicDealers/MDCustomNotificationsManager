//
//  ViewController.m
//  MDCustomNotificationsManager
//
//  Created by Jorge Pardo on 13/02/14.
//  Copyright (c) 2014 Magic Dealers. All rights reserved.
//

#import "ViewController.h"
#import "MDCustomNotificationsManager.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark IBActions.

- (IBAction)displayWarning:(id)sender {
    [MDCustomNotificationsManager displayNotificationWithMessage:@"Notifications are queued and delivered in order" ofType:MDCustomNotificationTypeWarning];
}


- (IBAction)displaySuccess:(id)sender {
    
    [MDCustomNotificationsManager displayNotificationWithMessage:@"You can add Completions Block" ofType:MDCustomNotificationTypeSuccess withActionCompletionBlock:^{
        [[[UIAlertView alloc] initWithTitle:@"Notification disappeared" message:@"The notification has disappeared and, thus, the completion block has been executed" delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles:nil, nil] show];
    }];
}


- (IBAction)displayError:(id)sender {
    [MDCustomNotificationsManager displayNotificationWithMessage:@"A button can be added, too, so the user can do something" ofType:MDCustomNotificationTypeError withButtonWithTitle:@"Forgot password?" buttonActionBlock:nil];
}


- (IBAction)displayInfo:(id)sender {
    [MDCustomNotificationsManager displayNotificationWithMessage:@"This notification is just a notification" ofType:MDCustomNotificationTypeInfo];
}


- (IBAction)displayCustom:(id)sender {
    
    MDNotificationMessage *message = [[MDNotificationMessage alloc] init];
    message.message = @"You can customize the notification to fit your needs: Colour, Icon, Displaying Time, etc.";
    message.displayingSeconds = 5;
    message.iconImage = [UIImage imageNamed:@"custom"];
    message.backgroundColour = [UIColor colorWithRed:0.45 green:0.22 blue:0.98 alpha:1];
    message.actionCompletionBlock = ^{
        [[[UIAlertView alloc] initWithTitle:@"Notification disappeared" message:@"The notification has disappeared and, thus, the completion block has been executed" delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles:nil, nil] show];
    };
    
    [MDCustomNotificationsManager displayNotificationWithMDNotificationMessage:message];
}


#pragma mark UIViewController's LifeCycle.

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
}


@end
