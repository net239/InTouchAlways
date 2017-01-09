//
//  inTouchContactListRowProperties.h
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/27/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "inTouchContactDataExtended.h"


@interface inTouchContactListRow : NSObject

//top level objects are at indent level 0, sub items at 1 ...
@property int indentLevel;
@property BOOL isRowExpanded;
@property inTouchContactDataExtended *contact;

//for multiple subitems under a parent, this property representschild items index
@property int  childItemIndex;


@end
