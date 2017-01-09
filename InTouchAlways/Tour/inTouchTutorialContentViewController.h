//
//  inTouchTutorialContentViewController.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 7/8/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface inTouchTutorialContentViewController : UIViewController

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)onClose:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *exitTourView;
@property (weak, nonatomic) IBOutlet UIButton *exitTourButton;

@end
