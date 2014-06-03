//
//  AlbumsViewController.h
//  zziphone
//
//  Created by Phil Beisel on 7/11/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "ZZSegmentedControl.h"
#import "AlbumViewController.h"
#import "ZZTabBar.h"
#import "zztypes.h"

@class UISegmentedControl;

@interface AlbumsViewController : ZZUIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, ZZSegmentedControlDelegate, ZZTabBarViewController, AlbumViewControllerDelegate> 
{
    
	UITableView *albumtable;	
    UIView *albumselectholder;
    ZZSegmentedControl *albumselect;
    
    NSTimer *_timer;
    
    BOOL _loaded;                              // data is ready
    NSString *_albumstype;                     // albums type e.g., 'all', 'my', 'liked'
    ZZUserID _userid;                          // albums owner
    unsigned long _updated;                    // when album set data was last updated
    
    NSUInteger _rowcount;
    NSUInteger _rowheight;                     // row height
    NSUInteger _v;                             // view
    
    AlbumViewController *_albumViewController;
}

@property (nonatomic, strong) IBOutlet UITableView *albumtable;
@property (nonatomic, strong) ZZSegmentedControl *albumselect;
@property (nonatomic, strong) IBOutlet UIView *albumselectholder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
-(void)setupNavigationBar;
-(NSInteger)segmentFromType: (NSString*)type;
-(void)postZZAViewEvent;

-(void)clearAlbumTable;

@end
