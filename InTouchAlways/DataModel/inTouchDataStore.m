//
//  inTouchDataStore.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 5/4/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchDataStore.h"
#import <sqlite3.h>


/* private : datbase object and path */
@interface inTouchDataStore ()
@property (readonly) NSString *databasePath;
@property (readonly) sqlite3  *inTouchDB;

-(int) upgradeDataBaseSchema;
@end

@implementation inTouchDataStore
- ( id ) init
{
    self = [super init];
    if (self)
    {
        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        
        // Build the path to the database file
        _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:  @"inTouch.R100.db"]];
        NSFileManager *filemgr = [NSFileManager defaultManager];
        
        const char *dbpath = [_databasePath UTF8String];
        
        if ([filemgr fileExistsAtPath: _databasePath ] == NO)
        {
            NSLog(@"Creating new SQLLITE3 inTouch Database %@", _databasePath);
            
            if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
            {
                
                char *errMsg = NULL;
                const char *sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, "\
                " FIRSTNAME TEXT, LASTNAME TEXT, " \
                "  LASTCONTACTED INTEGER, CONTACTFREQUENCY INTEGER, NOTES TEXT, " \
                "  PHONENUMBER TEXT )";
                
                if (sqlite3_exec(_inTouchDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to Create CONTACTS table  in new inTouch Database %@. Error = [%s] SQL = [%s]", _databasePath,errMsg,sql_stmt);
                    sqlite3_free(errMsg);
                    sqlite3_close(_inTouchDB);
                    return nil;
                    
                }
                sqlite3_free(errMsg);
                sqlite3_close(_inTouchDB);
            }
            else
            {
                NSLog(@"Failed to Open inTouch Database %@", _databasePath);
                return nil;
            }
        }
        else
        {
            NSLog(@"Using existing SQLLITE3 inTouch Database %@", _databasePath);
        }
        
        //upgrade the data base scheme to add additional columns - if these columns already exist - we should exit and do nothing
        //Check if additional columns exist
        [self upgradeDataBaseSchema];
        
        
        // recreate the view even if we are using existing database
        if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
        {
            
            /*****
             typedef enum {
             CONTACT_UNKNOWN = -1,
             CONTACT_DAILY = 1,
             CONTACT_WEEKLY = 7,
             CONTACT_MONTHLY = 30,
             CONTACT_THREEMONTHS = 90,
             CONTACT_SIXMONTHS = 180,
             CONTACT_YEARLY = 365,
             } ContactFrequency;
             ******/
            
            //create a view to get all contacts in proper sorted order
            char *errMsg = NULL;
            const char *sql_stmt =  " DROP VIEW IF  EXISTS CONTACTS_V  ";
            if (sqlite3_exec(_inTouchDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to DROP CONTACTS view  in new inTouch Database %@. Error = [%s] SQL = [%s]", _databasePath,errMsg,sql_stmt);
                sqlite3_free(errMsg);
                sqlite3_close(_inTouchDB);
                return nil;
            }
            sqlite3_free(errMsg);
            
            
            //create a view to get all contacts in proper sorted order
            sql_stmt =  " CREATE VIEW IF NOT EXISTS CONTACTS_V AS "
            " SELECT FIRSTNAME, LASTNAME, "                 \
            "   LASTCONTACTED,    "    \
            "   CONTACTFREQUENCY , NOTES, PHONENUMBER, CELLPHONE,HOMEPHONE,EMAIL,WORKPHONE, "    \
            "   CASE "  \
            "       WHEN DAYS_SINCE_CONTACT <= 0 THEN CONTACTFREQUENCY_INDAYS       "    \
            "       WHEN DAYS_SINCE_CONTACT >= CONTACTFREQUENCY_INDAYS THEN 0       "    \
            "       ELSE CONTACTFREQUENCY_INDAYS - DAYS_SINCE_CONTACT               "    \
            "   END AS CONTACT_AFTER_NDAYS ,                                        "    \
            "   CONTACTFREQUENCY_INDAYS,DAYS_SINCE_CONTACT  "                       \
            " FROM ( "                                      \
            "   SELECT FIRSTNAME, LASTNAME, "               \
            "   LASTCONTACTED,     "   \
            "   CONTACTFREQUENCY , NOTES, PHONENUMBER,  CELLPHONE,HOMEPHONE,EMAIL,WORKPHONE,  "   \
            "   CAST( JULIANDAY('now') - JULIANDAY( datetime(LASTCONTACTED,'unixepoch') ) AS INT ) AS DAYS_SINCE_CONTACT, " \
            "   CASE                                       "   \
            "       WHEN CONTACTFREQUENCY <= 0 THEN  180   "   \
            "       ELSE                  CONTACTFREQUENCY "   \
            "   END  AS CONTACTFREQUENCY_INDAYS         "   \
            "   FROM CONTACTS "                             \
            " ) ";
            
            if (sqlite3_exec(_inTouchDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to Create CONTACTS view  in new inTouch Database %@. Error = [%s] SQL = [%s]", _databasePath,errMsg,sql_stmt);
                sqlite3_free(errMsg);
                sqlite3_close(_inTouchDB);
                return nil;
            }
            sqlite3_free(errMsg);
            sqlite3_close(_inTouchDB);
        }
        else
        {
            NSLog(@"Failed to Open CONTACTS inTouch Database %@.", _databasePath);
            return nil;
        }
        
    }
    
    return self;
}

