//
//  inTouchTutorialViewController.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 7/11/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "inTouchTutorialContentViewController.h"

@interface inTouchTutorialViewController : UIViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@end
