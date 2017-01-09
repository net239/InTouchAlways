//
//  inTouchMasterViewContactCell.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/9/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface inTouchMasterViewContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *lastContacted;
@property (weak, nonatomic) IBOutlet UILabel *contactedNDaysBack;
@property (weak, nonatomic) IBOutlet UILabel *nextCallMessage;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

@end
