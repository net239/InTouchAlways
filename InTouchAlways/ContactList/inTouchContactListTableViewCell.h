//
//  inTouchContactListCell.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/17/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface inTouchContactListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UIButton *expandCollapseButton;
@property (weak, nonatomic) IBOutlet UIButton *CallTextOrEmailIcon;
@property (weak, nonatomic) IBOutlet UIButton *isPrimaryForCallTextOrEmailCheckMark;

- (void) setButtonExpanded;
- (void) setButtonCollapsed;

- (void) setCellForCall;
- (void) setCellForTexts;
- (void) setCellForEmails;

- (void) setPrimaryContact ;
- (void) setNotPrimaryContact;
- (void) hidePrimaryContactMarker;
- (void) showPrimaryContactMarker;




@end
