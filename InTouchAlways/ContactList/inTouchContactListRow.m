//
//  inTouchContactListRowProperties.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/27/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchContactListRow.h"

@implementation inTouchContactListRow

- (id) init
{
    self = [super init];
    if (self)
    {
        self.indentLevel = 0;
        self.isRowExpanded = NO;
    }
    return self;
}

@end
