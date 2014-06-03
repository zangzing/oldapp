//
//  AlbumViewController.m
//  zziphone
//
//  Created by Phil Beisel on 8/13/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "AlbumViewController.h"
#import "SDImageCache.h"
#import <QuartzCore/CoreAnimation.h>
#import "MainViewController.h"
#import "UIImageView+WebCache.h"
#import "ZZUIImageView.h"
#import "ZZUINavigationBar.h"
#import "PhotoBrowser.h"
#import "util.h"
#import "zzglobal.h"
#import "albums.h"



#define kRowHeight      105
#define kPhotosPerRow   3

#define kNavBar_Height                      44
#define kAlbumTable_Height                  500
#define kAlbumSelectHolder_Height           44
#define kCacheView_Height                   41
#define kFooter_Height                      55

#define kAlbumSelectHolder_y                44
#define kAlbumTable_y                       85
#define kAlbumSelectHolder_Revealed_y       44



@implementation AlbumViewController

@synthesize albumid;
@synthesize userid;
@synthesize updated_at;
@synthesize cache_version;
@synthesize albumname;
@synthesize albumtable;
@synthesize cacheswitch;
@synthesize cacheactivity;
@synthesize cacheprogress;
@synthesize cacheview;
@synthesize albumviewselect;
@synthesize albumselectholder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        albumid = 0;
        userid = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    MLOG(@"AlbumViewController: didReceiveMemoryWarning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // flush in-memory image cache
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MLOG(@"AlbumViewController: viewDidLoad");
        
    // nav bar
    [self useDefaultNavigationBarStyle];
   
    [self useCustomBackButton:@"Back" target:self action:@selector(goBack:)];
    
    albumtable.rowHeight = kRowHeight;
    
    // navbar bottom border (covers 1 pixel black border)
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
    [overlayView setBackgroundColor:[UIColor colorWithRed: 172.0/255.0 green: 172.0/255.0 blue: 172.0/255.0 alpha: 1.0]];
    // ***N [navbar addSubview:overlayView]; 
    
    // albumtable top border
    UIView *overlayView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [overlayView2 setBackgroundColor:[UIColor colorWithRed: 172.0/255.0 green: 172.0/255.0 blue: 172.0/255.0 alpha: 1.0]];
    [albumtable addSubview:overlayView2]; 
    
    cacheactivity.hidden = YES;
    cacheprogress.hidden = YES;
    cacheprogress.text = @"";
    [cacheswitch setOn:NO];
    [cacheswitch addTarget:self action:@selector(toggleCacheSwitch:) forControlEvents: UIControlEventValueChanged];
        
    _fullViewTranslucent = NO;
    
    // later placed in albumtable row 0
    [cacheview removeFromSuperview];
    
    _hasScrolledToPos1 = NO;
    
    /*
     cacheview.hidden = YES;
     _cachingUIRevealed = NO;
     _cachingUIRevealing = NO;
     _cacheRevealingPos = 0;
     */
    
    
    MLOG(@"albumview: frame: x:%f y:%f width:%f height:%f", self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height);
    
    [gV switchTabbar:kTABBAR_AlbumBar selectedTab:-1];
}


-(void)loadData
{
    titlelabel.text = albumname;
    
    _loaded = NO;
    [gAlbums getalbum:albumid userid:userid updated_at:updated_at cache_version:cache_version forceRefresh:NO];
    if ([gAlbums albumloaded:albumid]) 
        _loaded = YES;
    
    _prefetched = NO;
    
    [gAlbums setLastAlbum:userid albumid:albumid name:albumname];
    
    if ([gAlbums isCaching:albumid userid:userid]) {
        _caching = YES;
    }
    
    // post view.album event
	NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
	[xdata setObject:[NSNumber numberWithUnsignedLongLong:albumid] forKey:@"id"];
	[ZZGlobal trackEvent:@"view.album" xdata:xdata];
    
    if (_loaded) {
        [albumtable reloadData];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval: .1 target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];
}


