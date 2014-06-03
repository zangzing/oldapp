//
//  GroupEditViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 1/22/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "zztypes.h"
#import "ZZAPI.h"
#import "ZZSegmentedControl.h"
#import "ZZBaseViewController.h"
#import "EmailAddressViewController.h"
#import "NewPersonViewController.h"

typedef enum{
    kGroupNewMode,
    kGroupEditMode,
} ZZGroupEditMode;

@protocol GroupEditViewControllerDelegate

@required
-(void)groupEditComplete:(ZZGroup*)group changed:(BOOL)changed;
-(void)groupEditNew:(ZZGroup*)group;
-(void)groupEditDeleteGroup:(ZZGroupID)groupid;
@end


@interface GroupEditViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ABPeoplePickerNavigationControllerDelegate, UITextFieldDelegate, ZZSegmentedControlDelegate, EmailAddressViewControllerDelegate, NewPersonViewControllerDelegate> {
    
    NSObject <GroupEditViewControllerDelegate> *_delegate;

    UITableView *grouplist;
    UITextField *_groupname;
    UIView *_deleteButtonView;
    UIButton *_deleteButton;
    UIView *_saveButtonView;
    UIButton *_saveButton;
    
    ZZGroup *_group;
    NSArray *_members;
    ZZGroupEditMode _mode;   
    BOOL _allowGroupDelete;
    BOOL _renamePending;
    BOOL _changed;                  // YES if changed
    
}

@property (nonatomic, retain) IBOutlet  UITableView *grouplist;
@property (nonatomic, retain) NSObject <GroupEditViewControllerDelegate> *delegate;

-(void)setGroupEditMode:(ZZGroupEditMode)mode;
-(void)setGroup:(ZZGroup*)group;
-(void)setAllowGroupDelete:(BOOL)allowDelete;

@end
