//
//  inTouchMasterViewController.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/3/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "inTouchMasterViewController.h"
#import "inTouchContactEditController.h"
#import "inTouchDataStore.h"
#import "inTouchMasterViewContactCell.h"
#import "inTouchSettingsViewController.h"

@interface inTouchMasterViewController ()
{
    //this object stores all data related to the contacts list
    inTouchDataStore *_dataStore;
    
    //Array of all contacts - to show in table
    NSMutableArray *_contacts;
    
}
- (void) setupCallReminderNotificationAndBadgeNumber;
- (void) UIApplicationDidEnterBackgroundNotification;
- (void) UIApplicationDidBecomeActiveNotification;

@end

@implementation inTouchMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.title = @"InTouch Always";
    
    if ( ! _dataStore)
    {
        //initialize data store with some dummy data - just to test for now
        _dataStore = [[inTouchDataStore alloc] init];
    }
    
    if (!_contacts)
    {
        //load all contacts from database
        _contacts = [ _dataStore findAllContactsStartingWith:@"" :@""];
    }
    
    //setup notifications to see when we are de-active
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UIApplicationDidEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UIApplicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // if its the first run ever - we should walk the user thru a tour
    bool UsedAppAtleastOnce = false;
    
    NSString *lval = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"inTouch_UsedAppAtleastOnce"];
    if ( lval != nil && [lval isEqualToString:@"YES"])
        UsedAppAtleastOnce = true;
    
    //mark no more first use
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"inTouch_UsedAppAtleastOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    //see if we do not have any contacts
    if ( [ _contacts count] <= 0 )
    {
        
        if ( !UsedAppAtleastOnce)
        {
            //Show the tour
            [self performSegueWithIdentifier:@"showTour" sender:self];
        }
        else    
        {
            //We have already shown the tour -  just display a friendly alert
            NSString *msg = [NSString stringWithFormat:@"Start by adding all the people you want to be inTouch with."];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"InTouch Always" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];


        }
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

- (void) UIApplicationDidEnterBackgroundNotification
{
    [self setupCallReminderNotificationAndBadgeNumber];
}

- (void) UIApplicationDidBecomeActiveNotification
{
    //reload contacts - becuase we may be getting active the next day
    _contacts = [ _dataStore findAllContactsStartingWith:@"" :@""];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // TODO Dispose of any resources that can be recreated.
}


#pragma table load from contacts array
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* called to update  Screen Cell contents for the corresponding row */
    
    //create bg colors for cells
    static UIColor *bgColorRed = nil;
    static UIColor *bgColorBlue = nil;
    static UIColor *bgColorYellow = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bgColorRed = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"red_bg.png"]];
        bgColorYellow = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"yellow_bg.png"]];
        bgColorBlue = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"blue_bg.png"]];
    });

    
    inTouchMasterViewContactCell *cell = [tableView
                                          dequeueReusableCellWithIdentifier:@"MasterViewContactCell"];
    
    inTouchContactData *contact = [_contacts objectAtIndex:indexPath.row];
    
    cell.name.text = [ NSString stringWithFormat:@"%@ %@",contact.firstName, contact.lastName];
    
    long days = [contact getDaysSinceLastContact];
    cell.contactedNDaysBack.text = [inTouchContactData getLastContactedDaysAsString:days];

    if ( contact.contact_after_ndays == 0 )
    {
        cell.nextCallMessage.text  =    [ NSString stringWithFormat:@"Call Today" ];
        [cell.callButton setImage:[UIImage imageNamed:@"phone_red.png"] forState:UIControlStateNormal];
        //cell.backgroundColor = bgColorRed;
        //cell.nextCallMessage.textColor = bgColorRed;
    }
    else
    {
        cell.nextCallMessage.text  =    [ NSString stringWithFormat:@"Call in %ld days ",contact.contact_after_ndays];
        
        if ( contact.contact_after_ndays <= 7)
        {
            [cell.callButton setImage:[UIImage imageNamed:@"phone_yellow.png"] forState:UIControlStateNormal];
            //cell.backgroundColor = bgColorYellow;
            //cell.nextCallMessage.textColor = bgColorYellow;
        }
        else
        {
            [cell.callButton setImage:[UIImage imageNamed:@"phone_blue.png"] forState:UIControlStateNormal];
            //cell.backgroundColor = bgColorBlue;
            //cell.nextCallMessage.textColor = bgColorBlue;
        }
    }
    
    cell.lastContacted.text = [ inTouchContactData getStringFromDateMMDDYY:contact.lastContacted];
        
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        inTouchContactData *contact = [_contacts objectAtIndex:indexPath.row];
        [_contacts removeObjectAtIndex:indexPath.row];
        [_dataStore removeContact:contact];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* Called to show details of a cell content */
    
    if ([[segue identifier] isEqualToString:@"showContact"])
    {
        inTouchContactViewController *view = [segue destinationViewController];
        view.delegate = self;

        //pass on the selected item
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        inTouchContactData *contact = _contacts[indexPath.row];
        
        [view setDetailItem:contact];
    }
    if ([[segue identifier] isEqualToString:@"callContact"])
    {
        inTouchContactViewController *view = [segue destinationViewController];
        view.delegate = self;
        
        //pass on the item clicked by call button
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];

        inTouchContactData *contact = _contacts[indexPath.row];
        
        view.callWhenViewWillAppear = TRUE;
        [view setDetailItem:contact];
    }
    else if ([[segue identifier] isEqualToString:@"addContact"])
    {
        inTouchContactEditController *view = [segue destinationViewController];
        view.delegate = self;
        
        inTouchContactData *contact = [[inTouchContactData alloc] init];
        [view setDetailItem:contact];
    }
    
}