- (void)viewDidUnload
{
    MLOG(@"AlbumViewController: viewDidUnload");
    
    [super viewDidUnload];
    
    self.albumtable = nil;
    self.cacheview = nil;
    self.cacheswitch = nil;
    self.cacheactivity = nil;
    self.cacheprogress = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
    self.title = albumname;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];

    [ZZUtil setOrientation:UIDeviceOrientationPortrait];
    
    [albumtable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [cacheswitch setOn:NO];
    
    [gV switchTabbar:kTABBAR_AlbumBar selectedTab:-1];
    [gV hideTabbar:NO];
}


- (void)switchToView
{
    MLOG(@"AlbumViewController: switchToView");
}


- (void)actionView:(NSString*)action
{
    MLOG(@"AlbumViewController: actionView: %@", action);
}


-(void)willAppearIn:(UINavigationController *)navigationController
{
    ZZUINavigationBar* navbar = (ZZUINavigationBar*)navigationController.navigationBar;
    navbar.translucent = NO; 
    navbar.tintColor = nil;
    [navbar setBackgroundWith:[UIImage imageNamed:@"nav-background.png"]];
}


- (void) handleTimer:(NSTimer*)timer 
{
	
    //NSLog(@"AlbumViewContoller: handleTimer");
    
    if (_caching) {
        int left = 0;
        int total = 0;
        
        [gAlbums imageCachingProgress:albumid userid:userid left:&left total:&total];
        
        if (left < total && left != -1) {
            float pct = 100 * left / total;
            if (pct > 0) {
                if (cacheprogress.hidden)
                    cacheprogress.hidden = NO;
                if (cacheactivity.hidden) {
                    cacheactivity.hidden = NO;                
                    [cacheactivity startAnimating];
                }
                
                cacheprogress.text = [NSString stringWithFormat:@"%.0f%%", pct];
                [cacheprogress setNeedsDisplay];
            }
        } else {
            _caching = NO;
            
            [cacheactivity stopAnimating];
            cacheactivity.hidden = YES;
            cacheprogress.hidden = YES;
        }
    }
    
    if (_loaded)
        return;
    
	//MLOG(@"AlbumViewController: handleTimer, waiting on data");
    
    if ([gAlbums albumloaded:albumid]) 
        _loaded = YES;
    
    if (_loaded) {
        MLOG(@"AlbumViewController: data is now loaded");
        [albumtable reloadData];
    }
} 


- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:(BOOL)animated];
    
    NSLog(@"AlbumViewController: viewDidDisappear");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    MLOG(@"AlbumViewController: shouldAutorotateToInterfaceOrientation: %d", interfaceOrientation);
        
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    int rows = [self getphotorows];
    
    // force 4 rows to preserve scrolling so that the cacheview can be scrolled off (without this, cacheview will show for <=3 row albums)
    if (rows < 4)
        rows = 4;
    
    rows += 1;     // 1st row is cacheview
    rows += 1;     // footer row
    
    MLOG(@"AlbumsViewController: numberOfRowsInSection: %d", rows);
    
    _rowcount = rows;
    
    return rows;
}


- (int)getphotorows
{
    int c = [gAlbums getphotocount:albumid];
    
    if (c > 0) {
        int r = c / kPhotosPerRow;
        if (c % kPhotosPerRow > 0)
            r++;   
        return r;
    }
    
    return 0;
}


- (void)getrowthumbs: (int)row
{
    int rows = [self getphotorows];
    if (row < 1 || row > rows)
        return;
    
    int r = row - 1;
    for (int c = 1; c <= kPhotosPerRow; c++) {
        [gAlbums getgrid:(r*kPhotosPerRow)+c albumid:albumid];
    }
}


- (void)prefetchrowthumbs: (int)fromrow rows:(int)rows
{
    // *** prefetch off 12.19.11 pb
    return;     
    
    for (int r = 0; r < rows; r++) {
        [self getrowthumbs:(fromrow+r)];
    }
}


