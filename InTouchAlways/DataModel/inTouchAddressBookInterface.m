//
//  inTouchAddressBookInterface.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/16/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchAddressBookInterface.h"
#import "inTouchContactData.h"
#import "inTouchContactDataExtended.h"
#import <AddressBook/AddressBook.h>

@interface inTouchAddressBookInterface ()
{
    ABAddressBookRef _addressBook;
}
@end



@implementation inTouchAddressBookInterface


- ( id ) init
{
    self = [super init];
    if (self)
    {
        // Create a new address book object with data from the Address Book database
        CFErrorRef error = nil;
        _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        if (!_addressBook)
        {
            NSLog(@"Could not create ABAddressBookRef");
        }
        else if (error)
        {
            NSLog(@"Error creating ABAddressBookRef");
        }
        
        
    }
    return self;
}

-(void)dealloc {
    //cleanup code
    CFRelease(_addressBook);
}


// Check the authorization status of our application for Address Book
-(bool) checkAddressBookAccess
{
    bool granted = false;
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            granted = true;
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];
            //check again
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized )
                granted = true;
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning"
                                                            message:@"Permission was not granted for Contacts.Please Allow AddressBook access in Settings > Privacy > Contacts"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    
    return granted;
}

// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess
{
    //create semaphore, becuase the code in next blockmay not be called in main thread
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 //thread 1 , signal completion
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    //wait for some time till  the above thread is completed, just in case user has granted immediate access
    //thru the system popup
    dispatch_time_t timeUp= dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(2.5 * NSEC_PER_SEC));
    dispatch_semaphore_wait(sema, timeUp);
    
    //back to main thread
}


- ( BOOL)  MergeTwoContactsToLastContactIfForSamePerson: ( inTouchContactDataExtended *) thisContact : ( inTouchContactDataExtended *) lastContact
{
    
    //just say no if any one is null
    if ( thisContact == nil || lastContact == nil )
        return NO;
    
    //first and last name have to match
    NSComparisonResult rc = [ thisContact.firstName compare:lastContact.firstName];
    if (rc != NSOrderedSame )
        return NO;
    
    rc = [ thisContact.lastName compare:lastContact.lastName];
    if (rc != NSOrderedSame )
        return NO;

    
    //merge
    [lastContact.ChildItems addObjectsFromArray:thisContact.ChildItems];
    
    //sort
    NSArray *sortedChildItems= [lastContact.ChildItems sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                      {
                          InTouchContactChildItemDetails *ca = a;
                          InTouchContactChildItemDetails *cb = b;
                          
                          NSComparisonResult rc = NSOrderedSame;
                          if ( ca.childItemType < cb.childItemType)
                              rc = NSOrderedAscending;
                          else if ( ca.childItemType > cb.childItemType )
                              rc = NSOrderedDescending;
                          
                          if ( rc == NSOrderedSame)
                          {
                              rc = [ca.Label compare:cb.Label];
                              if ( rc == NSOrderedSame)
                              {
                                  rc = [ca.Value compare:cb.Value];
                              }
                          }
                          
                          return rc;
                      }];
    
    
    NSMutableArray *uniqueChildItems = [[NSMutableArray alloc] init];
    InTouchContactChildItemDetails  *thisChildItem= nil;
    InTouchContactChildItemDetails  *lastChildItem = nil;
    
    for (int i = 0 ; i < [ sortedChildItems count]; ++i)
    {
        thisChildItem = [ sortedChildItems objectAtIndex:i];
        
        if (lastChildItem != nil)
        {
            rc = [ thisChildItem.Label compare:lastChildItem.Label];
            if (rc == NSOrderedSame )
            {
            
                rc = [ thisChildItem.Value compare:lastChildItem.Value];
                if (rc == NSOrderedSame )
                {
                    rc = NSOrderedSame;
                    if ( thisChildItem.childItemType < lastChildItem.childItemType)
                        rc = NSOrderedAscending;
                    else if ( thisChildItem.childItemType > lastChildItem.childItemType )
                        rc = NSOrderedDescending;
                    
                    if (rc != NSOrderedSame )
                    {
                        [uniqueChildItems addObject:thisChildItem];
                    }
                }
            } 
            else
            {
                [uniqueChildItems addObject:thisChildItem];
            }
        }
        else
        {
            [uniqueChildItems addObject:thisChildItem];
        }
        
        lastChildItem = thisChildItem;
    }
    
    
    
    //go thru items again, as we need to mark the primary contacts and other flags again - since we merged
    lastChildItem = nil;
    for (int i = 0 ; i < [ uniqueChildItems count]; ++i)
    {
        thisChildItem = [ uniqueChildItems objectAtIndex:i];
        
        if ( lastChildItem != nil)
        {
            if ( thisChildItem.childItemType == lastChildItem.childItemType)
            {
                //same type as last item
                //since we already made first as primary - make all these none primary
                //since we have atleast 2 it can;t be only child in the group
                lastChildItem.isThisOnlyChilItemOfThisType = NO;
                thisChildItem.isThisOnlyChilItemOfThisType = NO;
                thisChildItem.isPrimaryContact = NO;
            }
            else
            {
                //new type of child item grouping has started
                thisChildItem.isPrimaryContact = YES;
                thisChildItem.isThisOnlyChilItemOfThisType = YES;
            }
        }
        else
        {
            //no last Item - this is the first - mark this primary and only in group
            thisChildItem.isPrimaryContact = YES;
            thisChildItem.isThisOnlyChilItemOfThisType = YES;
        }
        
        
        lastChildItem = thisChildItem;


    }
    
    lastContact.ChildItems = uniqueChildItems;
    
    return YES;
}