-(int) upgradeDataBaseSchema
{
    int rc = 0;
    
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
    {
        //See if we have columns - email, cellPhone ( for SMS)
        const char *columnsToAdd[] = {"CELLPHONE TEXT", "HOMEPHONE TEXT", "EMAIL TEXT" ,"WORKPHONE TEXT"};
        
        for ( int i = 0 ; i < sizeof(columnsToAdd) / sizeof(char *); ++i )
        {
            char *errMsg = NULL;
            const char *column = columnsToAdd[i];
            NSString *sql_stmt = [NSString stringWithFormat: @"ALTER TABLE CONTACTS ADD COLUMN %s", column];
                              
            if (sqlite3_exec(_inTouchDB, [sql_stmt UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //Do NOT give any error, just in case columns are not added and they do not exist, view creation will fail
                NSLog(@"Could Not Upgrade CONTACTS inTouch Database %@. To Add Column %s. Error = [%s] ", _databasePath,column,errMsg);
                
            }
            else
            {
                NSLog(@"Upgraded CONTACTS inTouch Database %@. Added Column %s  ", _databasePath,column);
            }
            sqlite3_free(errMsg);
        }
        
    }
    else
    {
        NSLog(@"Failed to Open CONTACTS inTouch Database for Upgrade%@.", _databasePath);
        rc = -1;
    }
    sqlite3_close(_inTouchDB);

    return rc;
}

- (int) createOrUpdateContact: (inTouchContactData *) Contact
{
    int rc = 0;
    const char *dbpath = [_databasePath UTF8String];
    
    //first find and see if the contact exists
    inTouchContactData * dbContact = [self findContact: Contact.firstName : Contact.lastName ];
    
    if (dbContact)
    {
        // update existing
        char *errMsg = NULL;
        
        NSString *querySQL = [NSString stringWithFormat: @" UPDATE CONTACTS " \
                              " SET " \
                              " LASTCONTACTED = %ld  " \
                              " , CONTACTFREQUENCY = %u " \
                              " , NOTES = \"%@\"  " \
                              " , PHONENUMBER = \"%@\"  " \
                              " , CELLPHONE = \"%@\"  " \
                              " , HOMEPHONE = \"%@\"  " \
                              " , EMAIL = \"%@\"  " \
                              " , WORKPHONE = \"%@\"  " \
                              " WHERE FIRSTNAME=\"%@\" AND LASTNAME=\"%@\" ",
                              (time_t) [Contact.lastContacted timeIntervalSince1970],
                              Contact.contactFrequency,
                              Contact.notes,
                              Contact.phoneNumber,
                              Contact.cellPhoneNumber,
                              Contact.homePhoneNumber,
                              Contact.email,
                              Contact.workPhoneNumber,
                              Contact.firstName,Contact.lastName];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
        {
            if (sqlite3_exec(_inTouchDB, query_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to Update CONTACTS in new inTouch Database %@. Error = [%s]. SQL = [%s]", _databasePath,errMsg,query_stmt);
                rc = -1;
            }
            else
                rc = sqlite3_changes(_inTouchDB);
        }
        else
        {
            NSLog(@"Failed to Open inTouch Database %@ SQL=[%s]", _databasePath,query_stmt);
            rc = -2;
        }
        
        sqlite3_free(errMsg);
        sqlite3_close(_inTouchDB);
        
    }
    else
    {
        // create new contact
        
        //make sure we do not save contacts with empty first names
        //remove white spaces
        NSArray* words = [Contact.firstName componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
        NSString* noSpaceFirstName = [words componentsJoinedByString:@""];
        if ( [noSpaceFirstName length] != 0 )
        {
            char *errMsg = NULL;
            
            NSString *querySQL = [NSString stringWithFormat: @" INSERT INTO CONTACTS  ( " \
                                  " FIRSTNAME , LASTNAME , " \
                                  " LASTCONTACTED , CONTACTFREQUENCY , NOTES, PHONENUMBER, CELLPHONE, HOMEPHONE, EMAIL ,WORKPHONE ) " \
                                  " VALUES  ( " \
                                  " \"%@\", \"%@\", %ld , %u , \"%@\" , \"%@\" , \"%@\" , \"%@\" , \"%@\" , \"%@\"  " \
                                  " ) " ,
                                  Contact.firstName,Contact.lastName,
                                  (time_t) [Contact.lastContacted timeIntervalSince1970],
                                  Contact.contactFrequency,
                                  Contact.notes,
                                  Contact.phoneNumber,
                                  Contact.cellPhoneNumber,
                                  Contact.homePhoneNumber,
                                  Contact.email,
                                  Contact.workPhoneNumber];
            
            const char *query_stmt = [querySQL UTF8String];
            
            if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
            {
                if (sqlite3_exec(_inTouchDB, query_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to INSERT CONTACTS in new inTouch Database %@. Error = [%s]. SQL = [%s]", _databasePath,errMsg,query_stmt);
                    rc = -3;
                }
                else
                    rc = sqlite3_changes(_inTouchDB);
            }
            else
            {
                NSLog(@"Failed to Open inTouch Database %@ SQL=[%s]", _databasePath,query_stmt);
                rc = -4;
            }
            
            
            sqlite3_free(errMsg);
            sqlite3_close(_inTouchDB);
        }
        else
        {
            //first name is empty for this new contact
            rc = -5;
        }
    }
    
    return rc;
}

- (int) removeContact: (inTouchContactData *) Contact
{
    const char *dbpath = [_databasePath UTF8String];
    int rc = 0;
    
    
    if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
    {
        char *errMsg = NULL;
        
        NSString *querySQL = [NSString stringWithFormat: @" DELETE FROM CONTACTS " \
                              " WHERE FIRSTNAME=\"%@\" AND LASTNAME=\"%@\"",
                              Contact.firstName,Contact.lastName];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_exec(_inTouchDB, query_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"Failed to Delete CONTACTS in new inTouch Database %@. Error = [%s]. SQL = [%s]", _databasePath,errMsg,query_stmt);
            rc = -1;
        }
        else
            rc = sqlite3_changes(_inTouchDB);
        
        sqlite3_free(errMsg);
        sqlite3_close(_inTouchDB);
    }
    else
    {
        NSLog(@"Failed to Open inTouch Database %@", _databasePath);
        rc = -2;
    }
    
    return rc;
}


- (inTouchContactData *) findContact: ( NSString *) firstName : (NSString *) lastName
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    inTouchContactData *contact = nil;
    
    if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @" SELECT " \
                              " FIRSTNAME,LASTNAME,LASTCONTACTED,CONTACTFREQUENCY,NOTES,PHONENUMBER,CONTACT_AFTER_NDAYS, " \
                              " CELLPHONE,HOMEPHONE,EMAIL,WORKPHONE " \
                              " FROM contacts_v WHERE FIRSTNAME=\"%@\" AND LASTNAME=\"%@\"",
                              firstName,lastName];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_inTouchDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                contact = [[inTouchContactData alloc] init];
                
                const char *temp = (const char *) sqlite3_column_text(statement, 0);
                contact.firstName = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
              
                temp = (const char *) sqlite3_column_text(statement, 1);
                contact.lastName = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                contact.lastContacted = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_int(statement, 2)];
                contact.contactFrequency = sqlite3_column_int(statement, 3);
                
                temp = (const char *) sqlite3_column_text(statement, 4);
                contact.notes = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
    
                temp = (const char *) sqlite3_column_text(statement, 5);
                contact.phoneNumber = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                contact.contact_after_ndays = sqlite3_column_int(statement, 6);
                
                temp = (const char *) sqlite3_column_text(statement, 7);
                contact.cellPhoneNumber = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                temp = (const char *) sqlite3_column_text(statement, 8);
                contact.homePhoneNumber = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                temp = (const char *) sqlite3_column_text(statement, 9);
                contact.email = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];

                temp = (const char *) sqlite3_column_text(statement, 10);
                contact.workPhoneNumber = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];


            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to Prepare Statement inTouch Database %@ SQL=[%s]", _databasePath,query_stmt);
            
        }
        sqlite3_close(_inTouchDB);
    }
    else
    {
        NSLog(@"Failed to Open inTouch Database %@", _databasePath);
    }
    
    return contact;
}


