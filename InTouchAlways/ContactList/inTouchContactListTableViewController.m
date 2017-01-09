//
//  inTouchContactListTableViewController.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/13/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchContactListTableViewController.h"
#import "inTouchContactListTableViewCell.h"
#import "inTouchContactDataExtended.h"
#import "inTouchContactListRow.h"


@interface inTouchContactListTableViewController ()
@property NSMutableArray  * tableRows;
@end
    

@implementation inTouchContactListTableViewController

- (void) loadMatchingAddressBookEntries : (NSArray * ) matchingAddressBookEntries
{
    //initialize the rows to reflect
    //all rows are top level - as the user clicks
    //on a particular row - we will expand my insertign more rows
    //and setting rowProperites accordingly
    self.tableRows = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [matchingAddressBookEntries count] ; ++i)
    {
        inTouchContactListRow *row = [[inTouchContactListRow alloc] init];
        
        row.indentLevel = 0;
        row.isRowExpanded = NO;
        row.childItemIndex = 0;
        row.contact = [matchingAddressBookEntries objectAtIndex:i];
        
        
        [self.tableRows insertObject:row atIndex:i ];
    }
    
 }


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // TODO Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tableRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* called to update  Screen Cell contents for the corresponding row */
    
    
    inTouchContactListRow *row = [self.tableRows objectAtIndex:indexPath.row];
    inTouchContactDataExtended *contact = row.contact;
    inTouchContactListTableViewCell *cell = nil;
    
    if (row.indentLevel == 0 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"contactListParentRow"];
        

        //top level item
        cell.name.text = [ NSString stringWithFormat:@"%@ %@",contact.firstName, contact.lastName];
    
        cell.expandCollapseButton.alpha = 1.0;
        
        if ( row.isRowExpanded)
        {
            [cell setButtonExpanded];
        }
        else
        {
            [cell setButtonCollapsed];
        }
        cell.phone.text = @"";
    }
    else if (row.indentLevel == 1)
    {
        //sub item
        cell = [tableView dequeueReusableCellWithIdentifier:@"contactListSubItemRow"];
        
        //hide the expandCollapse Button
        cell.expandCollapseButton.alpha = 0.0;

        cell.name.text  = @"";
        InTouchContactChildItemDetails  *childItemDetails = [ contact.ChildItems objectAtIndex:row.childItemIndex];
        
        if ( childItemDetails.childItemType== ChildItemIsForEmails)
        {
            cell.phone.text = [ NSString stringWithFormat:@"%@: %@",childItemDetails.Label, childItemDetails.Value];
            [cell setCellForEmails];
        }
        
        if ( childItemDetails.childItemType == ChildItemIsForCalls )
        {
           cell.phone.text = [ NSString stringWithFormat:@"%@: %@",childItemDetails.Label, childItemDetails.Value];
            [cell setCellForCall];
        }
        
        if ( childItemDetails.childItemType == ChildItemIsForTexts)
        {
           cell.phone.text = [ NSString stringWithFormat:@"%@: %@",childItemDetails.Label, childItemDetails.Value];
            [cell setCellForTexts];
        }
        
        if ( childItemDetails.isPrimaryContact)
            [cell setPrimaryContact];
        else
            [cell setNotPrimaryContact];
        
        if ( childItemDetails.isThisOnlyChilItemOfThisType)
            [cell hidePrimaryContactMarker];
        else
            [cell showPrimaryContactMarker];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self expandOrCollapseRow:indexPath];
}

