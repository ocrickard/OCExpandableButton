//
//  OCExpandableButton.m
//  SparrowButton
//
//  Created by Oliver Rickard on 5/18/13.
//  Copyright (c) 2013 Oliver Rickard. All rights reserved.
//

#import "OCExpandableButton.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration 0.1f

#define kInactiveGradientColors @[(__bridge id)[UIColor colorWithRed: 0.291 green: 0.475 blue: 0.768 alpha: 1].CGColor, (__bridge id)[UIColor colorWithRed: 0.079 green: 0.161 blue: 0.309 alpha: 1].CGColor]
#define kInactiveStrokeColor [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.241].CGColor
#define kInactiveFillColor [UIColor whiteColor].CGColor

#define kActiveGradientColors @[(__bridge id)[UIColor colorWithRed:0.769 green:0.773 blue:0.792 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:0.710 green:0.722 blue:0.741 alpha:1].CGColor]
#define kActiveStrokeColor [UIColor colorWithRed:0.455 green:0.458 blue:0.470 alpha:0.190].CGColor
#define kActiveFillColor [UIColor colorWithRed:0.494 green:0.498 blue:0.518 alpha:1].CGColor

#define kBackgroundGradientColors @[(__bridge id)[UIColor colorWithRed:0.933 green:0.937 blue:0.945 alpha:0.900].CGColor, (__bridge id)[UIColor colorWithRed:0.804 green:0.824 blue:0.839 alpha:0.900].CGColor]
#define kBackgroundStrokeColor [UIColor colorWithWhite:1.000 alpha:0.310].CGColor

#define kSubviewHorizontalMargin 10.f

@interface OCExpandableButton () {
    CAShapeLayer *_arrowLayer;
    CAGradientLayer *_arrowGradientLayer;
    
    CAGradientLayer *_backgroundGradientLayer;
    
    NSArray *_subviews;
    
    BOOL _active;
}

@end

@implementation OCExpandableButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    if(self) {
        _subviews = nil;
        _active = NO;
        self.alignment = OCExpandableButtonAlignmentRight;
        self.userInteractionEnabled = YES;
        [self setupSublayers];
        self.clipsToBounds = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame subviews:(NSArray *)subviews
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _subviews = subviews;
        _active = NO;
        self.alignment = OCExpandableButtonAlignmentRight;
        self.userInteractionEnabled = YES;
        [self setupSublayers];
        [self setupSubviews];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)dealloc {
    _arrowLayer = nil;
    _arrowGradientLayer = nil;
    _backgroundGradientLayer = nil;
    _subviews = nil;
}

#pragma mark - Subview Setup

- (void)setSubviews:(NSArray *)subviews {
    if(subviews != _subviews) {
        if(_subviews) {
            for(UIView *subview in subviews) {
                [subview removeFromSuperview];
            }
        }
        _subviews = subviews;
        [self setupSubviews];
    }
}

- (void)setupSubviews {
    for(UIView *view in _subviews) {
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        view.alpha = 0.f;
        view.hidden = YES;
        [self addSubview:view];
    }
}

- (void)resetSubviews {
    for(UIView *view in _subviews) {
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        view.alpha = 0.f;
        view.hidden = YES;
    }
}

#pragma mark - Layer Setup

