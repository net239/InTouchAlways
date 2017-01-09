//
//  inTouchAddressBookInterface.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/16/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface inTouchAddressBookInterface : NSObject

//find all contacts mathing names starting with
//returns array of inTouchContactDataExtended
- ( NSArray *) findAllContactsStartingWith: ( NSString *) firstName : (NSString *) lastName;

@end
