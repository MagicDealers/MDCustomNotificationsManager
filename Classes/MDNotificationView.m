//
//  MDNotificationView.m
//  MDCustomNotificationsManager
//
//  Created by Jorge Pardo on 1/10/15.
//  Copyright (c) 2015 Magic Dealers. All rights reserved.
//

#import "MDNotificationView.h"
#import "MDNotificationMessage.h"

@interface MDCustomNotificationsManager ()

- (UIImage *)appropriateIconImageForNotificationMessage:(MDNotificationMessage *)notificationMessage;
- (UIColor *)appropriateNotificationViewBackgroundColourForNotificationMessage:(MDNotificationMessage *)notificationMessage;

@end


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
    [button addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    
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