//find all contacts matching names starting with
- ( NSArray *) findAllContactsStartingWith: ( NSString *) firstName : (NSString *) lastName
{
    
    //get matching phone book entries
    if ( ! [self checkAddressBookAccess] )
        return nil;
    
    NSMutableArray *arrayOfContacts;
    arrayOfContacts = [[NSMutableArray alloc] init];
    
    int count = 0;
    inTouchContactDataExtended *contact = nil;
    
    CFTypeRef ac_typeref = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    NSArray *allContacts = (__bridge_transfer NSArray *)ac_typeref;
    
    for (id record in allContacts)
    {
        ABRecordRef person = (__bridge ABRecordRef)record;
        
        CFTypeRef fn_typeref = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef ln_typeref = ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        NSString *firstNameInAddrBook = (__bridge_transfer NSString *)(fn_typeref);
        NSString *lastNameInAddrBook = (__bridge_transfer NSString *)(ln_typeref);
        
        
        if (firstName == nil)
            firstName = @"";
        
        if (lastName == nil)
            lastName = @"";
        
        if (firstNameInAddrBook == nil)
            firstNameInAddrBook = @"";
        
        if (lastNameInAddrBook == nil)
            lastNameInAddrBook = @"";
        
        //remove white spaces
        firstNameInAddrBook = [firstNameInAddrBook stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        lastNameInAddrBook = [lastNameInAddrBook stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        firstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        lastName = [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        BOOL match = NO;
        
        //if both first name and last name are blank - return everything
        if ( [firstName length] == 0 && [lastName length] == 0)
        {
            if ( [firstNameInAddrBook length] != 0 || [lastNameInAddrBook length] != 0)
            {
                match = YES;
            }
        }
        else if ( [firstName length ] == 0 && [lastName length] > 0 )
        {
            if ( [lastNameInAddrBook rangeOfString:lastName options:NSCaseInsensitiveSearch].location == 0 )
            {
                //starts with
                match = YES;
            }
        }
        else if ( [firstName length ] > 0 && [lastName length] == 0 )
        {
            if ( [firstNameInAddrBook rangeOfString:firstName options:NSCaseInsensitiveSearch].location == 0 )
            {
                //starts with
                match = YES;
            }
        }
        else
        {
            if ( [lastNameInAddrBook rangeOfString:lastName options:NSCaseInsensitiveSearch].location == 0 )
            {
                //starts with
                if ( [firstNameInAddrBook rangeOfString:firstName options:NSCaseInsensitiveSearch].location == 0 )
                {
                    //starts with
                    match = YES;
                }
            }

            
        }
        
        if ( match)
        {
                //we have some thing matching closely
                ++count;
                
                contact = [[inTouchContactDataExtended alloc] init];
                
                contact.firstName = [firstNameInAddrBook stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                contact.lastName = [lastNameInAddrBook stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
            
            
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,kABPersonPhoneProperty);
                ABMultiValueRef Emails = ABRecordCopyValue(person,kABPersonEmailProperty);
            
           
                //allocate array to store emails, phones etc.
                contact.ChildItems = [[NSMutableArray alloc] init];

            
                {
                
                    //load phone numbers
                    NSString* phone = nil;
                    NSString* label = nil;
                    
                    BOOL MarkedOneAsPrimary = NO;
                    int countAdded = 0;
                
                    long countValues = ABMultiValueGetCount(phoneNumbers) ;
                    for ( int i = 0; i < countValues; ++i)
                    {
                        phone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                        label = (__bridge_transfer NSString*) ABMultiValueCopyLabelAtIndex(phoneNumbers,i);
                        
                        if (phone == nil)
                            phone = @"";
                        
                        if(label == nil)
                            label = @"";
                        
                        BOOL found = NO;
                        NSRange  range;

                        //skips fax numbers and pagers
                        range = [ label rangeOfString:(NSString*)kABPersonPhoneHomeFAXLabel options:NSCaseInsensitiveSearch];
                        if ( range.location != NSNotFound)
                            found = YES;
                        if ( found)
                            continue;
                        
                        range = [ label rangeOfString:(NSString*)kABPersonPhoneWorkFAXLabel options:NSCaseInsensitiveSearch];
                        if ( range.location != NSNotFound)
                            found = YES;
                        if ( found)
                            continue;

                        range = [ label rangeOfString:(NSString*)kABPersonPhoneOtherFAXLabel options:NSCaseInsensitiveSearch];
                        if ( range.location != NSNotFound)
                            found = YES;
                        if ( found)
                            continue;

                    
                        //remove crazy things around labels
                        static NSCharacterSet* set = nil;
                        if (set == nil){
                            set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                        }
                        
                        NSString* label_cleaned = [[label componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
                        
                        InTouchContactChildItemDetails  *childItem = [[InTouchContactChildItemDetails alloc] init];
                        childItem.Label = label_cleaned;
                        childItem.Value = phone;
                        childItem.childItemType = ChildItemIsForCalls;
                        
                        //make first item as Primary
                        if ( MarkedOneAsPrimary)
                            childItem.isPrimaryContact = NO;
                        else
                        {
                            childItem.isPrimaryContact = YES;
                            MarkedOneAsPrimary = YES;
                        }
                            
                        [contact.ChildItems addObject:childItem] ;
                        ++countAdded;
                    }
                    
                    if ( countAdded == 1)
                    {
                        //we add only one item of this type - get the last item added to this array
                        NSUInteger n = [contact.ChildItems count];
                        InTouchContactChildItemDetails  *childItemDetails = [ contact.ChildItems objectAtIndex: (n - 1) ];
                        childItemDetails.isThisOnlyChilItemOfThisType = YES;
                    }
                        
            
                }
            
                {
                    
                    //load text phone numbers
                    NSString* phone = nil;
                    NSString* label = nil;
                    
                    BOOL MarkedOneAsPrimary = NO;
                    int countAdded = 0;
                    
                    long countValues = ABMultiValueGetCount(phoneNumbers) ;
                    for ( int i = 0; i < countValues; ++i)
                    {
                        phone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                        label = (__bridge_transfer NSString*) ABMultiValueCopyLabelAtIndex(phoneNumbers,i);
                        
                        if (phone == nil)
                            phone = @"";
                        
                        if(label == nil)
                            label = @"";
                        
                        BOOL found = NO;
                        NSRange  range;
                        
                        //lets see if this is good for texting
                        found = NO;
                        range = [ label rangeOfString:(NSString*)kABPersonPhoneMobileLabel options:NSCaseInsensitiveSearch];
                        
                        if ( range.location != NSNotFound)
                            found = YES;
                        
                        if ( !found)
                        {
                            range = [ label rangeOfString:(NSString*)kABPersonPhoneIPhoneLabel options:NSCaseInsensitiveSearch];
                            if ( range.location != NSNotFound)
                                found = YES;
                        }
                        
                        if ( !found)
                            continue;
                        
                        
                        //remove crazy things around labels
                        static NSCharacterSet* set = nil;
                        if (set == nil){
                            set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                        }
                        
                        NSString* label_cleaned = [[label componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
                        
                        InTouchContactChildItemDetails  *childItem = [[InTouchContactChildItemDetails alloc] init];
                        childItem.Label = label_cleaned;
                        childItem.Value = phone;
                        childItem.childItemType = ChildItemIsForTexts;
                        
                        if ( MarkedOneAsPrimary)
                            childItem.isPrimaryContact = NO;
                        else
                        {
                            childItem.isPrimaryContact = YES;
                            MarkedOneAsPrimary = YES;
                        }
                        
                        [contact.ChildItems addObject:childItem] ;
                        ++countAdded;
                    }
                    
                    if ( countAdded == 1)
                    {
                        //we add only one item of this type - get the last item added to this array
                        NSUInteger n = [contact.ChildItems count];
                        InTouchContactChildItemDetails  *childItemDetails = [ contact.ChildItems objectAtIndex: (n - 1) ];
                        childItemDetails.isThisOnlyChilItemOfThisType = YES;
                    }

                    
                }

            
                {
                    //load emails
                    
                    NSString* email = nil;
                    NSString* email_label = nil;
                    
                    BOOL MarkedOneAsPrimary = NO;
                    int countAdded = 0;
                
                    long countValues = ABMultiValueGetCount(Emails) ;
                    
                    for ( int i = 0; i < countValues; ++i)
                    {
                        email = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(Emails, i);
                        email_label= (__bridge_transfer NSString*) ABMultiValueCopyLabelAtIndex(Emails,i);
                        
                        if (email == nil)
                            email = @"";
                        
                        if(email_label == nil)
                            email_label = @"";
                        
                        
                        //remove crazy things around labels
                        static NSCharacterSet* set = nil;
                        if (set == nil){
                            set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                        }
                        
                        NSString* email_label_cleaned = [[email_label componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
                        
                        InTouchContactChildItemDetails  *childItem = [[InTouchContactChildItemDetails alloc] init];
                        childItem.Label = email_label_cleaned;
                        childItem.Value = email;
                        childItem.childItemType = ChildItemIsForEmails;
                        
                        if ( MarkedOneAsPrimary)
                            childItem.isPrimaryContact = NO;
                        else
                        {
                            childItem.isPrimaryContact = YES;
                            MarkedOneAsPrimary = YES;
                        }
                        
                        
                        [contact.ChildItems addObject:childItem] ;
                        ++countAdded;

                    }
                    
                    if ( countAdded == 1)
                    {
                        //we add only one item of this type - get the last item added to this array
                        NSUInteger n = [contact.ChildItems count];
                        InTouchContactChildItemDetails  *childItemDetails = [ contact.ChildItems objectAtIndex: (n - 1) ];
                        childItemDetails.isThisOnlyChilItemOfThisType = YES;
                    }

                
                }
            
                CFRelease(Emails);
                CFRelease(phoneNumbers);
                [arrayOfContacts addObject:contact];
        }
        
    }
    
    
    NSArray *sortedContacts = nil;
    
    
    sortedContacts = [arrayOfContacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                   {
                       inTouchContactData *ca = a;
                       inTouchContactData *cb = b;
                       
                       NSComparisonResult rc = [ca.firstName compare:cb.firstName];
                       
                       if ( rc == NSOrderedSame)
                       {
                           rc = [ca.lastName compare:cb.lastName];
                       }
                       
                       return rc;
                   }];
    
 
    //now lets iterate thru array and drop out any contacts which are not unique
    NSMutableArray *uniqueContacts = [[NSMutableArray alloc] init];
    
    inTouchContactDataExtended *thisContact = nil;
    inTouchContactDataExtended *lastContact = nil;
    for (int i = 0 ; i < [sortedContacts count] ; ++i)
    {
        //get the object at this location
        thisContact = [sortedContacts objectAtIndex:i];
        
        //see if this is same last last one
        bool isSameAsLastContactAndHenceMergedWithLast = NO;
        if ( lastContact != nil)
        {
            isSameAsLastContactAndHenceMergedWithLast =   [self MergeTwoContactsToLastContactIfForSamePerson: thisContact : lastContact];
        }
   
        if ( !isSameAsLastContactAndHenceMergedWithLast)
            [uniqueContacts addObject:thisContact];
        
        lastContact = thisContact;
    }

    
    return uniqueContacts;
}



@end