- (NSMutableArray *) findAllContactsStartingWith:(NSString *)firstName :(NSString *)lastName
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    inTouchContactData *contact = nil;
    NSMutableArray *arrayOfContacts;
    
    arrayOfContacts = [[NSMutableArray alloc] init];
    
    //TODO Change order by based on who should be contacted next;
    if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @" SELECT " \
                              "FIRSTNAME,LASTNAME,LASTCONTACTED,CONTACTFREQUENCY,NOTES,PHONENUMBER,CONTACT_AFTER_NDAYS, " \
                              " CELLPHONE,HOMEPHONE,EMAIL,WORKPHONE " \
                              " FROM contacts_v WHERE FIRSTNAME LIKE \"%@%%\" AND LASTNAME LIKE \"%@%%\"" \
                              " ORDER BY "  \
                              " CASE  "  \
                              "     WHEN CONTACT_AFTER_NDAYS <=0 THEN 1 " \
                              "     WHEN CONTACT_AFTER_NDAYS <=7 THEN 2 "
                              "     ELSE    3 " \
                              " END , " \
                              " FIRSTNAME, LASTNAME ",
                              firstName,lastName];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_inTouchDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                contact = [[inTouchContactData alloc] init];
                
                const char *temp = (const char *) sqlite3_column_text(statement, 0);
                contact.firstName = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                temp = (const char *) sqlite3_column_text(statement, 1);
                contact.lastName = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                contact.lastContacted = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_int(statement, 2)];
                contact.contactFrequency = sqlite3_column_int(statement, 3);
                
                temp = (const char *) sqlite3_column_text(statement, 4);
                contact.notes = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                temp = (const char *) sqlite3_column_text(statement, 5);
                contact.phoneNumber = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                contact.contact_after_ndays = sqlite3_column_int(statement, 6);
                
                temp = (const char *) sqlite3_column_text(statement, 7);
                contact.cellPhoneNumber = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                temp = (const char *) sqlite3_column_text(statement, 8);
                contact.homePhoneNumber = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                temp = (const char *) sqlite3_column_text(statement, 9);
                contact.email = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                temp = (const char *) sqlite3_column_text(statement, 10);
                contact.workPhoneNumber = temp == NULL ? @"" : [[NSString alloc] initWithUTF8String:temp];
                
                [arrayOfContacts addObject:contact];
                
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to Prepare Statement inTouch Database %@ SQL=[%s]", _databasePath,query_stmt);
            
        }
        sqlite3_close(_inTouchDB);
    }
    else
    {
        NSLog(@"Failed to Open inTouch Database %@", _databasePath);
    }
    
    return arrayOfContacts;
}

