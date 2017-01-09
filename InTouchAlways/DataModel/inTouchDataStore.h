//
//  inTouchDataStore.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/4/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "inTouchContactData.h"

/* Interfcae to store and load data from the contacts database */
@interface inTouchDataStore : NSObject

- (int) createOrUpdateContact: (inTouchContactData *) Contact;

//returns number of contacts removed
- (int) removeContact: (inTouchContactData *) Contact;

//find contact exactly matching this first and last name
- (inTouchContactData *) findContact: ( NSString *) firstName : (NSString *) lastName;

//find all contacts mathing names starting with
- ( NSMutableArray *) findAllContactsStartingWith: ( NSString *) firstName : (NSString *) lastName;

//Get total contacts stored
-(int) getTotalContacts;

//find number of people who are to be called today
-(int) getTotalContactsTobeCalledToday;

//find number of people who are to be called tomorrow
-(int) getTotalContactsTobeCalledTodayAndTomorrow;


@end
