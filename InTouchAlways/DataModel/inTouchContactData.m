//
//  inTouchContactData.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/4/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchContactData.h"

@implementation inTouchContactData

- ( id ) init
{
    self = [super init];
    if (self)
    {
        self.contactFrequency = CONTACT_WEEKLY;
        
        NSDate *now = [NSDate date];
        self.lastContacted = now;
        self.firstName = @"";
        self.lastName = @"";
        self.phoneNumber = @"";
        self.homePhoneNumber = @"";
        self.workPhoneNumber = @"";
        self.cellPhoneNumber = @"";
        self.email = @"";

    }
    return self;
}

+ (NSDate * ) getDateFromStringMMDDYY: (NSString *) str
{
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [newFormatter setDateStyle:NSDateFormatterShortStyle];
    [newFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    return [newFormatter dateFromString:str];
}

+ (NSString * ) getStringFromDateMMDDYY:(NSDate *)date
{
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [newFormatter setDateStyle:NSDateFormatterShortStyle];
    [newFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [newFormatter stringFromDate:date];
}

+ (NSString *) getContactFrequencyStringFromEnum: (ContactFrequency) contactFrequency
{
    switch (contactFrequency)
    {
        case CONTACT_DAILY          : return        @"Daily";
        case CONTACT_WEEKLY         : return        @"Weekly";
        case CONTACT_MONTHLY        : return        @"Monthly";
        case CONTACT_THREEMONTHS    : return        @"Three Months";
        case CONTACT_SIXMONTHS      : return        @"Six Months";
        case CONTACT_YEARLY         : return        @"Yearly";
        default                     : return        nil;
    }
}

+ (ContactFrequency) getContactFrequencyEnumFromString:(NSString *) contactFrequency
{
    ContactFrequency frequency = CONTACT_UNKNOWN;
    
    if ( [contactFrequency isEqualToString:@"Daily"])
        frequency = CONTACT_DAILY;
    else if ( [contactFrequency isEqualToString:@"Weekly"])
        frequency = CONTACT_WEEKLY;
    else if ( [contactFrequency isEqualToString:@"Monthly"])
        frequency = CONTACT_MONTHLY;
    else if ( [contactFrequency isEqualToString:@"Three Months"])
        frequency = CONTACT_THREEMONTHS;
    else if ( [contactFrequency isEqualToString:@"Six Months"])
        frequency = CONTACT_SIXMONTHS;
    else if ( [contactFrequency isEqualToString:@"Yearly"])
        frequency = CONTACT_YEARLY;
    
    return frequency;
}

+ (long) getContactFrequencyAsDays: (ContactFrequency) contactFrequency;
{
    return (long) contactFrequency;
}

+ (long) getTotalContactFrequencyOptions
{
    int count = sizeof(ContactFrequencyOptionsArray) / sizeof(ContactFrequencyOptionsArray[0]);
    return count;
}

+ (long) getIndexInAllContactFrequencyOptions: (ContactFrequency) contactFrequency
{
    long count = [inTouchContactData getTotalContactFrequencyOptions];
    
    for ( long  i = 0 ; i < count; ++i)
    {
        if ( ContactFrequencyOptionsArray[i] == contactFrequency)
            return i;
    }
    
    //due to some reason the contactFrequency did not show up in array !!
    //TODO - could be sign of trouble;
    return -1;
}

+ (long)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2
{
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return [components day];
}

+ (long) calculate_contact_after_ndays: (ContactFrequency) contactFrequency : (NSDate *) lastContacted
{
    
    //contact after n days should be now - ( last contacted + contact frequency )
    NSDate *now = [NSDate date];
    long contact_after_ndays = 0;
    long contact_frequency_indays = [ inTouchContactData getContactFrequencyAsDays:contactFrequency];
    long  days_since_contact = [ inTouchContactData daysBetween:lastContacted and:now];
    
    if ( days_since_contact <= 0  )
        contact_after_ndays = contact_frequency_indays;
    else if ( days_since_contact >= contact_frequency_indays)
        contact_after_ndays = 0;
    else
        contact_after_ndays = contact_frequency_indays - days_since_contact;
    
    return contact_after_ndays;
}

- (long) getDaysSinceLastContact
{
    //contact after n days should be now - ( last contacted + contact frequency )
    NSDate *now = [NSDate date];
    long  days_since_contact = [ inTouchContactData daysBetween:self.lastContacted and:now];
    
    if ( days_since_contact <= 0  )
        return 0;
    else
        return days_since_contact;
}

- (NSDate *) getNextCallDate
{
    NSDate *now = [NSDate date];
    long contact_after_ndays = [inTouchContactData calculate_contact_after_ndays:self.contactFrequency :self.lastContacted];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = contact_after_ndays;
    
    NSDate *nextDate = [calendar dateByAddingComponents:dayComponent toDate:now options:0];
    return nextDate;
}

+ (BOOL) isValidPhone:(NSString*) phoneString
{
    
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    
    NSRange inputRange = NSMakeRange(0, [phoneString length]);
    NSArray *matches = [detector matchesInString:phoneString options:0 range:inputRange];
    
    // no match at all
    if ([matches count] == 0) {
        return NO;
    }
    
    // found match but we need to check if it matched the whole string
    NSTextCheckingResult *result = (NSTextCheckingResult *)[matches objectAtIndex:0];
    
    if ([result resultType] == NSTextCheckingTypePhoneNumber && result.range.location == inputRange.location && result.range.length == inputRange.length) {
        // it matched the whole string
        return YES;
    }
    else {
        // it only matched partial string
        return NO;
    }
}

+(NSString*) formatAsPhoneNumber: (NSString*) phone
{
    static NSCharacterSet* set = nil;
    if (set == nil){
        set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    }
    
    NSString* phoneString = [[phone componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    switch (phoneString.length) {
        case 7: return [NSString stringWithFormat:@"%@-%@", [phoneString substringToIndex:3], [phoneString substringFromIndex:3]];
        case 10: return [NSString stringWithFormat:@"(%@) %@-%@", [phoneString substringToIndex:3], [phoneString substringWithRange:NSMakeRange(3, 3)],[phoneString substringFromIndex:6]];
        case 11: return [NSString stringWithFormat:@"%@ (%@) %@-%@", [phoneString substringToIndex:1], [phoneString substringWithRange:NSMakeRange(1, 3)], [phoneString substringWithRange:NSMakeRange(4, 3)], [phoneString substringFromIndex:7]];
        case 12: return [NSString stringWithFormat:@"+%@ (%@) %@-%@", [phoneString substringToIndex:2], [phoneString substringWithRange:NSMakeRange(2, 3)], [phoneString substringWithRange:NSMakeRange(5, 3)], [phoneString substringFromIndex:8]];
        default: return phone;
    }
}

// get days back as string
+ (NSString *) getLastContactedDaysAsString:  (long) days
{
    
    if ( days <= 0 )
        return @"Today";
    else if ( days == 1 )
        return @"Yesterday";
    else
        return [NSString stringWithFormat:@"%ld Days Back", days];
}

@end
