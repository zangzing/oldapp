//
//  SavePhotoViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 10/19/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZBaseViewController.h"
#import "ZZGradientButton.h"
#import "ZZAlbumShareTable.h"
#import "SelectAlbumViewController.h"
#import "ShareListViewController.h"



@protocol SavePhotoViewControllerDelegate

@optional
- (void) addPhotoAction:(ZZUserID)userid albumid:(ZZAlbumID)albumid shareData:(NSDictionary*)shareData;
- (void) cancelPhotoAction;
@end


@interface SavePhotoViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ZZAlbumShareTableDelegate>
{
    NSObject <SavePhotoViewControllerDelegate> *delegate;

    UIButton *addButton;
    UITableView *albumselect;
    
    ZZAlbumShareTable *_albumShare;             // album share table
    
    SelectAlbumViewController *_selectAlbumVC;
    
    BOOL _animateforedit;
    
    ZZUserID _setuserid;                        // set user id, to use for upload
    ZZAlbumID _setalbumid;                      // set album id, to use for upload
    
    NSArray *_sharePeople;
    NSArray *_shareGroups;
    
    BOOL _usingAlbumShareList;                  // if album owner (admin), use album share list
    ZZShareList *_albumShareList;
}

@property (nonatomic, retain) IBOutlet  UIButton *addButton;
@property (nonatomic, retain) IBOutlet  UITableView *albumselect;
@property (nonatomic, retain) IBOutlet  ZZAlbumShareTable *albumShare;
@property (nonatomic, retain) IBOutlet  UITableView *sharemessagecontainer;

-(void)setDelegate:(id)newDelegate;
-(void)setupSharing;


@end