- (void)setupSublayers {
    CGRect backgroundRect = self.bounds;
    
    //Construct the background layer that animates out when tapped
    {
        _backgroundGradientLayer = [CAGradientLayer layer];
        _backgroundGradientLayer.frame = backgroundRect;
        _backgroundGradientLayer.colors = kBackgroundGradientColors;
        _backgroundGradientLayer.startPoint = CGPointMake(0.5f, 0.f);
        _backgroundGradientLayer.endPoint = CGPointMake(0.5f, 1.f);
        _backgroundGradientLayer.borderColor = kBackgroundStrokeColor;
        _backgroundGradientLayer.borderWidth = 1.f;
        _backgroundGradientLayer.cornerRadius = 9.f;
        _backgroundGradientLayer.opacity = 0.f;
        
        _backgroundGradientLayer.shadowColor = [UIColor blackColor].CGColor;
        _backgroundGradientLayer.shadowOffset = CGSizeMake(0.f, 2.f);
        _backgroundGradientLayer.shadowOpacity = 0.2f;
        _backgroundGradientLayer.shadowRadius = 3.f;
        
        [self.layer addSublayer:_backgroundGradientLayer];
    }
    
    CGRect arrowButtonRect = CGRectInset(self.bounds, 4.f, 4.f);
    
    //Construct the blue gradient layer
    {
        
        _arrowGradientLayer = [CAGradientLayer layer];
        _arrowGradientLayer.frame = arrowButtonRect;
        _arrowGradientLayer.colors = kInactiveGradientColors;
        _arrowGradientLayer.startPoint = CGPointMake(0.5f, 0.f);
        _arrowGradientLayer.endPoint = CGPointMake(0.5f, 1.f);
        _arrowGradientLayer.borderColor = kInactiveStrokeColor;
        _arrowGradientLayer.borderWidth = 0.5f;
        _arrowGradientLayer.cornerRadius = 7.f;
        
        //Disable implicit animations
        _arrowGradientLayer.actions = @{@"onOrderIn" : [NSNull null], @"onOrderOut" : [NSNull null], @"sublayers" : [NSNull null], @"contents" : [NSNull null], @"bounds" : [NSNull null], @"transform" : [NSNull null], @"position" : [NSNull null]};
        
        [self.layer addSublayer:_arrowGradientLayer];
    }
    
    //Construct the arrow
    {
        UIColor* arrowShadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.469];
        
        CGSize arrowShadowOffset = CGSizeMake(0.1, -0.1);
        CGFloat arrowShadowBlurRadius = 4;
        
        UIBezierPath* arrowPath = [UIBezierPath bezierPath];
        CGFloat scaleFactor = CGRectGetWidth(arrowButtonRect)/31.f;
        //Construct the arrow's path - drawn by hand in PaintCode (love that
        // app) then scaled here so it grows with the size of the button.
        [arrowPath moveToPoint: CGPointMake(7.5*scaleFactor, 18.5*scaleFactor)];
        [arrowPath addLineToPoint: CGPointMake(10*scaleFactor, 21*scaleFactor)];
        [arrowPath addLineToPoint: CGPointMake(15.5*scaleFactor, 15.5*scaleFactor)];
        [arrowPath addLineToPoint: CGPointMake(21*scaleFactor, 21*scaleFactor)];
        [arrowPath addLineToPoint: CGPointMake(23.5*scaleFactor, 18.5*scaleFactor)];
        [arrowPath addLineToPoint: CGPointMake(15.5*scaleFactor, 10.5*scaleFactor)];
        [arrowPath addLineToPoint: CGPointMake(7.5*scaleFactor, 18.5*scaleFactor)];
        [arrowPath closePath];
        
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.frame = arrowButtonRect;
        _arrowLayer.path = arrowPath.CGPath;
        
        _arrowLayer.fillColor = kInactiveFillColor;
        _arrowLayer.shadowColor = arrowShadowColor.CGColor;
        _arrowLayer.shadowOffset = arrowShadowOffset;
        _arrowLayer.shadowRadius = arrowShadowBlurRadius;
        _arrowLayer.shadowPath = arrowPath.CGPath;
        _arrowLayer.shadowOpacity = 1.f;
        
        //Disable implicit animations
        _arrowLayer.actions = @{@"onOrderIn" : [NSNull null], @"onOrderOut" : [NSNull null], @"sublayers" : [NSNull null], @"contents" : [NSNull null], @"bounds" : [NSNull null], @"transform" : [NSNull null]};
        
        [self.layer addSublayer:_arrowLayer];
    }
}

#pragma mark - Activation