- (ZZUIImageView*)getgridthumb: (int)row column:(int)column
{
    /*
    ZZUIImageView* i = [[ZZUIImageView alloc] initWithImage:[UIImage imageNamed:@"coming-soon.png"]];
    i.type = Thumb;
    i.userInteractionEnabled = YES;
    return i;
    */
    
    int rows = [self getphotorows];
    if (row < 1 || row > rows)
        return NULL;
    
    if (column < 1 || column > kPhotosPerRow)
        return NULL;
    
    int photoindex = ((row-1)*kPhotosPerRow)+column;
    ZZUIImageView* image = [gAlbums getgrid:photoindex albumid:albumid];
    //MLOG(@"getgridthumb: %d (%llu)", image.photoIndex, image.photoid);
    return image;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int pos = [indexPath indexAtPosition: 1];
    if (pos == 0)
        return kCacheView_Height - 3;
    else if (pos == _rowcount - 1)
        return kFooter_Height;
    else
        return kRowHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // rect  x,y,width,height
    int x;
    int y;
    int height;
    int width;
    
    int pos = [indexPath indexAtPosition: 1];
    
    //NSString *cellIdentifier = [NSString stringWithFormat: @"s%d:%d", [ indexPath indexAtPosition: 0 ], [ indexPath indexAtPosition:1 ]];
    //MLOG(@"AlbumViewController:  cellForRowAtIndexPath: %@", cellIdentifier);       
    
    @try {
        NSString* reuseIdentifer = @"photo";
        if (pos == 0)
            reuseIdentifer = @"header";
        if (pos == _rowcount - 1)
            reuseIdentifer = @"footer";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
        } else {
            //NSLog(@"cell reused: %d", cell.contentView.subviews.count);
            for (UIView *view in cell.contentView.subviews) {
                
                // kill active downloads
                if ([view isKindOfClass:[ZZUIImageView class]]) {
                    ZZUIImageView *albumimage = (ZZUIImageView*)view;
                    [albumimage cancelCurrentImageLoad];
                }
                
                [view removeFromSuperview];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (pos == 0) {
            // header
            cacheview.frame = CGRectMake(0, 0, 320, kCacheView_Height);
            [cell.contentView addSubview:cacheview];
            
            if ([gAlbums isCaching:albumid userid:userid]) {
                _caching = YES;
                [cacheswitch setOn:YES];
            }
            
            return cell;
        }
        
        if (pos == _rowcount - 1) {
            // footer
            UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, kFooter_Height)];
            [cell.contentView addSubview:footer];
            
            return cell;        
        }
        
        if (!_hasScrolledToPos1) {
            
            // set this once, scrolls off the cacheview
            _hasScrolledToPos1 = YES;
            [albumtable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
        // reset to 0-based (to ignore pos=0 cacheview row)
        pos -= 1;
        
        // fill with off-white
        UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kRowHeight)];
        backview.backgroundColor = [UIColor colorWithRed: 249.0/255.0 green: 249.0/255.0 blue: 250.0/255.0 alpha: 1.0];
        [cell.contentView addSubview:backview];
        
        x = 3;
        y = 3;
        height = 104;
        width = 104;
        
        for (int c = 1; c <= kPhotosPerRow; c++) {
            
            ZZUIImageView *thumbview = [self getgridthumb:(pos+1) column:c]; 
            if (thumbview) {            
                UIImageView *photoFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-grid-frame.png"]];
                photoFrame.frame = CGRectMake(x,y,width,height); 
                [cell.contentView addSubview:photoFrame];  
                
                [thumbview setDelegate:self];
                
                thumbview.albumid = albumid;
                thumbview.target = AlbumView;            
                thumbview.frame = CGRectMake(x+5,y+4,94,94); 
                //thumbview.bounds = CGRectMake(0,0,width,height); 
                thumbview.clipsToBounds = YES;
                thumbview.contentMode = UIViewContentModeScaleAspectFill;
                [cell.contentView addSubview:thumbview];
            }
            
            x += (width + 1);
        }
        
        if (pos == 4 && !_prefetched) {
            // after 5th row, others are offscreen, prefetch some rows below
            // want the first displayable images to show before prefetching below the fold
            _prefetched = YES;
            [self prefetchrowthumbs:4+1 rows:30];
        }
    
        return cell;
    }
    @catch (NSException *exception) {
        MLOG(@"cellForRowAtIndexPath EXCEPTION: %@", exception);
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NULL];
        cell.textLabel.text = [NSString stringWithFormat:@"EXCEPTION: %@", exception];
        return cell;
    }
}


