//
//  inTouchDetailsViewController.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/18/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchContactViewController.h"
#import "inTouchContactEditController.h"

typedef enum {
    CONTACT_METHOD_EMAIL,
    CONTACT_METHOD_SMS = 1,
    CONTACT_METHOD_PHONE = 7,
 } ContactMethod;


@interface inTouchContactViewController ()

//used to set the state just before a call is initiated
@property (atomic)   bool isCallInitiated;
@property (atomic)   bool didEnterBackGroundAfterCallInitiated;

- (void) UIApplicationDidBecomeActiveNotification;
- (void) UIApplicationDidEnterBackgroundNotification;
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

//update notes and last contacted dates once we have successfully contacted the person
- (void ) updateLastContactedDateAndNotes : (ContactMethod) contactMethod;

//see if we are running on ios8 or later
- (BOOL)isIOS8OrHigher;

//get phone URL
- (NSURL *) getPhoneURL;
@end

@implementation inTouchContactViewController

static const int ALTERVIEW_TAG_CALLOK         = 1;
static const int ALTERVIEW_TAG_CONFIRM_TO_CALL   = 2;

#pragma mark - Managing the detail item

- (BOOL)isIOS8OrHigher
{
    NSOperatingSystemVersion ios8_0_0 = (NSOperatingSystemVersion){8, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios8_0_0]) {
        return YES;
    } else
    {
        return NO;
    }
}

- (NSURL *) getPhoneURL
{
    
    //remove white spaces
    NSString *phNo = self.primaryPhoneNumber.text;
    NSArray* words = [phNo componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* noSpacePhNo = [words componentsJoinedByString:@""];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",noSpacePhNo]];
    
    return phoneUrl;
}

- (void)setDetailItem:(id)newDetailItem
{
    _detailItem = newDetailItem;
}

- (void)loadItemtoView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        inTouchContactData *contact = self.detailItem;
        
        self.name.text = [NSString stringWithFormat:@"%@ %@",contact.firstName, contact.lastName];
        self.lastContacted.text = [inTouchContactData getStringFromDateMMDDYY:contact.lastContacted];
        self.frequency.text = [inTouchContactData getContactFrequencyStringFromEnum:contact.contactFrequency];
        self.primaryPhoneNumber.text = [inTouchContactData formatAsPhoneNumber:contact.phoneNumber];
        self.primaryTextNumber.text = [inTouchContactData formatAsPhoneNumber:contact.cellPhoneNumber];
        self.primaryEmail.text = contact.email;
        
        self.notes.text = contact.notes;
        
        
        long days = [contact getDaysSinceLastContact];
        self.contactedNDaysBack.text = [inTouchContactData getLastContactedDaysAsString:days];

        
        if ( contact.contact_after_ndays == 0 )
        {
            self.nextCallMessage.text  =    [ NSString stringWithFormat:@"Call Today" ];
            
            [self.callButton setImage:[UIImage imageNamed:@"phone_simple_red.png"] forState:UIControlStateNormal];
            [self.msgButton setImage:[UIImage imageNamed:@"messages_simple_red.png"] forState:UIControlStateNormal];
            [self.emailButton setImage:[UIImage imageNamed:@"email_simple_red.png"] forState:UIControlStateNormal];
        }
        else
        {
            self.nextCallMessage.text  =    [ NSString stringWithFormat:@"Call in %ld days ",contact.contact_after_ndays];
            
            if ( contact.contact_after_ndays <= 7)
            {
                [self.callButton setImage:[UIImage imageNamed:@"phone_simple_yellow.png"] forState:UIControlStateNormal];
                [self.msgButton setImage:[UIImage imageNamed:@"messages_simple_yellow.png"] forState:UIControlStateNormal];
                [self.emailButton setImage:[UIImage imageNamed:@"email_simple_yellow.png"] forState:UIControlStateNormal];
            }
            else
            {
                [self.callButton setImage:[UIImage imageNamed:@"phone_simple_blue.png"] forState:UIControlStateNormal];
                [self.msgButton setImage:[UIImage imageNamed:@"messages_simple_blue.png"] forState:UIControlStateNormal];
                [self.emailButton setImage:[UIImage imageNamed:@"email_simple_blue.png"] forState:UIControlStateNormal];
            }
        }
        
        self.lastContacted.text = [ inTouchContactData getStringFromDateMMDDYY:contact.lastContacted];
        
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //setup notifications to see when we are active
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UIApplicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UIApplicationDidEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    //TODO Remove these hard coded values
    [[self.notes layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.notes layer] setBorderWidth:.2];
    [[self.notes layer] setCornerRadius:6];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadItemtoView];
    
    if ( self.callWhenViewWillAppear)
    {
        //reset this flag, so we don't initiate call every time
        self.callWhenViewWillAppear = false;
        
        [self callPrimaryPhoneNumber:self];
    }
    
    [super viewWillAppear :animated];
} 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // TODO Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* Called to show details of a cell content */
    
    if ([[segue identifier] isEqualToString:@"editContact"])
    {
        inTouchContactData *contact = self.detailItem;
        
    
        inTouchContactEditController *view = [segue destinationViewController];
        view.delegate = self;
        
        [[segue destinationViewController] setDetailItem:contact];
    }
}


