//
//  ShareListViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 1/21/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "GroupEditViewController.h"
#import "SelectGroupViewController.h"
#import "NewPersonViewController.h"
#import "ZZBaseViewController.h"
#import "EmailAddressViewController.h"
#import "ZZAPI.h"

@protocol ShareListViewControllerDelegate

@required
- (void) shareListComplete:(NSArray*)people groups:(NSArray*)groups;
@end

@interface ShareListViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate, ABPeoplePickerNavigationControllerDelegate, GroupEditViewControllerDelegate, SelectGroupViewControllerDelegate, NewPersonViewControllerDelegate, EmailAddressViewControllerDelegate> {
    
    NSObject <ShareListViewControllerDelegate> *delegate;

    UITableView *_addTableView;
    UITableView *_shareList;
    
    BOOL _asAlbumShareList;                 // as an album share list (for album admin/pick view/contributor type for each person/group) or just a share list
    NSMutableArray *_groupShareList;
    NSMutableArray *_peopleShareList;   
    
    NSArray *_groups;                       // this user's groups
    
    BOOL _editing;

}

@property (nonatomic, retain) IBOutlet UITableView *addTableView;
@property (nonatomic, retain) IBOutlet UITableView *shareList;

-(void)setShareList:(BOOL)asAlbumShareList people:(NSArray*)people groups:(NSArray*)groups;
-(void)setDelegate:(id)newDelegate;
-(void)getGroups:(BOOL)init;
-(void)toggleShareListItem:(int)index;

@end
