//
//  inTouchSettingsViewController.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 7/24/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "iRate.h"

@interface inTouchSettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,
                                                    iRateDelegate,UITextFieldDelegate >
- (IBAction)onEmail:(id)sender;
- (IBAction)onRate:(id)sender;
- (IBAction)onTour:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *DailyCallTimer;

+(void) saveDailyCallTimeSetting : (NSString *)  dailyCallTimeHHMM;
+( NSString *) loadDailyCallTimeSetting;

+ (NSDate * ) getDateFromStringHHMM: (NSString *) str;
+ (NSString * ) getStringFromDateHHMM:(NSDate *)date;

@end
