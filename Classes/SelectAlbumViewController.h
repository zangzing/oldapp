//
//  SelectAlbumViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 11/4/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zztypes.h"
#import "NewAlbumViewController.h"
#import "ZZSegmentedControl.h"
#import "ZZBaseViewController.h"
#import "ZZAPI.h"


@protocol SelectAlbumViewControllerDelegate

@required
- (void) uploadToSelectedAlbum:(ZZAlbum *)selectedAlbum;

@optional
- (void) selectedAlbum:(ZZUserID)userid albumid:(ZZAlbumID)albumid albumName:(NSString*)albumName;
- (void) cancelAlbumSelect;
@end

@class ZZUINavigationBar;

@interface SelectAlbumViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, ZZSegmentedControlDelegate, NewAlbumViewControllerDelegate> {
    
    NSObject <SelectAlbumViewControllerDelegate> *delegate;

    UITableView *albumsTable;	
    UIView *albumsSelectHolder;
    ZZSegmentedControl *albumsSelect;
    
    NSString *_albumstype;                     // albums type e.g., 'all', 'my', 'liked'
    ZZUserID _userid;                          // albums owner
    
    NSMutableArray *_myalbumaddindices;
}

@property (nonatomic, strong) IBOutlet UITableView *albumsTable;
@property (nonatomic, strong) ZZSegmentedControl *albumsSelect;
@property (nonatomic, strong) IBOutlet UIView *albumsSelectHolder;

- (void)setupNavigationBar;
- (void)setDelegate:(id)newDelegate;

@end
