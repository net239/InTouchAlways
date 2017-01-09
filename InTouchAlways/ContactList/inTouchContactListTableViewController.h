//
//  inTouchContactListTableViewController.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/13/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "inTouchContactData.h"

//to pass data back to the caller
@protocol inTouchContactListCompletedDelegate <NSObject>

//pass on the the information about the matching contact that user select
//from the list presented
- (void)updateUserContactSelectionFromListPresented:( inTouchContactData *) contact;
@end


@interface inTouchContactListTableViewController : UITableViewController

//list of matching contacts that is dispayed to user - so he could select one
-(void) loadMatchingAddressBookEntries: (NSArray *) matchingAddressBookEntries;

//flip - expand or collapse
-(void) expandOrCollapseRow:(NSIndexPath *)indexPath;

//called when user has selected an item 
@property id<inTouchContactListCompletedDelegate>  delegate;

@property (strong, nonatomic) IBOutlet UITableView *contactListTableView;
- (IBAction)onExpandOrCollapse:(id)sender;
- (IBAction)onPrimaryCheckMark:(id)sender;

@end
