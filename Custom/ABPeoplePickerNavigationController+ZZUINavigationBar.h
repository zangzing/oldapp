//
//  ABPeoplePickerNavigationController+ZZUINavigationBar.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/1/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ZZUINavigationBar.h"
#import <objc/runtime.h>

@interface ABPeoplePickerNavigationController (ZZUINavigationBar) 

- (id)initWithCustomNavigationBar:(ZZUINavigationBar *)navigationBar;


@end
