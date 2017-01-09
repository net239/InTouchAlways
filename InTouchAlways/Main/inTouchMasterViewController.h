//
//  inTouchMasterViewController.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/3/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "inTouchContactEditController.h"
#import "inTouchContactViewController.h"

@interface inTouchMasterViewController : UITableViewController <inTouchContactEditCompletedDelegate,
                                                                inTouchContactViewUpdateContactDelegate>

@end
