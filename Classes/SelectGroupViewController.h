//
//  SelectGroupViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 1/29/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zztypes.h"
#import "ZZAPI.h"
#import "GroupAddViewController.h"
#import "ZZBaseViewController.h"

@protocol SelectGroupViewControllerDelegate

@required
-(void)selectGroupDone:(ZZGroup *)group;
-(void)selectGroupCancel;
@end


@interface SelectGroupViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, GroupAddViewControllerDelegate> {
    
    NSObject <SelectGroupViewControllerDelegate> *_delegate;
    UITableView *_selectgroup;
    NSArray *_groups;
    NSMutableArray *_useGroups;         
    BOOL _allowTypeSelection;
    NSArray *_excludeGroups;            // groups to filter out
}

@property (nonatomic, retain) IBOutlet  UITableView *selectgroup;
@property (nonatomic, retain) NSObject <SelectGroupViewControllerDelegate> *delegate;

@property (nonatomic) BOOL allowTypeSelection;

-(void)setExcludeGroups:(NSArray*)excludeGroups;

@end