-(void)clearAlbumTable
{
    // drop all cell views
    NSInteger nSections = [albumtable numberOfSections];
    for (int j=0; j<nSections; j++) {
        NSInteger nRows = [albumtable numberOfRowsInSection:j];
        for (int i=0; i<nRows; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
            UITableViewCell *cell = [albumtable cellForRowAtIndexPath:indexPath];
            for (UIView *view in cell.contentView.subviews) 
                [view removeFromSuperview];
        }
    }
}


- (void)goBack:(id)sender
{
    [_timer invalidate];
    _timer = nil;
    
    [self clearAlbumTable];

    [gAlbums unloadalbum:albumid];
    
    // back to Albums view
    [delegate albumViewControllerDone:userid albumid:albumid];
}


- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}


/*  10.4.11 pb
 
 the code in scrollViewDidEndDragging + scrollViewDidScroll produces the effect of revealing the cacheview panel (above the segment controller)
 we decided to scrap this for a simplier model (placing the cacheview as cell 0 in the table view)
 but i left this code to illustrate this model in case we need it elsewhere or want to revive it
 */

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    /*
     if (_cachingUIRevealing) {
     
     MLOG(@"cache reveal end");
     _cachingUIRevealing = NO;
     
     if (_cacheRevealingPos >= kCacheView_Height) {
     // fully revealed, set as so
     MLOG(@"cache revealed");
     _cachingUIRevealed = YES;
     _cacheRevealingPos = 0;
     
     // pin below releaved cacheview
     albumtable.frame = CGRectMake(0, kNavBar_Height+kCacheView_Height+kAlbumSelectHolder_Height, 320, kAlbumTable_Height);
     }
     }
     */
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView 
{
    _lastscroll = CFAbsoluteTimeGetCurrent();    
    
    /*
     CGPoint offset = aScrollView.contentOffset;
     CGRect bounds = aScrollView.bounds;
     CGSize size = aScrollView.contentSize;
     UIEdgeInsets inset = aScrollView.contentInset;
     float y = offset.y + bounds.size.height - inset.bottom;
     float h = size.height;
     MLOG(@"offset: %f", offset.y);   
     MLOG(@"content.height: %f", size.height);   
     MLOG(@"bounds.height: %f", bounds.size.height);   
     MLOG(@"inset.top: %f", inset.top);   
     MLOG(@"inset.bottom: %f", inset.bottom);   
     MLOG(@"pos: %f of %f", y, h);
     */
    
    /*
     CGPoint offset = aScrollView.contentOffset;
     if (offset.y < -10 && _fullViewTranslucent) {
     
     albumtable.frame = CGRectMake(0, kNavBar_Height+kAlbumSelectHolder_y, 320, kAlbumTable_Height);
     
     [navbar setAlpha:1.0];
     [albumselectholder setAlpha:1.0];
     
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
     
     _fullViewTranslucent = NO;
     }
     
     // begin revealing cacheview
     if (offset.y < -5 && (!_cachingUIRevealed && !_cachingUIRevealing)) {
     
     // begin reveal
     
     _cacheRevealingPos = 0;
     _cachingUIRevealing = YES;
     
     MLOG(@"cache reveal start");
     
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
     
     [navbar setAlpha:1.0];
     
     cacheview.frame = CGRectMake(0, kNavBar_Height, 320, 0);
     albumselectholder.frame = CGRectMake(0, kNavBar_Height, 320, kAlbumSelectHolder_Height);
     
     [albumselectholder setAlpha:1.0];
     
     cacheview.clipsToBounds = YES;
     cacheview.hidden = NO;
     }
     
     // reveal cacheview (in progress)
     if (_cachingUIRevealing) {
     
     _cacheRevealingPos = -(5 + offset.y);
     if (_cacheRevealingPos < 0)
     _cacheRevealingPos = 0;
     if (_cacheRevealingPos > kCacheView_Height)
     _cacheRevealingPos = kCacheView_Height;
     
     //MLOG(@"_cacheRevealingPos: %d", _cacheRevealingPos);
     
     cacheview.frame = CGRectMake(0, kNavBar_Height, 320, _cacheRevealingPos);
     albumselectholder.frame = CGRectMake(0, kNavBar_Height + _cacheRevealingPos, 320, kAlbumSelectHolder_Height);
     }
     
     
     if (offset.y > 10) {
     
     if (_cachingUIRevealed) {
     MLOG(@"reveal: OFF");
     
     _cachingUIRevealed = NO;
     
     // wash away reveal
     CATransition *t = [CATransition animation];
     t.type = kCATransitionReveal;
     t.subtype = kCATransitionFromTop;
     [cacheview.layer addAnimation:t forKey:nil];
     
     albumselectholder.frame = CGRectMake(0, kNavBar_Height, 320, kAlbumSelectHolder_Height);
     
     cacheview.hidden = YES;
     }
     
     _fullViewTranslucent = YES;
     
     albumtable.frame = CGRectMake(0, -20, 320, kAlbumTable_Height);       // move to 0 position to allow scroll under transparent area
     
     navbar.alpha = 0.6;
     navbar.barStyle = UIBarStyleBlackTranslucent;
     [albumselectholder setAlpha:0.6];
     
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
     }
     
     */
}