- (void)toggleActive {
    
    _active = !_active;
    
    if(_active) {
        
        //The button is now active.  We have to expand the frame, change the
        // colors of the bg, animate in the sub-buttons
        
        //Compute the new size
        CGFloat newWidth = kSubviewHorizontalMargin + self.bounds.size.width;
        for(UIView *view in _subviews) {
            newWidth += view.frame.size.width + kSubviewHorizontalMargin;
        }
        
        CGFloat curX = -newWidth + self.bounds.size.width + kSubviewHorizontalMargin;
        NSTimeInterval delay = 0.02f + 0.02f*_subviews.count;
        //Animate in the items
        for(UIView *view in _subviews) {
            view.center = CGPointMake(curX + floorf(view.frame.size.width*0.5f), CGRectGetMidY(self.bounds));
            view.hidden = NO;
            view.alpha = 0.f;
            view.transform = CGAffineTransformMakeScale(2.f, 2.f);
            [UIView animateWithDuration:kAnimationDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                view.alpha = 1.f;
                view.transform = CGAffineTransformIdentity;
            } completion:nil];
            delay -= 0.02f;
            curX += view.frame.size.width + kSubviewHorizontalMargin;
        }
        
        //Animate in the gray background
        [self fadeLayer:_backgroundGradientLayer newOpacity:1.f duration:kAnimationDuration];
        
        [self setBoundsForLayer:_backgroundGradientLayer newBounds:CGRectMake(0, 0, newWidth, _backgroundGradientLayer.bounds.size.height) duration:kAnimationDuration];
        CGPoint position = CGPointMake(_backgroundGradientLayer.position.x - 0.5f*(_backgroundGradientLayer.bounds.size.width - self.bounds.size.width), CGRectGetMidY(self.bounds));
        [self setPositionForLayer:_backgroundGradientLayer newPosition:position duration:kAnimationDuration];
        
        //Change bg colors
        [self animateColorChangeForLayer:_arrowGradientLayer newColors:kActiveGradientColors duration:kAnimationDuration];
        _arrowGradientLayer.borderColor = kActiveStrokeColor;
        
        //Change the fill colors
        [self fadeFillColorForLayer:_arrowLayer newColor:kActiveFillColor duration:kAnimationDuration];
        _arrowLayer.shadowOpacity = 0.f;
        
        //Switch up the frames!
        if(self.alignment == OCExpandableButtonAlignmentLeft) {
            
            //Do something?
            
        } else if(self.alignment == OCExpandableButtonAlignmentRight) {
            
            //rotate
            [self rotateLayer:_arrowLayer byDegrees:-90.f duration:kAnimationDuration];
        }
        
    } else {
        
        //The button is inactive.  We have to contract the frame, change the
        // colors, and animate out the sub-buttons.
        
        //Animate out the items
        for(UIView *view in _subviews) {
            [UIView animateWithDuration:kAnimationDuration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.alpha = 0.f;
                view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            } completion:^(BOOL finished) {
                view.hidden = YES;
            }];
        }
        
        //Animate out the gray background
        [self fadeLayer:_backgroundGradientLayer newOpacity:0.f duration:kAnimationDuration];
        
        _backgroundGradientLayer.bounds = self.bounds;
        _backgroundGradientLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        //Change bg colors
        [self animateColorChangeForLayer:_arrowGradientLayer newColors:kInactiveGradientColors duration:kAnimationDuration];
        _arrowGradientLayer.borderColor = kInactiveStrokeColor;
        
        //Change the fill colors
        [self fadeFillColorForLayer:_arrowLayer newColor:kInactiveFillColor duration:kAnimationDuration];
        _arrowLayer.shadowOpacity = 1.f;
        
        //Switch up the frames!
        if(self.alignment == OCExpandableButtonAlignmentLeft) {
            
        } else if(self.alignment == OCExpandableButtonAlignmentRight) {
            //rotate back to the start
            [self rotateLayer:_arrowLayer byDegrees:90.f duration:kAnimationDuration];
        }
        
    }
}

