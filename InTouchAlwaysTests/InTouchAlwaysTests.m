//
//  InTouchAlwaysTests.m
//  InTouchAlwaysTests
//
//  Created by Jitan Sahni on 5/3/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "inTouchDataStore.h"

@interface InTouchAlwaysTests : XCTestCase
@property NSString *databasePath;
@end

@implementation InTouchAlwaysTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    //Remove any existing databases and create a brand new one
    NSString *docsDir;
    NSArray  *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:     @"inTouch.R100.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
    }
    else
    {
        //just rename it so we do not delete what already exists
        [filemgr moveItemAtPath:_databasePath toPath: [_databasePath stringByAppendingString:@".testNewDbCreation.tmp"] error:NULL];
    }
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    //move back the original database
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    [filemgr removeItemAtPath:_databasePath error:NULL];
    [filemgr moveItemAtPath:[_databasePath stringByAppendingString:@".testNewDbCreation.tmp"] toPath: _databasePath error:NULL];
}


- (void) testDatatbaseOperations
{
    //create a fresh instance of Data Store
    inTouchDataStore * dataStore = [[inTouchDataStore alloc] init];
    inTouchContactData *contact = [[inTouchContactData alloc] init];
    
    contact.firstName = @"Jitan";
    contact.lastName = @"Sahni";
    contact.lastContacted = [inTouchContactData getDateFromStringMMDDYY:@"04/04/14"];
    contact.contactFrequency = CONTACT_SIXMONTHS;
    contact.notes = @"NOTES";
    contact.phoneNumber = @"1-732-80000";
    contact.cellPhoneNumber = @"1-732-611-9999";
    contact.homePhoneNumber = @"1-732-726-1111";
    contact.email = @"abce.efg@yahoo.com";
    contact.workPhoneNumber = @"212-678-1111";
    
    while (1)
    {
    
        int rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        //find it
        {
            inTouchContactData *dbContact = [dataStore findContact:@"Jitan" :@"Sahni"];
            
            //see if what we got back is same as original
            if (dbContact == nil)
            {
                XCTFail(@"testNewDbCreation failed to find contact");
                break;
            }
        }
        
        //do one more time to make sure updates are working fine
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to update contact");
            break;
        }
        
        //find it
        inTouchContactData *dbContact = [dataStore findContact:@"Jitan" :@"Sahni"];
        
        //see if what we got back is same as original
        if (dbContact == nil)
        {
            XCTFail(@"testNewDbCreation failed to find contact");
            break;
        }
        
        if ( ![contact.firstName isEqualToString:dbContact.firstName])
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");
        
        if ( ![contact.lastName isEqualToString:dbContact.lastName])
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");
    
        if ( [inTouchContactData daysBetween:contact.lastContacted and:dbContact.lastContacted ] != 0)
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");

        if ( contact.contactFrequency != dbContact.contactFrequency)
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");

        if ( ![contact.notes isEqualToString:dbContact.notes])
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");
        
        if ( ![contact.phoneNumber isEqualToString:dbContact.phoneNumber])
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");
        
        if ( ![contact.homePhoneNumber isEqualToString:dbContact.homePhoneNumber])
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");
        
        if ( ![contact.cellPhoneNumber isEqualToString:dbContact.cellPhoneNumber])
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");
        
        if ( ![contact.email isEqualToString:dbContact.email])
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");

        if ( ![contact.workPhoneNumber isEqualToString:dbContact.workPhoneNumber])
            XCTFail(@"testNewDbCreation failed to find contact. found contact does not match original");

        //remove
        rc = [dataStore removeContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to remove contact");
            break;
        }
        
        dbContact = [dataStore findContact:@"Jitan" :@"Sahni"];
        if (dbContact != nil)
        {
            XCTFail(@"testNewDbCreation failed to find contact");
            break;
        }
        
        //create and find a bunch of contacts
        contact.firstName = @"Jitan";
        contact.lastName = @"Sahni";
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        contact.firstName = @"Jitan2";
        contact.lastName = @"Sahni2";
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        contact.firstName = @"Jitan3";
        contact.lastName = @"Sahni3";
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        NSArray  *listOfContacts = [dataStore findAllContactsStartingWith:@"Jitan" :@""];
        //this should give us all three
        if ( [listOfContacts count] != 3)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        listOfContacts = [dataStore findAllContactsStartingWith:@"" :@""];
        //this should give us all three
        if ( [listOfContacts count] != 3)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        listOfContacts = [dataStore findAllContactsStartingWith:@"J" :@"S"];
        //this should give us all three
        if ( [listOfContacts count] != 3)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }

        
        listOfContacts = [dataStore findAllContactsStartingWith:@"Jitan" :@"Sharma"];
        //this should give us none
        if ( [listOfContacts count] != 0)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
 
        //test get total contacts
        int count = [dataStore getTotalContacts];
        if (count != 3)
        {
            XCTFail(@"testNewDbCreation failed getTotalContacts");
            break;
        }
        
        //remove something and count again
        dbContact = [dataStore findContact:@"Jitan2" :@"Sahni2"];
        if (dbContact == nil)
        {
            XCTFail(@"testNewDbCreation failed to find contact");
            break;
        }
        
        //remove
        rc = [dataStore removeContact:dbContact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to remove contact");
            break;
        }

        count = [dataStore getTotalContacts];
        if (count != 2)
        {
            XCTFail(@"testNewDbCreation failed getTotalContacts");
            break;
        }
        
        //try to save empty first name
        contact.firstName = @"";
        contact.lastName = @"Sahni3";
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != -5 )
        {
            XCTFail(@"testNewDbCreation failed to NOT add new EMPTY contact");
            break;
        }
        
        count = [dataStore getTotalContacts];
        if (count != 2)
        {
            XCTFail(@"testNewDbCreation failed NOT add new EMPTY contact");
            break;
        }
        
        
        
        
        break;
            
    }
}


