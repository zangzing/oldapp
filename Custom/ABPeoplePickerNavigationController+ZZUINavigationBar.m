//
//  ABPeoplePickerNavigationController+ZZUINavigationBar.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/1/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ABPeoplePickerNavigationController+ZZUINavigationBar.h"

@implementation ABPeoplePickerNavigationController (ZZUINavigationBar)


- (id)initWithCustomNavigationBar:(ZZUINavigationBar *)navigationBar
{
    self = [self init];
    
    if (self)
    {        
    
        [self setValue:navigationBar forKey:@"_navigationBar"];
    }
    
    return self;
}

@end
