//
//  OCExpandableButton.h
//  SparrowButton
//
//  Created by Oliver Rickard on 5/18/13.
//  Copyright (c) 2013 Oliver Rickard. All rights reserved.
//

#import <UIKit/UIKit.h>

//Determines if the content is left or right aligned.
//If the content is left aligned, then the button will expand towards the right
// with content
typedef enum {
    OCExpandableButtonAlignmentLeft,
    OCExpandableButtonAlignmentRight
} OCExpandableButtonAlignment;

@class OCExpandableButton;

// The delegate allows notification of expandable button opening/closure
@protocol OCExpandableButtonDelegate

- (void)expandableButtonOpened:(OCExpandableButton*)button;
- (void)expandableButtonClosed:(OCExpandableButton*)button;

@end

@interface OCExpandableButton : UIView

@property (nonatomic, assign) OCExpandableButtonAlignment alignment;
@property (nonatomic, strong) id<OCExpandableButtonDelegate> delegate;

//initialize with a specific set of subviews
- (id)initWithFrame:(CGRect)frame subviews:(NSArray *)subviews;

//Standard initializer, set the subviews later.
- (id)initWithFrame:(CGRect)frame;

//These are the views that show in the bar when the control is expanded.
- (void)setOptionViews:(NSArray *)subviews;

//Opens the control if the control is currently closed.  No effect if the button
// is already open.
- (void)open;

//Closes the control if open.  No effect if already closed.
- (void)close;

@end
