//
//  inTouchContactDataExtended.m
//  InTouchAlways
//
//  Created by Jitan Sahni on 6/17/14.
//  Copyright (c) 2014 Yoti World. All rights reserved.
//

#import "inTouchContactDataExtended.h"

@implementation inTouchContactDataExtended

@end


@implementation InTouchContactChildItemDetails

- ( id ) init
{
    self = [super init];
    if (self)
    {
        self.isThisOnlyChilItemOfThisType = NO;
        self.isPrimaryContact = NO;
        self.childItemType = ChildItemIsForCalls;
    }
    return self;
}


@end
