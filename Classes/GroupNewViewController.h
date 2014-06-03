//
//  GroupNewViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 1/25/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//


//
//  *** This controller is no longer used
//


#import <UIKit/UIKit.h>
#import "ZZAPI.h"
#import "ZZBaseViewController.h"

@protocol GroupNewViewControllerDelegate

@required
-(void)newGroupComplete:(ZZGroup *)group;
-(void)newGroupRenamed:(ZZGroup *)group name:(NSString*)name;
-(void)newGroupCancel;
@end

@interface GroupNewViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
    NSObject <GroupNewViewControllerDelegate> *delegate;

    UITableView *grouptableview;
    UITextField *_groupnametext;
    
    ZZGroup *_group;
    BOOL _closing;    
}

@property (nonatomic, retain) IBOutlet  UITableView *grouptableview;

-(void)setGroup:(ZZGroup *)group;
-(void)setDelegate:(id)newDelegate;

@end
