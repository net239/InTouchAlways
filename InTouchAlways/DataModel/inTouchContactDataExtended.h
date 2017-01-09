//
//  inTouchContactDataExtended.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/17/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchContactData.h"

//extend basic contact to store multiple phones, emails etc.  - we call them "ChildItems"
@interface inTouchContactDataExtended : inTouchContactData
@property NSMutableArray  *ChildItems;
@end


//type of sub item  - contacts have multiple phones, emails etc. this is used to identify type of cotact child item
//we also use this for sorting child items - so DO NOT change ENUM order !!
typedef enum
{
    ChildItemIsForCalls = 0,
    ChildItemIsForTexts = 1,
    ChildItemIsForEmails = 2,
} ChildItemType;


//extra details for each contact entry for multiple phones, emails, text message numbers etc
@interface InTouchContactChildItemDetails : NSObject

@property NSString *Label;
@property NSString *Value;  //phone, email, text number etc.
@property ChildItemType  childItemType;

@property BOOL isPrimaryContact;
@property int  isThisOnlyChilItemOfThisType; //is this only one phone or email or text number for this contact

@end;