- (void) testDatatbaseSortOrder
{
    //create a fresh instance of Data Store
    inTouchDataStore * dataStore = [[inTouchDataStore alloc] init];
    
    
    //the idea here is we are going to insert a bunch of contacts and see that the once
    //which need to be called first popup to the top
    
    
    
    while (1)
    {
        inTouchContactData *contact = [[inTouchContactData alloc] init];
        NSDate *now = [NSDate date];
        
        contact.firstName = @"RA";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_SIXMONTHS;
        
        int rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        contact.firstName = @"RB";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_DAILY;
        
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }

        //We inserted two contacts : one that needs to be contacted monthly and other 6 monthly
        //lets see how they look like when fetched
        NSArray  *listOfContacts = [dataStore findAllContactsStartingWith:@"R" :@""];
        //this should give us all two
        if ( [listOfContacts count] != 2)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        //first should be R2
        inTouchContactData *dbContact = listOfContacts[0];
        
        //contact after n days should be now - ( last contacted + contact frequency )
        long contact_after_ndays = [ inTouchContactData calculate_contact_after_ndays: dbContact.contactFrequency :dbContact.lastContacted ];
        

        if ( ![dbContact.firstName isEqualToString:@"RB"])
        {
            XCTFail(@"testNewDbCreation failed Sort Order - expected record RB");
            break;
        }

        if ( dbContact.contact_after_ndays != contact_after_ndays)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",contact_after_ndays,dbContact.contact_after_ndays);
            break;

        }
        
        //anything with daily frequency and called today , should show up as contact after a day
        contact.firstName = @"RA";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_DAILY;
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        
        dbContact = [dataStore findContact:@"RA" :@"lastname"];
        if (dbContact == nil)
        {
            XCTFail(@"testNewDbCreation failed to find contact");
            break;
        }
        
        contact_after_ndays = [ inTouchContactData calculate_contact_after_ndays: dbContact.contactFrequency :dbContact.lastContacted ];
        if ( dbContact.contact_after_ndays != contact_after_ndays)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",contact_after_ndays,dbContact.contact_after_ndays);
            break;
            
        }
        
        if ( dbContact.contact_after_ndays != 1)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",contact_after_ndays,dbContact.contact_after_ndays);
            break;
            
        }



        
        
        break;
        
    }
}

