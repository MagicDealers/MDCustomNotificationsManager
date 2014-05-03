
# MDCustomNotificationsManager 

**Readme** with a now typical gif animation showing what and how the library does what it does, and some fancy dissertation of the appropriated ways of using it *coming soon*. Stay tunned. 

[@thecafremo](https://twitter.com/thecafremo) (Through which you can contact me, but, you now, I don't tweet much. At all, to be honest).

<!-- **MDCustomNotificationsManager** displays it's a simple a configurable way of displaying messages in a notification-way.


## Usage

## How to:

**MDCustomNotificationsManager**'s public methods: 

    + (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType;
    + (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withActionCompletionBlock:(ActionCompletionBlock)actionCompletionBlock;
    + (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withButtonWithTitle:(NSString *)buttonTitle buttonActionBlock:(ButtonActionBlock)buttonActionBlock;
    + (void)displayNotificationWithMessage:(NSString *)message ofType:(MDCustomNotificationType)notificationType withButtonWithTitle:(NSString *)buttonTitle buttonActionBlock:(ButtonActionBlock)buttonActionBlock actionCompletionBlock:(ActionCompletionBlock)actionCompletionBlock;
    
    + (void)displayNotificationWithMDNotificationMessage:(MDNotificationMessage *)notificationMessage;	


Using the `displayNotificationWithMDNotificationMessage:` method you can configure the NotificationView's appearance and behaviour. As a parameter it requires a **MDNotificationMessage**, which has the following properties:

- **message**: The text to be displayed. *NSString*
- **notificationType**: The type of Message that will be displayed. *MDCustomNotificationType* enum
- **actionCompletionBlock**: The block to be executed once the notification **has disappeared**. *(void(^)(void))* 
- **buttonTitle**: The button's title. If *nil* not button will be added to the NotificationView. *NSString*
- **buttonActionBlock**: The block to be executed once the button **is pressed**. *(void(^)(void))*
- **displayingSeconds**: The number of **seconds** that the Notification will be displayed. *float*
- **iconImage**: The icon to be displayed along the message. It's frame is of 36x36 points. *UIImage*
- **backgroundColour**: The colour of the NotificationView's background. *UIColor*


## Installation

###Manually



###Through CocoPods

Simply add `pod 'MDCustomNotificationsManager'` to your Pod

    pod "MDCustomNotificationsManager"



##Author 

Jorge Pardo, JorgePardoPeset@gmail.com 
[@thecafremo](https://twitter.com/thecafremo)



## License

**MDCustomNotificationsManager** is available under the **MIT** license. See the *LICENSE* file for more info.-->

