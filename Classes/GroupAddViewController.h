//
//  GroupAddViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 2/13/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zztypes.h"
#import "ZZGroup.h"
#import "GroupEditViewController.h"
#import "ZZSegmentedControl.h"
#import "ZZBaseViewController.h"

@protocol GroupAddViewControllerDelegate

@required
-(void)groupAddDone:(ZZGroup*)group;
-(void)groupAddCancel;
@end

@interface GroupAddViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, ZZSegmentedControlDelegate, GroupEditViewControllerDelegate> {

    NSObject <GroupAddViewControllerDelegate> *_delegate;
    
    UITableView *_groupedit;
    ZZSegmentedControl *_grouptype;

    UIButton *_addgroup;
    
    ZZGroup *_group;
    
    BOOL _allowTypeSelection;
}

@property (nonatomic, retain) IBOutlet  UITableView *groupedit;
@property (nonatomic, retain) ZZGroup *group;
@property (nonatomic, retain) NSObject <GroupAddViewControllerDelegate> *delegate;

@property (nonatomic) BOOL allowTypeSelection;


@end