- (void)setPositionForLayer:(CALayer *)layer newPosition:(CGPoint)point duration:(NSTimeInterval)duration {
    NSValue *positionAtStart = [layer valueForKeyPath:@"position"];
    layer.position = point;
    CABasicAnimation *boundsChange = [CABasicAnimation animationWithKeyPath:@"position"];
    boundsChange.duration = duration;
    boundsChange.fromValue = positionAtStart;
    boundsChange.toValue = [NSValue valueWithCGPoint:point];
    boundsChange.removedOnCompletion = YES;
    [layer addAnimation:boundsChange forKey:@"position"];
}

- (void)setBoundsForLayer:(CALayer *)layer newBounds:(CGRect)bounds duration:(NSTimeInterval)duration {
    NSValue *boundsAtStart = [layer valueForKeyPath:@"bounds"];
    layer.bounds = bounds;
    CABasicAnimation *boundsChange = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsChange.duration = duration;
    boundsChange.fromValue = boundsAtStart;
    boundsChange.toValue = [NSValue valueWithCGRect:bounds];
    boundsChange.removedOnCompletion = YES;
    [layer addAnimation:boundsChange forKey:@"bounds"];
}

- (void)fadeFillColorForLayer:(CAShapeLayer *)layer newColor:(CGColorRef)color duration:(NSTimeInterval)duration {
    id colorAtStart = [layer valueForKeyPath:@"fillColor"];
    layer.fillColor = color;
    CABasicAnimation *colorChange = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    colorChange.duration = duration;
    colorChange.fromValue = colorAtStart;
    colorChange.toValue = (__bridge id)color;
    colorChange.removedOnCompletion = YES;
    [layer addAnimation:colorChange forKey:@"fillColor"];
}

- (void)fadeLayer:(CALayer *)layer newOpacity:(CGFloat)opacity duration:(NSTimeInterval)duration {
    NSNumber *opacityAtStart = [layer valueForKeyPath:@"opacity"];
    layer.opacity = opacity;
    CABasicAnimation *opacityChange = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityChange.duration = duration;
    opacityChange.fromValue = opacityAtStart;
    opacityChange.toValue = @(opacity);
    opacityChange.removedOnCompletion = YES;
    [layer addAnimation:opacityChange forKey:@"opacity"];
}

- (void)animateColorChangeForLayer:(CAGradientLayer *)gradientLayer newColors:(NSArray *)colors duration:(NSTimeInterval)duration {
    NSArray *colorsAtStart = [gradientLayer valueForKeyPath:@"colors"];
    gradientLayer.colors = colors;
    CABasicAnimation *colorChange = [CABasicAnimation animationWithKeyPath:@"colors"];
    colorChange.duration = duration;
    colorChange.fromValue = colorsAtStart;
    colorChange.toValue = colors;
    colorChange.removedOnCompletion = YES;
    [gradientLayer addAnimation:colorChange forKey:@"colors"];
}

- (void)rotateLayer:(CALayer *)layer byDegrees:(CGFloat)degrees duration:(NSTimeInterval)duration {
    NSNumber *rotationAtStart = [layer valueForKeyPath:@"transform.rotation"];
    CATransform3D transform = CATransform3DRotate(layer.transform, degrees*M_PI/180.f, 0.0, 0.0, 1.0);
    layer.transform = transform;
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.duration = duration;
    rotation.fromValue = rotationAtStart;
    rotation.toValue = [NSNumber numberWithFloat:([rotationAtStart floatValue] + degrees*M_PI/180.f)];
    rotation.removedOnCompletion = YES;
    [layer addAnimation:rotation forKey:@"transform.rotation"];
}

#pragma mark - Touch Handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(touches.count > 0) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        if(CGRectContainsPoint(self.bounds, touchPoint)) {
            //The user touched up inside the button.  Let's toggle activation.
            [self toggleActive];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(_active) {
        for(UIView *subview in _subviews) {
            if(CGRectContainsPoint(subview.frame, point)) {
                return subview;
            }
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - Public Methods

- (void)open {
    if(!_active) {
        [self toggleActive];
    }
}

- (void)close {
    if(_active) {
        [self toggleActive];
    }
}

@end