// ZZUIImageViewDelegate

- (void)imageTap:(ZZUIImageView *)image
{
    MLOG(@"AlbumViewController: imageTap");
    
    NSArray *photos = [gAlbums getScreenPhotos:image.albumid];
    
    if (_photoBrowser == nil) {
        _photoBrowser = [[PhotoBrowser alloc] initWithPhotos:photos];
        [_photoBrowser setDelegate:self];
        [_photoBrowser setInitialPageIndex:image.photoIndex-1]; 
    } else {
        [_photoBrowser setPhotos:photos];
        [_photoBrowser setInitialPageIndex:image.photoIndex-1]; 
        [_photoBrowser setupView];
    }
        
    [self.navigationController pushViewController:_photoBrowser animated:YES];
}


- (void)imageLoaded:(ZZUIImageView *)image
{
    //MLOG(@"AlbumViewController: imageLoaded");
}


- (NSNumber*)shouldAnimateLoaded:(ZZUIImageView *)image
{
    // animate first 12 (initially visible)
    
    if (image.photoIndex <= 12)
        return [NSNumber numberWithBool:YES];
    
    return [NSNumber numberWithBool:NO];
}


- (NSNumber*)shouldAnimateDownloaded:(ZZUIImageView *)image
{
    int rows = [self getphotorows];
    if (rows <= 4)
        [NSNumber numberWithBool:YES];
    
    /*
     float deltaTimeInSeconds = CFAbsoluteTimeGetCurrent() - _lastscroll;
     if (deltaTimeInSeconds < 1)
     return [NSNumber numberWithBool:NO];
     */
    
    return [NSNumber numberWithBool:YES];
}


-(void)toggleCacheSwitch:(id)sender
{
    if (cacheswitch.isOn) {
        
        cacheprogress.text = @"";
        [cacheactivity setNeedsDisplay];
        
        NSDictionary* args = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:albumid] , @"albumid", [NSNumber numberWithLongLong:userid], @"userid", [NSNumber numberWithLongLong:updated_at], @"updated_at", cache_version, @"cache_version", nil];
        [gAlbums performSelectorInBackground:@selector(startImageCaching:) withObject:args];
        
        _caching = YES;
        cacheactivity.hidden = NO;
        cacheprogress.hidden = NO;
        [cacheactivity startAnimating];
        
        NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
        [xdata setObject:[NSNumber numberWithUnsignedLongLong:albumid] forKey:@"id"];
        [ZZGlobal trackEvent:@"cache.album" xdata:xdata]; 
    } else {
        
        _caching = NO;
        cacheactivity.hidden = YES;
        cacheprogress.hidden = YES;
        [cacheactivity stopAnimating];
        
        NSDictionary* args = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:albumid] , @"albumid", [NSNumber numberWithLongLong:userid], @"userid", nil];
        [gAlbums performSelectorInBackground:@selector(stopImageCaching:) withObject:args];
    }
}


- (void)photoBrowserDone:(PhotoBrowser*)photoBrowser
{
    MLOG(@"AlbumViewController: photoBrowserDone");
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}



@end
