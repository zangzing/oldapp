//
//  AlbumViewController.h
//  zziphone
//
//  Created by Phil Beisel on 8/13/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "ZZBaseViewController.h"
#import "ZZSegmentedControl.h"
#import "ZZTabBar.h"
#import "ZZUIImageView.h"

@class ZZUIImageView;
@class PhotoBrowser;

@protocol AlbumViewControllerDelegate

@optional
- (void) albumViewControllerDone:(ZZUserID)userid albumid:(ZZAlbumID)albumid;
@end


@interface AlbumViewController : ZZBaseViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, ZZSegmentedControlDelegate, ZZTabBarViewController, ZZUIImageViewDelegate> {
    
    NSObject <AlbumViewControllerDelegate> *delegate;
    
    NSTimer *_timer;

    UITableView *albumtable;
    UIView *cacheview;
    UISwitch *cacheswitch;
    UIActivityIndicatorView *cacheactivity;
    UILabel *cacheprogress;
    UILabel *titlelabel;
    
    BOOL _loaded;                              // data is ready
    BOOL _prefetched;                          // prefetched rows after initial grid
    ZZAlbumID albumid;
    ZZUserID userid;
    unsigned long long updated_at;
    NSString* cache_version;
    NSString* albumname;
    BOOL _caching;                             // caching in progress
    BOOL _fullViewTranslucent;
    
    /*
     BOOL _cachingUIRevealed;                   // done: revealed
     BOOL _cachingUIRevealing;                  // in progress
     int _cacheRevealingPos;                    // in progress, y pos
     */
    
    int _rowcount;          
    CFTimeInterval _lastscroll;                // last time user scrolled
    BOOL _hasScrolledToPos1;
    
    PhotoBrowser *_photoBrowser;
}

- (void)loadData;
- (int)getphotorows;
- (void)getrowthumbs: (int)row;
- (ZZUIImageView*)getgridthumb: (int)row column:(int)column;
- (void)prefetchrowthumbs: (int)fromrow rows:(int)rows;
- (void)setDelegate:(id)newDelegate;

@property (nonatomic, strong) IBOutlet UITableView *albumtable;
@property (nonatomic, strong) ZZSegmentedControl *albumviewselect;
@property (nonatomic, strong) IBOutlet UIView *albumselectholder;
@property (nonatomic, strong) IBOutlet UIView *cacheview;
@property (nonatomic, strong) IBOutlet UISwitch *cacheswitch;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *cacheactivity;
@property (nonatomic, strong) IBOutlet UILabel *cacheprogress;

@property (nonatomic) unsigned long long albumid;
@property (nonatomic) unsigned long long userid;
@property (nonatomic) unsigned long long updated_at;
@property (nonatomic, strong) NSString *cache_version;
@property (nonatomic, strong) NSString *albumname;

@end
