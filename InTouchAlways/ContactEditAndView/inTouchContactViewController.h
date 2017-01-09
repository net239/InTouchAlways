//
//  inTouchDetailsViewController.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/18/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "inTouchDataStore.h"
#import "inTouchContactEditController.h"
#import <MessageUI/MessageUI.h>


//to pass data back to the caller
@protocol inTouchContactViewUpdateContactDelegate <NSObject>
- (void)updateContact:( inTouchContactData *) contact;
@end

@interface inTouchContactViewController : UIViewController
                  < inTouchContactEditCompletedDelegate,
                    MFMessageComposeViewControllerDelegate,
                    MFMailComposeViewControllerDelegate,
                    UINavigationControllerDelegate>

//set by caller - to display the content of the item ( Contact )
@property (strong, nonatomic) id detailItem;
@property id<inTouchContactViewUpdateContactDelegate>  delegate;

//call as soon as the view is loaded (usvally from mains screen call button
@property bool   callWhenViewWillAppear;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *primaryPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *primaryTextNumber;
@property (weak, nonatomic) IBOutlet UILabel *primaryEmail;

@property (weak, nonatomic) IBOutlet UITextView *notes;
@property (weak, nonatomic) IBOutlet UILabel *nextCallMessage;
@property (weak, nonatomic) IBOutlet UILabel *lastContacted;
@property (weak, nonatomic) IBOutlet UILabel *contactedNDaysBack;
@property (weak, nonatomic) IBOutlet UILabel *frequency;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *msgButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

- (IBAction)callPrimaryPhoneNumber:(id)sender;
- (IBAction)msgPrimaryTextNumber:(id)sender;
- (IBAction)emailPrimaryEmailAddress:(id)sender;

@end
