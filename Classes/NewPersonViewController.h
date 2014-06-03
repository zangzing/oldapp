//
//  NewPersonViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 2/3/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZAPI.h"
#import "ZZBaseViewController.h"
#import "ZZSegmentedControl.h"

typedef enum{
    kPersonNewMode,
    kPersonEditMode,
} ZZPersonEditMode;

@protocol NewPersonViewControllerDelegate

@required
-(void)newPersonAdded:(ZZUser*)user;
-(void)newPersonChanged:(ZZUser*)user;
-(void)newPersonCancel;
@end


@interface NewPersonViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, ZZSegmentedControlDelegate> {

    NSObject <NewPersonViewControllerDelegate> *_delegate;

    ZZUser *_user;
    NSArray *_emails;
    NSString *_first;
    NSString *_last;
    
    ZZSegmentedControl *_persontype;
    UILabel *_nameLabel;
    UILabel *_emailLabel;
    UIImageView *_profileImage;
    UITableView *_emailSelect;
    
    ZZSharePermission _sharetype;
    NSString *_emailSelected;
    
    BOOL _allowTypeSelection;
    
    ZZPersonEditMode _mode;
}

-(void)setUser:(ZZUser*)user first:(NSString*)first last:(NSString*)last;
-(void)setContact:(NSArray*)emails first:(NSString*)first last:(NSString*)last;

@property (nonatomic, retain) NSObject <NewPersonViewControllerDelegate> *delegate;

@property (nonatomic, retain) IBOutlet  UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet  UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet  UIImageView *profileImage;
@property (nonatomic, retain) IBOutlet  UITableView *emailSelect;

@property (nonatomic) BOOL allowTypeSelection;
@property (nonatomic) ZZPersonEditMode mode;


@end
