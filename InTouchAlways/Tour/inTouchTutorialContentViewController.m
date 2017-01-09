//
//  inTouchTutorialContentViewController.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 7/8/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchTutorialContentViewController.h"

@interface inTouchTutorialContentViewController ()

@end

@implementation inTouchTutorialContentViewController

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
    
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
    
    //last page
    if ( self.pageIndex == 8)
    {
        self.exitTourView.alpha = 1;
        
    }
    else
    {
        self.exitTourView.alpha = 0;

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onClose:(id)sender
{
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