-(void) expandOrCollapseRow:(NSIndexPath *)indexPath
{
    inTouchContactListRow *selectedRow = [self.tableRows objectAtIndex:indexPath.row];
    inTouchContactDataExtended *contact = selectedRow.contact;
    
    if ( selectedRow.indentLevel == 0 )
    {
        //user selected a top level item
        //check if we are already expanded
        if (selectedRow.isRowExpanded)
        {
            //we are already expanded - lets collapse the child items
            NSMutableArray *subItemRows=[NSMutableArray array];
            NSUInteger removeRowAt=indexPath.row+1;
            
            //mark the row of "parent" as collapsed
            selectedRow.isRowExpanded = NO;
            
            //collect all rows to remove
           
            for (int i = 0 ; i < [ contact.ChildItems count]; ++i)
            {
                //collect this row to be removed from table view
                [subItemRows addObject:[NSIndexPath indexPathForRow:removeRowAt inSection:0]];
                
                //remove from our own tablerow collection object
                [self.tableRows removeObjectAtIndex:indexPath.row+1];

                ++removeRowAt;
            }
            
            //remove all children and refresh parent to show its collapsed
            NSMutableArray *parentItemRows=[NSMutableArray array];
            [parentItemRows addObject:indexPath];
            
            
            [self.contactListTableView deleteRowsAtIndexPaths:subItemRows withRowAnimation:UITableViewRowAnimationLeft];
            [self.contactListTableView reloadRowsAtIndexPaths:parentItemRows withRowAnimation:UITableViewRowAnimationLeft];

        }  //exapnded
        else
        {
        
            //now we need to "expand" by inserting all the rows and indenting cells
            NSMutableArray *subItemRows=[NSMutableArray array];
            NSUInteger insertRowAt=indexPath.row+1;
            
            //mark the row of "parent" as expanded
            selectedRow.isRowExpanded = YES;
            int parentIndentLevel = selectedRow.indentLevel;
            
            for (int i = 0 ; i < [ contact.ChildItems count]; ++i)
            {
                
                [subItemRows addObject:[NSIndexPath indexPathForRow:insertRowAt inSection:0]];
                inTouchContactListRow *newSubItemRow = [[inTouchContactListRow alloc] init];
                
                newSubItemRow.contact = contact;
                newSubItemRow.childItemIndex = i;
                newSubItemRow.indentLevel = parentIndentLevel + 1;
                
                [self.tableRows insertObject:newSubItemRow atIndex:insertRowAt];
                ++insertRowAt;

            }
            
            
            //insert all children and refresh parent to show its expanded
            NSMutableArray *parentItemRows=[NSMutableArray array];
            [parentItemRows addObject:indexPath];
            
            [self.contactListTableView insertRowsAtIndexPaths:subItemRows withRowAnimation:UITableViewRowAnimationLeft];
            [self.contactListTableView reloadRowsAtIndexPaths:parentItemRows withRowAnimation:UITableViewRowAnimationLeft];

            
        } //expand child
    } //parent
    else
    {
        //user select a child sub item
        InTouchContactChildItemDetails  *childItemDetails = [ contact.ChildItems objectAtIndex:selectedRow.childItemIndex];
        
        //loop at select all primary checked items AND this particular row - make this as primary
        //since user selected it !
        
        for (int i = 0 ; i < [ contact.ChildItems count]; ++i)
        {
            //mark everything else non primary for this particular item type
            InTouchContactChildItemDetails  *n =[ contact.ChildItems objectAtIndex:i];
            
            if ( n.childItemType == childItemDetails.childItemType)
            {
                n.isPrimaryContact = NO;
            }
            
            if ( n.isPrimaryContact )
            {
                if ( n.childItemType == ChildItemIsForCalls)
                    contact.phoneNumber = n.Value;
                else if ( n.childItemType == ChildItemIsForTexts)
                    contact.cellPhoneNumber = n.Value;
                else if ( n.childItemType == ChildItemIsForEmails)
                    contact.email = n.Value;
            }
        }
        
        childItemDetails.isPrimaryContact = YES;
        if ( childItemDetails.childItemType == ChildItemIsForCalls)
            contact.phoneNumber = childItemDetails.Value;
        else if ( childItemDetails.childItemType == ChildItemIsForTexts)
            contact.cellPhoneNumber = childItemDetails.Value;
        else if ( childItemDetails.childItemType == ChildItemIsForEmails)
            contact.email = childItemDetails.Value;

        //inform our delegate that user selected this row
        [self.delegate  updateUserContactSelectionFromListPresented:contact];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}




- (IBAction)onExpandOrCollapse:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    
    [self expandOrCollapseRow:indexPath];
}

- (IBAction)onPrimaryCheckMark:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    inTouchContactListRow *row = [self.tableRows objectAtIndex:indexPath.row];
    inTouchContactDataExtended *contact = row.contact;
    
    if ( row.indentLevel == 1 )
    {
        InTouchContactChildItemDetails  *childItemDetails = [ contact.ChildItems objectAtIndex:row.childItemIndex];
        
        //if this is primary - no need to do anything
        if ( ! childItemDetails.isPrimaryContact)
        {
            //find the row for the first chid item for thic contact
            NSUInteger rowForFirstChildItem = indexPath.row - row.childItemIndex;
            
            for (int i = 0 ; i < [ contact.ChildItems count]; ++i)
            {
                //mark everything else non primary
                InTouchContactChildItemDetails  *n =[ contact.ChildItems objectAtIndex:i];
                
                if ( n.childItemType == childItemDetails.childItemType)
                {
                    n.isPrimaryContact = NO;
                    
                    //index path of this row, can be calculated - relative to the current item row
                    NSUInteger  rowForThisChildItem = rowForFirstChildItem + i;
                    NSIndexPath *indexPathForThisItem = [NSIndexPath indexPathForRow:rowForThisChildItem inSection:0];
                    
                    [self.contactListTableView  reloadRowsAtIndexPaths:@[indexPathForThisItem]
                                                            withRowAnimation:UITableViewRowAnimationNone];
                    
                }
                
            }
            
            childItemDetails.isPrimaryContact = YES;
            [self.contactListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

        }
    
    }
}


@end
