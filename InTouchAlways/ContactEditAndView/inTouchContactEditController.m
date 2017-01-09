//
//  inTouchDetailViewController.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/3/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "inTouchContactEditController.h"
#import "inTouchAddressBookInterface.h"


@interface inTouchContactEditController ()

//interface to iphone addressbook
@property inTouchAddressBookInterface* addressBook;
@property NSArray *matchingAddressBookEntries;

- (void) loadItemtoView;
- (void) saveItemFromView;
@end

@implementation inTouchContactEditController

static const int DATEPICKER_TAG_LASTCONTACTED = 1;
static const int PICKER_TAG_CONTACTFREQUENCY  = 2;


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
    {
        _detailItem = newDetailItem;
    }
}

- (void)loadItemtoView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        inTouchContactData *contact = self.detailItem;
        
        self.firstName.text =contact.firstName;
        self.lastName.text =contact.lastName;
        
        self.lastContacted.text = [inTouchContactData getStringFromDateMMDDYY:contact.lastContacted];
        self.contactFrequency.text = [inTouchContactData getContactFrequencyStringFromEnum:contact.contactFrequency];
        self.phoneNumber.text = [inTouchContactData formatAsPhoneNumber:contact.phoneNumber];
        self.textMessageNumber.text = [inTouchContactData formatAsPhoneNumber:contact.cellPhoneNumber];
        self.eMail.text = [inTouchContactData formatAsPhoneNumber:contact.email];
        self.notes.text = contact.notes;

    }
}

- (void) saveItemFromView
{
    if (self.detailItem)
    {

        inTouchContactData *contact = self.detailItem;
        
        contact.firstName = self.firstName.text;
        contact.lastName = self.lastName.text;
        
        contact.lastContacted = [inTouchContactData getDateFromStringMMDDYY:self.lastContacted.text];
        contact.contactFrequency = [inTouchContactData getContactFrequencyEnumFromString:self.contactFrequency.text];
        contact.phoneNumber = self.phoneNumber.text;
        contact.cellPhoneNumber = self.textMessageNumber.text;
        contact.email = self.eMail.text;
        contact.notes = self.notes.text;
        
        //call delegate to save the contents to database
        [_delegate updateContact:self.detailItem];
    }
   
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //address book
    if (self.addressBook == nil)
        self.addressBook = [[inTouchAddressBookInterface alloc] init];
    
    
    
    //so that we can hide the key board when user presses return
    //and to get other notifications from text fields like when editting has started etc.
    self.firstName.delegate = self;
    self.lastName.delegate = self;
    self.phoneNumber.delegate = self;
    self.textMessageNumber.delegate = self;
    self.eMail.delegate = self;
    self.lastContacted.delegate = self;
    self.contactFrequency.delegate = self;
    self.notes.delegate = self;
    
    //TODO Remove these hard coded values
    [[self.notes layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.notes layer] setBorderWidth:.2];
    [[self.notes layer] setCornerRadius:6];
    
    //set this up so we can dismiss keybard and datepicker and stuff when user precess somewhere in this view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewTapped)];
    [self.view addGestureRecognizer:tap];
    
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    UIToolbar* keyboardDoneAndSearchButtonView = [[UIToolbar alloc] init];
    
    
    [keyboardDoneButtonView sizeToFit];
    [keyboardDoneAndSearchButtonView sizeToFit];
    
    
    UIBarButtonItem* searchContactsButton = [[UIBarButtonItem alloc] initWithTitle:@"Search Contacts"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(onKeyBoardSearchContacts:)];
    
    
    UIBarButtonItem* doneButton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(onKeyBoardDone:)];
    UIBarButtonItem* doneButton2 = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(onKeyBoardDone:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];


    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpace,doneButton1,nil]];
    [keyboardDoneAndSearchButtonView setItems:[NSArray arrayWithObjects:searchContactsButton,flexibleSpace,doneButton2, nil]];
    
    
    self.firstName.inputAccessoryView = keyboardDoneAndSearchButtonView;
    self.lastName.inputAccessoryView = keyboardDoneAndSearchButtonView;
    self.phoneNumber.inputAccessoryView = keyboardDoneAndSearchButtonView;
    self.textMessageNumber.inputAccessoryView = keyboardDoneAndSearchButtonView;
    self.eMail.inputAccessoryView = keyboardDoneAndSearchButtonView;
    self.lastContacted.inputAccessoryView = keyboardDoneButtonView;
    self.contactFrequency.inputAccessoryView = keyboardDoneButtonView;
    self.notes.inputAccessoryView = keyboardDoneButtonView;
    
    // Update the view.
    [self loadItemtoView];
}