/* called when contact data needs to be updated to database - by the edit  view */
- (void)updateContact:( inTouchContactData *) contact
{
    // update our main controller
    [_delegate updateContact:contact];
    
}


#pragma CallNow
- (IBAction)callPrimaryPhoneNumber:(id)sender
{
    
    inTouchContactData *contact = self.detailItem;
    NSURL *phoneUrl = [self getPhoneURL];
    NSString *phNo = self.primaryPhoneNumber.text;
    NSArray* words = [phNo componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* noSpacePhNo = [words componentsJoinedByString:@""];
    
    //validate the phone number
    if ( [inTouchContactData isValidPhone:phNo] &&
        [[UIApplication sharedApplication] canOpenURL:phoneUrl]
        )
    {
        //ask user if they were able to talk to the person
        NSString *msg = [NSString stringWithFormat:@"Call %@ %@ %@? " ,
                         contact.firstName, contact.lastName, phNo
                         ];
        UIAlertView *alert = [[UIAlertView alloc]   initWithTitle:@"Confirm" message:msg
                               delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil
                              ];
        alert.delegate = self;
        alert.tag = ALTERVIEW_TAG_CONFIRM_TO_CALL;
        
        [alert show];

    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"Cannot call %@. Please check the Phone Number",noSpacePhNo];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (IBAction)msgPrimaryTextNumber:(id)sender
{
    
    NSString *msgNo = self.primaryTextNumber.text;
    NSArray* words = [msgNo componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* noSpaceMsgNo = [words componentsJoinedByString:@""];
    
    NSURL *msgUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"sms:%@",noSpaceMsgNo]];
    
    //validate the phone number
    if ( [inTouchContactData isValidPhone:msgNo] &&
        [[UIApplication sharedApplication] canOpenURL:msgUrl]
        )
    {
        [self.msgButton setEnabled:NO];
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = @"";
            controller.recipients = [NSArray arrayWithObjects:noSpaceMsgNo,nil];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"Cannot SMS %@. Please check the Text Number",noSpaceMsgNo];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.msgButton setEnabled:YES];
    
    switch (result) {
        case MessageComposeResultCancelled:
        {
            NSLog(@"Cancelled");
            break;
        }
        case MessageComposeResultFailed:
        {
            NSString *msg = [NSString stringWithFormat:@"Cannot SMS %@. Please check the Text Number",@""];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            break;
        }
        case MessageComposeResultSent:
        {
            [self updateLastContactedDateAndNotes:CONTACT_METHOD_SMS];
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)emailPrimaryEmailAddress:(id)sender
{
    
    //localised application name
    NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([applicationName length] == 0)
    {
        applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    }
    
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat: @""];
    
    // Email Content
    NSString *messageBody = [NSString stringWithFormat: @"\n\n\n\n\n\nSent using %@",
                             applicationName];
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject: [NSString stringWithFormat:@"%@",
                                                      self.primaryEmail.text] ];
    
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
            [self updateLastContactedDateAndNotes:CONTACT_METHOD_EMAIL];
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

- (void) UIApplicationDidBecomeActiveNotification
{
    
    //see if we had initiated a call
    inTouchContactData *contact = self.detailItem;
    
    bool confirmWereAbleToCall = NO;
    if ( ![ self isIOS8OrHigher] )
    {
        confirmWereAbleToCall = self.isCallInitiated && self.didEnterBackGroundAfterCallInitiated && contact != nil;
    }
    else
    {
        //IOS 8 does not put application to background in a tel call ...
        confirmWereAbleToCall = self.isCallInitiated && contact != nil;
    }
    
    
    if ( confirmWereAbleToCall)
    {
        self.isCallInitiated = false;
        self.didEnterBackGroundAfterCallInitiated = false;
        
        //ask user if they were able to talk to the person
        NSString *msg = [NSString stringWithFormat:@"Were you able to talk to %@ %@? " ,
                         contact.firstName, contact.lastName];
        UIAlertView *alert = [[UIAlertView alloc]   initWithTitle:@"Confirm" message:msg delegate:nil
                                                cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.delegate = self;
        alert.tag = ALTERVIEW_TAG_CALLOK;
        
        [alert show];
    }
    else
    {
        self.isCallInitiated = false;
        self.didEnterBackGroundAfterCallInitiated = false;
    }
    
}

- (void ) UIApplicationDidEnterBackgroundNotification
{
    if ( self.isCallInitiated)
        self.didEnterBackGroundAfterCallInitiated = true;
}

- (void ) updateLastContactedDateAndNotes : (ContactMethod) contactMethod
{
    inTouchContactData *contact = self.detailItem;
    
    NSDate *now = [NSDate date];
    
    //see if notes is empty
    NSArray* words = [contact.notes componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* noSpace = [words componentsJoinedByString:@""];
    
    //update notes
    NSString *prefix = @"";
    if ([noSpace length] == 0 )
    {
        if ( contactMethod == CONTACT_METHOD_EMAIL)
            prefix = @"[Emailed on:";
        else if ( contactMethod == CONTACT_METHOD_SMS)
            prefix = @"[Texted on:";
        else if ( contactMethod == CONTACT_METHOD_PHONE)
            prefix = @"[Called on:";
    }
    else
    {
        if ( contactMethod == CONTACT_METHOD_EMAIL)
            prefix = @"\n[Emailed on:";
        else if ( contactMethod == CONTACT_METHOD_SMS)
            prefix = @"\n[Texted on:";
        else if ( contactMethod == CONTACT_METHOD_PHONE)
            prefix = @"\n[Called on:";
    }
    
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [newFormatter setDateStyle:NSDateFormatterShortStyle];
    [newFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSString *updatedNotes = [NSString stringWithFormat:@"%@%@%@]\n",
                              contact.notes,
                              prefix,
                              [newFormatter stringFromDate:now]
                              ];
    
    contact.notes = updatedNotes;

    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag == ALTERVIEW_TAG_CALLOK && buttonIndex == 1)
    {
        [self updateLastContactedDateAndNotes:CONTACT_METHOD_PHONE];
        
        //change the last contacted date
        inTouchContactData *contact = self.detailItem;
        NSDate *now = [NSDate date];
        contact.lastContacted = now;
        
        
        //call delegate to save the contents to database
        [_delegate updateContact:self.detailItem];
        
        //reload view
        [self loadItemtoView];
    
    }
    else if (alertView.tag == ALTERVIEW_TAG_CONFIRM_TO_CALL && buttonIndex == 1)
    {
        NSURL *phoneUrl = [self getPhoneURL];

        static UIWebView *callWebView = nil;
        if ( ! [ self isIOS8OrHigher] )
        {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                callWebView = [UIWebView new];
            });
        }
        
        self.isCallInitiated = true;
        
        
        if ( ![ self isIOS8OrHigher] )
        {
            [callWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
        }
        else
        {
            //in ios8 when we launch using tel:: AND control does come back to the app
            //if we use the above call in ios8 it invokes tell prompt but does name make the
            //app goto back ground, we cannot properly confirm if user was able to speak to the contact
            [[UIApplication sharedApplication] openURL:phoneUrl];
        }
    }
    
}



@end
