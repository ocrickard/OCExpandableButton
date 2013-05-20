//
//  OCViewController.m
//  OCExpandableButton
//
//  Created by Oliver Rickard on 5/18/13.
//  Copyright (c) 2013 Oliver Rickard. All rights reserved.
//

#import "OCViewController.h"
#import "OCExpandableButton.h"

@interface OCViewController () {
    OCExpandableButton *button;
}

@end

@implementation OCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSMutableArray *subviews = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 4; i++) {
        UIButton *numberButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20.f, 30.f)];
        numberButton.backgroundColor = [UIColor clearColor];
        [numberButton setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        numberButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        numberButton.titleLabel.textColor = [UIColor colorWithRed:0.494 green:0.498 blue:0.518 alpha:1];
        [numberButton addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
        [subviews addObject:numberButton];
    }
    
    //Note to reader - the blue initial button is inset 3px on all sides from
    // the initial frame you provide.  You should provide a square rect of any
    // size.
    button = [[OCExpandableButton alloc] initWithFrame:CGRectMake(floorf(self.view.bounds.size.width*0.5f - 37.f*0.5f), self.view.bounds.size.height - 57, 37, 37) subviews:subviews];
    button.alignment = OCExpandableButtonAlignmentLeft;
    [self.view addSubview:button];
    
    //You can open/close the button using the public methods.  So if you wanted
    // to close the button on scroll or orientation change, you can do that.
    [button open];
}

- (void)tapped {
    NSLog(@"tapped");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
