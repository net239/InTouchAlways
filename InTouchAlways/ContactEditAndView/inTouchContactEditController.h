//
//  inTouchDetailViewController.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/3/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "inTouchDataStore.h"
#import "inTouchContactListTableViewController.h"


//to pass data back to the caller
@protocol inTouchContactEditCompletedDelegate <NSObject>
- (void)updateContact:( inTouchContactData *) contact;
@end


@interface inTouchContactEditController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UIAlertViewDelegate,
    UIActionSheetDelegate,inTouchContactListCompletedDelegate>


@property (strong, nonatomic) id detailItem;
@property id<inTouchContactEditCompletedDelegate>  delegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *lastContacted;
@property (weak, nonatomic) IBOutlet UITextField *contactFrequency;
@property (weak, nonatomic) IBOutlet UITextView  *notes;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchContactsButton;

@property (weak, nonatomic) IBOutlet UITextField *textMessageNumber;
@property (weak, nonatomic) IBOutlet UITextField *eMail;

- (IBAction)onCancel:(id)sender;
- (IBAction)onDone:(id)sender;

- (IBAction)onKeyBoardDone:(id)sender;
- (IBAction)onKeyBoardSearchContacts:(id)sender;

@end