- (IBAction)onKeyBoardDone:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)onKeyBoardSearchContacts:(id)sender
{
    
    bool showContactList = [self shouldPerformSegueWithIdentifier:@"showContactPickList" sender:self];
    
    if (showContactList)
    {
        [self performSegueWithIdentifier:@"showContactPickList" sender:self];
        [self.view endEditing:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma text fields

//dismiss keyboard, datepicker etc when user taps on view
-(void) onViewTapped
{
    [self.view endEditing:YES];
}

//dismiss keyboard when user presses return
-(BOOL) textFieldShouldReturn:(UITextField *) textFieldView
{
    [self.view endEditing:YES];
    return NO;
}


/* These methods ensure the text fields and views are moved up so keyboard does not hide them */
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGPoint scrollPoint = CGPointMake(0, textView.frame.origin.y - 20 );
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

//move the text field down as user is done editting
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

//move text field up as user starts editting
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

//move the text field down as user is done editting
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma Date Picker

+ (NSDate * ) getDateFromStringHHMM: (NSString *) str
{
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [newFormatter setDateStyle:NSDateFormatterNoStyle];
    [newFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [newFormatter dateFromString:str];
}

+ (NSString * ) getStringFromDateHHMM:(NSDate *)date
{
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [newFormatter setDateStyle:NSDateFormatterNoStyle];
    [newFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [newFormatter stringFromDate:date];
}


//setup a Date Picker as user starts editing this text field
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //show date picker when person enters last contacted field
    if ([textField isEqual:self.lastContacted])
    {
        UIDatePicker *datepicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        datepicker.tag = DATEPICKER_TAG_LASTCONTACTED;
        [datepicker setDatePickerMode:UIDatePickerModeDate];
        
        [datepicker addTarget:self
                       action:@selector(onValueChanged:)
             forControlEvents:UIControlEventValueChanged];
        
        
        //max date today
        datepicker.maximumDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        
        //current date from contact data store
        NSDate *date = [inTouchContactData getDateFromStringMMDDYY:textField.text];
        
        if (date == nil)
        {
            //just initailaize with a date 
            NSDate *now = [NSDate date];
            datepicker.date = now;
        }
        else
            datepicker.date = date;
        
        textField.inputView = datepicker;
        [self onValueChanged:datepicker];
    }
    else if ( [ textField isEqual:self.contactFrequency])
    {
        UIPickerView *optionpicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        optionpicker.tag = PICKER_TAG_CONTACTFREQUENCY;

        //to receive data and other delegate events
        optionpicker.delegate = self;
        
        //initialize
        ContactFrequency  frequency = [inTouchContactData getContactFrequencyEnumFromString:textField.text];
        if ( frequency == CONTACT_UNKNOWN)
            frequency = CONTACT_WEEKLY;
        
        textField.inputView = optionpicker;
        [optionpicker selectRow: [inTouchContactData getIndexInAllContactFrequencyOptions:frequency] inComponent:0 animated:YES];
    }
    
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.phoneNumber])
    {
        self.phoneNumber.text = [inTouchContactData formatAsPhoneNumber:self.phoneNumber.text];

    }
    if ([textField isEqual:self.textMessageNumber])
    {
        self.textMessageNumber.text = [inTouchContactData formatAsPhoneNumber:self.textMessageNumber.text];
        
    }
    
    return YES;
}


//called when date picker has changed value - so we can load to corresponding text field
- (void)onValueChanged: (id)sender
{
    if([sender isKindOfClass:[UIDatePicker class]])
    {
        UIDatePicker *datepicker = (UIDatePicker *)sender;
        if (datepicker.tag == DATEPICKER_TAG_LASTCONTACTED)
        {
            self.lastContacted.text = [inTouchContactData getStringFromDateMMDDYY:datepicker.date];
        }
    }
}


#pragma mark PickerView

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [inTouchContactData getTotalContactFrequencyOptions];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [inTouchContactData getContactFrequencyStringFromEnum: ContactFrequencyOptionsArray[row] ];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if (pickerView.tag == PICKER_TAG_CONTACTFREQUENCY)
    {
        self.contactFrequency.text = [inTouchContactData getContactFrequencyStringFromEnum: ContactFrequencyOptionsArray[row] ];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL performSegue = YES;
    
    if ([identifier isEqualToString:@"showContactPickList"])
    {
         //see if this name matches in addressbook
         self.matchingAddressBookEntries = [self.addressBook findAllContactsStartingWith:self.firstName.text :self.lastName.text];
         
         if ( self.matchingAddressBookEntries && [self.matchingAddressBookEntries count] <= 0)
         {
             NSString *msg = [NSString stringWithFormat:@"No matching contacts found in Addressbook"];
             
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
             
             performSegue = NO;
         }
    }
    return performSegue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* Called to show details of a cell content */
    
    if ([[segue identifier] isEqualToString:@"showContactPickList"])
    {
        inTouchContactListTableViewController *contactListView = [segue destinationViewController];
        contactListView.delegate = self;
        
        [[segue destinationViewController] loadMatchingAddressBookEntries:self.matchingAddressBookEntries];
    }
    
}

- (void)updateUserContactSelectionFromListPresented:( inTouchContactData *) contact
{
    
    self.firstName.text = contact.firstName;
    self.lastName.text = contact.lastName;
    self.phoneNumber.text = contact.phoneNumber;
    self.textMessageNumber.text = contact.cellPhoneNumber;
    self.eMail.text = contact.email;
    
    self.phoneNumber.text = [inTouchContactData formatAsPhoneNumber:self.phoneNumber.text];
    self.textMessageNumber.text = [inTouchContactData formatAsPhoneNumber:self.textMessageNumber.text];
    
}


#pragma ExitView
- (IBAction)onCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender
{
    //validate
    bool validationOK  = YES;
    
    //check if the first name has been made empty
    NSArray* words = [self.firstName.text componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* noSpace = [words componentsJoinedByString:@""];
    
    if ([noSpace length] == 0 )
    {
        validationOK = NO;
        
        NSString *msg = [NSString stringWithFormat:@"First Name can not be blank"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

    if (validationOK)
    {
        //save the contents
        [self saveItemFromView];
    
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
