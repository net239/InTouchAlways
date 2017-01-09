//
//  inTouchSettingsViewController.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 7/24/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchSettingsViewController.h"
#import "iRate.h"

@interface inTouchSettingsViewController ()
@property id old_delegate;
@end

@implementation inTouchSettingsViewController

static const int PICKER_TAG_DAILYCALLTIMER  = 2;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)onKeyBoardDone:(id)sender
{
    [self.view endEditing:YES];
}

//dismiss keyboard, datepicker etc when user taps on view
-(void) onViewTapped
{
    [self.view endEditing:YES];
}

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


+(void) saveDailyCallTimeSetting : (NSString *)  dailyCallTimeHHMM
{
    [[NSUserDefaults standardUserDefaults] setObject:dailyCallTimeHHMM forKey:@"inTouch_dailyCallTimeHHMM"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+( NSString *) loadDailyCallTimeSetting
{
    NSString *lval = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"inTouch_dailyCallTimeHHMM"];
    
    NSDate *date = [self getDateFromStringHHMM:lval];
    if ( date == nil)
    {
        NSDate *now = [NSDate date];

        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
        comps.hour   = 10;
        comps.minute = 0;
        comps.second = 0;
        date = [calendar dateFromComponents:comps];
    }
    
    return [self getStringFromDateHHMM:date];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.DailyCallTimer.delegate = self;
    
    self.DailyCallTimer.text = [inTouchSettingsViewController loadDailyCallTimeSetting];
    
    
    //set this up so we can dismiss keybard and datepicker and stuff when user precess somewhere in this view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewTapped)];
    [self.view addGestureRecognizer:tap];
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* doneButton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleBordered target:self
                                                                   action:@selector(onKeyBoardDone:)];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpace,doneButton1,nil]];
    
    self.DailyCallTimer.inputAccessoryView = keyboardDoneButtonView;

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.old_delegate = [iRate sharedInstance].delegate;
    [iRate sharedInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [iRate sharedInstance].delegate = self.old_delegate;
    self.old_delegate = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



//called when date picker has changed value - so we can load to corresponding text field
- (void)onDatePickerValueChanged: (id)sender
{
    if([sender isKindOfClass:[UIDatePicker class]])
    {
        UIDatePicker *datepicker = (UIDatePicker *)sender;
        if (datepicker.tag == PICKER_TAG_DAILYCALLTIMER)
        {
            self.DailyCallTimer.text = [inTouchSettingsViewController getStringFromDateHHMM :datepicker.date];
            
            [inTouchSettingsViewController saveDailyCallTimeSetting :self.DailyCallTimer.text];
        }
    }
}


//setup a Date Picker as user starts editing this text field
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //show date picker when person enters last contacted field
    if ([textField isEqual:self.DailyCallTimer])
    {
        UIDatePicker *datepicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        datepicker.tag = PICKER_TAG_DAILYCALLTIMER;
        [datepicker setDatePickerMode:UIDatePickerModeTime];
        
        
        //current date from contact data store
        NSDate *date = [inTouchSettingsViewController getDateFromStringHHMM:textField.text];
        
        if (date == nil)
        {
            //just initailaize with a date
            NSDate *now = [NSDate date];
            datepicker.date = now;
        }
        else
            datepicker.date = date;

        
        [datepicker addTarget:self
                       action:@selector(onDatePickerValueChanged:)
             forControlEvents:UIControlEventValueChanged];
        
        textField.inputView = datepicker;
        [self onDatePickerValueChanged:datepicker];
    }
    
    return YES;
}


- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}


- (IBAction)onEmail:(id)sender
{
    //get application name and version
    //application version (use short version preferentially)
    NSString *applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([applicationVersion length] == 0)
    {
        applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    
    //localised application name
    NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([applicationName length] == 0)
    {
        applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    }
    
    //bundle
    NSString *applicationBundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    
    //support email
    NSString *supportEmailDomain = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)@"SupportEmailDomain"];
    
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat: @"Email Customer Support : %@",applicationName];
    
    // Email Content
    NSString *messageBody = [NSString stringWithFormat: @"\n\n\n\n\n\n{{Application: %@ Version: %@ Bundle: %@}}",
                                                        applicationName,applicationVersion,applicationBundleName];
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject: [NSString stringWithFormat:@"support.%@@%@",
                                                                            applicationName,supportEmailDomain] ];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onRate:(id)sender
{
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (IBAction)onTour:(id)sender
{
}

- (void)iRateCouldNotConnectToAppStore:(NSError *)error
{
    
    NSString *msg = [NSString stringWithFormat:@"Could not connect to Appstore. Error: [%@]",[error localizedDescription]];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

}
@end
