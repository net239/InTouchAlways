//
//  inTouchContactListCell.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/17/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchContactListTableViewCell.h"

@implementation inTouchContactListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setButtonExpanded
{
    [self.expandCollapseButton setImage:[UIImage imageNamed:@"arrow_up.png"] forState:UIControlStateNormal];
    self.expandCollapseButton.alpha = 1.0;
    
}

- (void) setButtonCollapsed
{
    [self.expandCollapseButton setImage:[UIImage imageNamed:@"arrow_dn.png"] forState:UIControlStateNormal];
    self.expandCollapseButton.alpha = 0.0;  //no need to display down button - since we are showing this on all contacts
}

- (void) setCellForCall
{
    [self.CallTextOrEmailIcon setImage:[UIImage imageNamed:@"phone_simple.png"] forState:UIControlStateNormal];
}
- (void) setCellForTexts
{
  [self.CallTextOrEmailIcon setImage:[UIImage imageNamed:@"messages_simple.png"] forState:UIControlStateNormal];
}
- (void) setCellForEmails
{
  [self.CallTextOrEmailIcon setImage:[UIImage imageNamed:@"email_simple.png"] forState:UIControlStateNormal];
}

- (void) setPrimaryContact
{
    [self.isPrimaryForCallTextOrEmailCheckMark setImage:[UIImage imageNamed:@"checkmark_circle.png"] forState:UIControlStateNormal];

}
- (void) setNotPrimaryContact
{
    [self.isPrimaryForCallTextOrEmailCheckMark setImage:[UIImage imageNamed:@"circle_empty.png"] forState:UIControlStateNormal];
 
}

- (void) hidePrimaryContactMarker
{
    
    self.isPrimaryForCallTextOrEmailCheckMark.alpha = 0.4;
    
}

- (void) showPrimaryContactMarker
{
    self.isPrimaryForCallTextOrEmailCheckMark.alpha = 1.0;
}




@end