- (void) testDatatbaseContactFrequencyOptions
{
    //create a fresh instance of Data Store
    inTouchDataStore * dataStore = [[inTouchDataStore alloc] init];
    
    
    //make sure all contact frequency options are working fine
    
    while (1)
    {
        NSDate *now = [NSDate date];
        inTouchContactData *contact = [[inTouchContactData alloc] init];
        
        /***********************************************************************/
        contact.firstName = @"RB";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_DAILY;
        
        int rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        
        // find the contact we inserted
        NSArray  *listOfContacts = [dataStore findAllContactsStartingWith:@"RB" :@"lastname"];
        if ( [listOfContacts count] != 1)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        //first should be RB
        inTouchContactData *dbContact = listOfContacts[0];
        
        //contact after n days should be now - ( last contacted + contact frequency )
        long contact_after_ndays = [ inTouchContactData calculate_contact_after_ndays: dbContact.contactFrequency :dbContact.lastContacted ];
        
        
        if ( dbContact.contact_after_ndays != contact_after_ndays)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    contact_after_ndays,dbContact.contact_after_ndays);
            break;
        }
        
        if ( dbContact.contact_after_ndays != 1)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    1l,dbContact.contact_after_ndays);
            break;
        }
        
        /***********************************************************************/

        /***********************************************************************/
        contact.firstName = @"RB";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_WEEKLY;
        
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        
        // find the contact we inserted
        listOfContacts = [dataStore findAllContactsStartingWith:@"RB" :@"lastname"];
        if ( [listOfContacts count] != 1)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        //first should be RB
        dbContact = listOfContacts[0];
        
        //contact after n days should be now - ( last contacted + contact frequency )
        contact_after_ndays = [ inTouchContactData calculate_contact_after_ndays: dbContact.contactFrequency :dbContact.lastContacted ];
        
        
        if ( dbContact.contact_after_ndays != contact_after_ndays)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    contact_after_ndays,dbContact.contact_after_ndays);
            break;
        }
        
        if ( dbContact.contact_after_ndays != 7)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    1l,dbContact.contact_after_ndays);
            break;
        }
        
        /***********************************************************************/

        /***********************************************************************/
        contact.firstName = @"RB";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_MONTHLY;
        
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        
        // find the contact we inserted
        listOfContacts = [dataStore findAllContactsStartingWith:@"RB" :@"lastname"];
        if ( [listOfContacts count] != 1)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        //first should be RB
        dbContact = listOfContacts[0];
        
        //contact after n days should be now - ( last contacted + contact frequency )
        contact_after_ndays = [ inTouchContactData calculate_contact_after_ndays: dbContact.contactFrequency :dbContact.lastContacted ];
        
        
        if ( dbContact.contact_after_ndays != contact_after_ndays)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    contact_after_ndays,dbContact.contact_after_ndays);
            break;
        }
        
        if ( dbContact.contact_after_ndays != 30)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    1l,dbContact.contact_after_ndays);
            break;
        }
        
        /***********************************************************************/
        
        /***********************************************************************/
        contact.firstName = @"RB";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_THREEMONTHS;
        
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        
        // find the contact we inserted
        listOfContacts = [dataStore findAllContactsStartingWith:@"RB" :@"lastname"];
        if ( [listOfContacts count] != 1)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        //first should be RB
        dbContact = listOfContacts[0];
        
        //contact after n days should be now - ( last contacted + contact frequency )
        contact_after_ndays = [ inTouchContactData calculate_contact_after_ndays: dbContact.contactFrequency :dbContact.lastContacted ];
        
        
        if ( dbContact.contact_after_ndays != contact_after_ndays)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    contact_after_ndays,dbContact.contact_after_ndays);
            break;
        }
        
        if ( dbContact.contact_after_ndays != 90)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    1l,dbContact.contact_after_ndays);
            break;
        }
        
        /***********************************************************************/
        
        /***********************************************************************/
        contact.firstName = @"RB";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_SIXMONTHS;
        
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        
        // find the contact we inserted
        listOfContacts = [dataStore findAllContactsStartingWith:@"RB" :@"lastname"];
        if ( [listOfContacts count] != 1)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        //first should be RB
        dbContact = listOfContacts[0];
        
        //contact after n days should be now - ( last contacted + contact frequency )
        contact_after_ndays = [ inTouchContactData calculate_contact_after_ndays: dbContact.contactFrequency :dbContact.lastContacted ];
        
        
        if ( dbContact.contact_after_ndays != contact_after_ndays)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    contact_after_ndays,dbContact.contact_after_ndays);
            break;
        }
        
        if ( dbContact.contact_after_ndays != 180)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    1l,dbContact.contact_after_ndays);
            break;
        }
        
        /***********************************************************************/
        
        /***********************************************************************/
        contact.firstName = @"RB";
        contact.lastName = @"lastname";
        contact.lastContacted = now;
        contact.contactFrequency = CONTACT_YEARLY;
        
        rc  = [dataStore createOrUpdateContact:contact];
        if ( rc != 1 )
        {
            XCTFail(@"testNewDbCreation failed to add new contact");
            break;
        }
        
        
        // find the contact we inserted
        listOfContacts = [dataStore findAllContactsStartingWith:@"RB" :@"lastname"];
        if ( [listOfContacts count] != 1)
        {
            XCTFail(@"testNewDbCreation failed findAllContactsStartingWith");
            break;
        }
        
        //first should be RB
        dbContact = listOfContacts[0];
        
        //contact after n days should be now - ( last contacted + contact frequency )
        contact_after_ndays = [ inTouchContactData calculate_contact_after_ndays: dbContact.contactFrequency :dbContact.lastContacted ];
        
        
        if ( dbContact.contact_after_ndays != contact_after_ndays)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    contact_after_ndays,dbContact.contact_after_ndays);
            break;
        }
        
        if ( dbContact.contact_after_ndays != 365)
        {
            XCTFail(@"testNewDbCreation failed Sort Order NDays - expected %ld. got %ld",
                    1l,dbContact.contact_after_ndays);
            break;
        }
        
        /***********************************************************************/




        
        break;
        
    }
}


@end
