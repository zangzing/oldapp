//
//  EmailAddressViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 1/29/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZSegmentedControl.h"
#import "ZZBaseViewController.h"

@protocol EmailAddressViewControllerDelegate

@required
-(void)newEmailAddress:(ZZUserID)userid name:(NSString*)name email:(NSString*)email sharePermission:(ZZSharePermission)sharePermission;
-(void)newEmailAddressCancel;
@end

@interface EmailAddressViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ZZSegmentedControlDelegate> {
 
    NSObject <EmailAddressViewControllerDelegate> *_delegate;

    ZZSegmentedControl *_persontype;
    UITableView *emailaddresstable;
    UITextField *_emailtextfield;
    //UITextField *_nametextfield;
    
    ZZUser *_user;
    ZZSharePermission _sharetype;
    BOOL _allowTypeSelection;
}

@property (nonatomic, retain) NSObject <EmailAddressViewControllerDelegate> *delegate;
@property (nonatomic, retain) IBOutlet  UITableView *emailaddresstable;
@property (nonatomic) BOOL allowTypeSelection;

-(void)setZZUser:(ZZUser*)user;

@end
