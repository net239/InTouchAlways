//
//  inTouchContactData.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/4/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Class to store user data - in data base and for passing around the app */

/* NOTE  MAKE SURE  TO add to ContactFrequencyOptionsArray If you add or remove more enums in ContactFrequency
         These enums are defined to be equivalent to frequency in days, so its easy to read and map 
         them from database
 */
typedef enum {
    CONTACT_UNKNOWN = -1,
    CONTACT_DAILY = 1,
    CONTACT_WEEKLY = 7,
    CONTACT_MONTHLY = 30,
    CONTACT_THREEMONTHS = 90,
    CONTACT_SIXMONTHS = 180,
    CONTACT_YEARLY = 365,
} ContactFrequency;

//All contact frequency options
const static int ContactFrequencyOptionsArray[] =   {   CONTACT_DAILY,CONTACT_WEEKLY,CONTACT_MONTHLY,
                                                        CONTACT_THREEMONTHS,CONTACT_SIXMONTHS,
                                                        CONTACT_YEARLY
                                                    };

@interface inTouchContactData : NSObject

//basic information stored per contact
@property NSString          *firstName;
@property NSString          *lastName;
@property NSDate            *lastContacted;
@property ContactFrequency  contactFrequency;
@property NSString          *notes;
@property NSString          *phoneNumber;

//Added in second release
@property NSString          *cellPhoneNumber;
@property NSString          *homePhoneNumber;
@property NSString          *workPhoneNumber;
@property NSString          *email;



//automatically calculated by SQL query - when record is fetched from database
@property long               contact_after_ndays;

//number of days since last contacted
- (long) getDaysSinceLastContact;

//when to call Next
- (NSDate *) getNextCallDate;

//helper function to load and store date to and from text
+ (NSDate * ) getDateFromStringMMDDYY: (NSString *) str;
+ (NSString *) getStringFromDateMMDDYY: (NSDate *) date;

//helper function to convert contact frequency - to and from text
+ (NSString *) getContactFrequencyStringFromEnum: (ContactFrequency) contactFrequency;
+ (ContactFrequency) getContactFrequencyEnumFromString:(NSString *) contactFrequency;

//get contact frequency as days
+ (long) getContactFrequencyAsDays: (ContactFrequency) contactFrequency;

//get Array index of this contact frequency in the Array of All options
+ (long) getIndexInAllContactFrequencyOptions: (ContactFrequency) contactFrequency;

//get total contact options
+ (long) getTotalContactFrequencyOptions;

//helper function to get difference between two days
+ (long)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;

//helper function to calculate when the contact should be contacted next, based on frequency and last contact
+ (long) calculate_contact_after_ndays: (ContactFrequency) contactFrequency : (NSDate *) lastContacted;

//check if its a valid phone number
+ (BOOL) isValidPhone:(NSString*) phoneString;

//format string as a phone number
+(NSString*) formatAsPhoneNumber: (NSString*) phone;

// get days back as string
+ (NSString *) getLastContactedDaysAsString:  (long) days;


@end