#pragma inTouchDetailViewCompletedDelegate

/* called when contact data needs to be updated to database - by the add or edit  view */
- (void)updateContact:( inTouchContactData *) contact
{
    [_dataStore createOrUpdateContact:contact];
    
    //recompute contact after n days;
    contact.contact_after_ndays = [inTouchContactData calculate_contact_after_ndays:contact.contactFrequency :contact.lastContacted];
    
    //refresh main table
    _contacts = [ _dataStore findAllContactsStartingWith:@"" :@""];
    [self.tableView reloadData];
}

#pragma notification_and_badge
- (void) setupCallReminderNotificationAndBadgeNumber
{
    //cancel any existing notifications
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    
    //1. setup badge number based on how many people to call today
    //2. setup one notification on day change so we can setup the badge number when day changes next time
    //3. setup another notification at 10 AM to call people that are scheduled to be called today
    int countTobeCalledToday  = [_dataStore getTotalContactsTobeCalledToday];
    int countTobeCalledTodayAndTomorrow  = [_dataStore getTotalContactsTobeCalledTodayAndTomorrow];
    
    //1.
    app.applicationIconBadgeNumber = countTobeCalledToday;
    
    if ( countTobeCalledTodayAndTomorrow > 0 )
    {
        //load from settings
        NSString *callAtHHMMString = [inTouchSettingsViewController loadDailyCallTimeSetting];
        NSDate   *callAtHHMM = [inTouchSettingsViewController getDateFromStringHHMM :callAtHHMMString];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *componentsForCallAtHHMM = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:callAtHHMM];
        NSInteger hour = [componentsForCallAtHHMM hour];
        NSInteger minute = [componentsForCallAtHHMM minute];
        
        
        
        NSDate *now = [NSDate date];
        
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
 
        //add the day to now to make it tomorrow
        NSDate *tomorrow = [calendar dateByAddingComponents:dayComponent toDate:now options:0];

        //remove time part
        dayComponent = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:tomorrow];
        tomorrow = [calendar dateFromComponents:dayComponent];
        
   
        //set to tomorrow morning at given time
        [dayComponent setHour:hour];
        [dayComponent setMinute:minute];
        NSDate *tomorrowMorning = [calendar dateFromComponents:dayComponent];
        
        //2.
        UILocalNotification* notifyAlarmBadgeUpdateAtMidnight = [[UILocalNotification alloc] init];
        if (notifyAlarmBadgeUpdateAtMidnight)
        {
            notifyAlarmBadgeUpdateAtMidnight.fireDate = tomorrow;
            notifyAlarmBadgeUpdateAtMidnight.timeZone = [NSTimeZone defaultTimeZone];
            notifyAlarmBadgeUpdateAtMidnight.repeatInterval = 0;
            notifyAlarmBadgeUpdateAtMidnight.applicationIconBadgeNumber = countTobeCalledTodayAndTomorrow;
            [app scheduleLocalNotification:notifyAlarmBadgeUpdateAtMidnight];
        }

        
        //3.
        UILocalNotification* notifyAlarmDailyCallReminder = [[UILocalNotification alloc] init];
        if (notifyAlarmDailyCallReminder)
        {
            notifyAlarmDailyCallReminder.fireDate = tomorrowMorning;
            notifyAlarmDailyCallReminder.timeZone = [NSTimeZone defaultTimeZone];
            notifyAlarmDailyCallReminder.repeatInterval = NSDayCalendarUnit;
            notifyAlarmDailyCallReminder.alertBody = [NSString stringWithFormat:
                                                      @"You have atleast %d contacts to be called today",
                                                      countTobeCalledTodayAndTomorrow];
            
            [app scheduleLocalNotification:notifyAlarmDailyCallReminder];
        }
        
        NSLog(@"Scheduled Notification. Count Today = %d, Count Tomorrow = %d",
                                                        countTobeCalledToday,
                                                        countTobeCalledTodayAndTomorrow);
    }

}


@end
