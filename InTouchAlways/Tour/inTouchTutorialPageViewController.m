//
//  inTouchTutorialPageViewController.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 7/12/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchTutorialPageViewController.h"

@interface inTouchTutorialPageViewController ()

@end

@implementation inTouchTutorialPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //for tutorial screens
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