-(int) getTotalContacts
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    int count =0;
    
    if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @" SELECT COUNT(*) FROM contacts_v " ];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_inTouchDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                count = sqlite3_column_int(statement, 0);
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to Prepare Statement inTouch Database %@ SQL=[%s]", _databasePath,query_stmt);
            
        }
        sqlite3_close(_inTouchDB);
    }
    else
    {
        NSLog(@"Failed to Open inTouch Database %@", _databasePath);
    }
    return count;
}

//find number of people who are to be called today
-(int) getTotalContactsTobeCalledToday
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    int count =0;
    
    if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @" SELECT COUNT(*) FROM contacts_v WHERE "\
                                                          " CONTACT_AFTER_NDAYS = 0 " ];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_inTouchDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                count = sqlite3_column_int(statement, 0);
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to Prepare Statement inTouch Database %@ SQL=[%s]", _databasePath,query_stmt);
            
        }
        sqlite3_close(_inTouchDB);
    }
    else
    {
        NSLog(@"Failed to Open inTouch Database %@", _databasePath);
    }
    return count;

}

//find number of people who are to be called tomorrow
-(int) getTotalContactsTobeCalledTodayAndTomorrow
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    int count =0;
    
    if (sqlite3_open(dbpath, &_inTouchDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @" SELECT COUNT(*) FROM contacts_v WHERE "\
                              " (CONTACT_AFTER_NDAYS = 0 or CONTACT_AFTER_NDAYS = 1 ) " ];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_inTouchDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                count = sqlite3_column_int(statement, 0);
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to Prepare Statement inTouch Database %@ SQL=[%s]", _databasePath,query_stmt);
            
        }
        sqlite3_close(_inTouchDB);
    }
    else
    {
        NSLog(@"Failed to Open inTouch Database %@", _databasePath);
    }
    return count;    
}




@end
