//
//  AlbumsViewController.m
//  zziphone
//
//  Created by Phil Beisel on 7/11/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import "SDImageCache.h"
#import "MainViewController.h"
#import "AlbumsViewController.h"
#import "AlbumViewController.h"
#import "UIImageView+WebCache.h"
#import "ZZUINavigationBar.h"
#import "UIFactory.h"
#import "ZZLabel.h"
#import "zzglobal.h"
#import "albums.h"
#import "ZZCache.h"
#import "ZZUser.h"


#define kRowHeight                          108

#define kFooter_Height                      51


@implementation AlbumsViewController

@synthesize albumtable;
@synthesize albumselect;
@synthesize albumselectholder;

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginNotification:) name:@"Login" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LogoutNotification:) name:@"Logout" object:nil];        
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    

    _rowheight = kRowHeight;
    [albumtable setSeparatorColor:[UIColor clearColor]];
    albumtable.rowHeight = _rowheight;
    
    // navbar bottom border (covers 1 pixel black border)
    /*
     UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
     [overlayView setBackgroundColor:[UIColor colorWithRed: 172.0/255.0 green: 172.0/255.0 blue: 172.0/255.0 alpha: 1.0]];
     [navbar addSubview:overlayView]; 
     [overlayView release];
     */
    
    // albumtable top border
    //UIView *overlayView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    //[overlayView2 setBackgroundColor:[UIColor colorWithRed: 172.0/255.0 green: 172.0/255.0 blue: 172.0/255.0 alpha: 1.0]];
    //[albumtable addSubview:overlayView2]; 
    
    /*
     // fill albumselectholder gradient
     UIColor *gcolor1 = [UIColor colorWithRed: 244.0/255.0 green: 244.0/255.0 blue: 244.0/255.0 alpha: 1.0];
     UIColor *gcolor2 = [UIColor colorWithRed: 219.0/255.0 green: 219.0/255.0 blue: 219.0/255.0 alpha: 1.0];
     CAGradientLayer *gradient = [CAGradientLayer layer];
     gradient.frame = albumselectholder.bounds;
     gradient.colors = [NSArray arrayWithObjects:(id)[gcolor1 CGColor], (id)[gcolor2 CGColor], nil];
     [albumselectholder.layer insertSublayer:gradient atIndex:0];
     */
    
    UIImageView *segmentBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment-background.png"]];
    [albumselectholder insertSubview:segmentBackgroundImage atIndex:0];
    
    UIImageView *navDropShadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seg-nav-drop-shadow.png"]];
    navDropShadowImage.frame = CGRectMake(0, 0, navDropShadowImage.image.size.width, navDropShadowImage.image.size.height);
    [albumselectholder insertSubview:navDropShadowImage atIndex:1];
        
    [self switchToView];  
}


- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
}


- (void)switchToView
{
    MLOG(@"AlbumsViewController: switch view");
    
    NSString* albumstype = [gZZ stringForSetting:[ZZSession currentUser].user_id setting:@"albums_type"];
    if (albumstype == NULL)
        albumstype = @"my";     // default
    
    ZZUserID albumsuser = 0;
    NSNumber* n = [gZZ numberForSetting:[ZZSession currentUser].user_id setting:@"albums_user"];
    if (n) {
        albumsuser = [n unsignedLongLongValue];
    } else {
        albumsuser = [ZZSession currentUser].user_id;      // default
    }
    
    _albumstype = [[NSString alloc] initWithString:albumstype];
    _userid = albumsuser;
    
    //If user is not logged in display default user
    if (_userid == 0)
        _userid = [gZZ defaultuserid];
    
    _loaded = NO;
    if ([gAlbums albumsetloaded:_userid type:_albumstype]) {
        _loaded = YES;
        _updated = [gAlbums albumsetsupdated:_userid];
    }
    
    if (!_loaded)
        [gAlbums getalbumsets:_userid];
    
    [self setupNavigationBar];
    
    if (albumselect) {
        [albumselect removeFromSuperview];
    }
    
    if (_userid == [ZZSession currentUser].user_id) {
        // me
        NSDictionary *albumselectdef = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"All", @"My", @"Liked", @"Invited", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(77,30)], @"size", @"segment.png", @"button-image", @"segment-selected.png", @"button-highlight-image", @"segment-separator.png", @"divider-image", [NSNumber numberWithFloat:11.0], @"cap-width", [UIColor blackColor], @"button-color", [UIColor blackColor], @"button-highlight-color", nil];
        
        albumselect = [[ZZSegmentedControl alloc] initWithSegmentCount:4 selectedSegment:[self segmentFromType:_albumstype] segmentdef:albumselectdef tag:0 delegate:self];
        albumselect.frame = CGRectMake(5, 7, albumselect.frame.size.width, albumselect.frame.size.height);    // adjust location
        [albumselectholder addSubview:albumselect];
    } else {
        // user's
        NSString *usernamep = @"ZangZing";
        ZZUser *cachedUser = [ZZCache getCachedUser: _userid];
        if (cachedUser){
            usernamep = [cachedUser displayFirstName];
        }
        
        NSDictionary *albumselectdef = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"All", usernamep, @"Liked", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(102,30)], @"size", @"segment.png", @"button-image", @"segment-selected.png", @"button-highlight-image", @"segment-separator.png", @"divider-image", [NSNumber numberWithFloat:11.0], @"cap-width", [UIColor blackColor], @"button-color", [UIColor blackColor], @"button-highlight-color", nil];
        
        albumselect = [[ZZSegmentedControl alloc] initWithSegmentCount:3 selectedSegment:[self segmentFromType:_albumstype] segmentdef:albumselectdef tag:0 delegate:self];
        albumselect.frame = CGRectMake(5, 7, albumselect.frame.size.width, albumselect.frame.size.height);    // adjust location
        [albumselectholder addSubview:albumselect];
    }
    
    [self postZZAViewEvent];
    
    if (_loaded)
        [albumtable reloadData];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval: .1 target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];
}



-(void)switchFromView
{
    [_timer invalidate];
    _timer = nil;
    
    [self clearAlbumTable];
}


-(void) postZZAViewEvent
{
    // post view.albums event
    
    if (_userid == [ZZSession currentUser].user_id) {
        NSString* event = [NSString stringWithFormat:@"view.my.%@.albums", _albumstype];
        [ZZGlobal trackEvent:event xdata:nil];      
    } else {
        NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
        [xdata setObject:[NSNumber numberWithUnsignedLongLong:_userid] forKey:@"userid"];
        
        NSString* event = [NSString stringWithFormat:@"view.other.%@.albums", _albumstype];
        [ZZGlobal trackEvent:event xdata:xdata];      
    }
}

- (void) setupNavigationBar
{    
    // customize nav bar
    
    ZZUINavigationBar* navbar = (ZZUINavigationBar*)self.navigationController.navigationBar;
    [navbar setBackgroundWith:[UIImage imageNamed:@"nav-background.png"]];
    
    if (_userid==[gZZ defaultuserid]) {
        UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zzlogo-1.png"]];
        self.navigationItem.titleView = logoView;
    } else {
        UIView *titleview = [[UIView alloc]initWithFrame:CGRectMake(0,0,150,32)];
        
        NSString *title=@"";
        if([ZZSession currentSession]){
            title = [[ZZSession currentUser] displayFirstName];
        }
        int pwidth = 42;            // profile image + spacing
        int titleareawidth = 150;   // area for title text
        
        int titlewidth = pwidth + titleareawidth;     // total allowed width for the title (profile pict + spacing + title width)
        int fontsize = 16;
        
        // given title, find max font size that will fit and hold that width
        for (int i = 16; i >= 12; i--) {
            float fwidth = [title sizeWithFont:[UIFont boldSystemFontOfSize:i]].width;
            if (fwidth <= titleareawidth) {
                titlewidth = pwidth + fwidth;
                fontsize = i;
                break;
            }
        }
        
        // now with titlewidth, center
        int screenwidth = 320;
        int xoffset = (screenwidth - titlewidth) / 2;
        int titleviewxpos = 85;     // natural x position for title view in navbar
        
        // rect  x,y,width,height
        int x;
        int y;
        int height;
        int width;
        
        x = xoffset - titleviewxpos;       // set x to centering offset adjusted by titleview's normal x pos
        
        y = -3;
        height = 38;
        width = 37;
        
        UIImageView *profileframe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile-frame.png"]];
        profileframe.frame = CGRectMake(x,y,width,height); 
        profileframe.bounds = CGRectMake(0,0,width,height); 
        [titleview addSubview:profileframe];
        
        UIImageView *userimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_profile.png"]];
        ZZUser *cachedUser = [ZZCache getCachedUser:_userid];
        if (cachedUser)
            [userimage setImageWithURL_SD:[NSURL URLWithString:cachedUser.profile_photo_url]];
        
        userimage.frame = CGRectMake(5,5,27,27); 
        userimage.bounds = CGRectMake(0,0,27,27); 
        userimage.clipsToBounds = YES;
        userimage.contentMode = UIViewContentModeScaleAspectFill;
        [profileframe addSubview:userimage];
        
        x = x + pwidth;
        y = 0;
        height = 32;
        width = 150;
        
        ZZUILabel *titlelabel = [[ZZUILabel alloc]initWithShadowSpec:CGRectMake(x,y,width,height) shadowColor:[UIColor whiteColor] offsetX:0 offsetY:1 blur:2];
        
        titlelabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
        titlelabel.font = [UIFont boldSystemFontOfSize:fontsize];
        titlelabel.textColor = [UIColor blackColor];
        titlelabel.text = title;
        
        [titleview addSubview:titlelabel];
        self.navigationItem.titleView = titleview;
        
        if (_userid != [ZZSession currentUser].user_id) {
            UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
            followButton.frame = CGRectMake(0,0,50,29);
            [followButton setTitle:@"Follow" forState:UIControlStateNormal];
            [followButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
            followButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            
            CGFloat capWidth = 5.0;
            UIImage* followButtonImage = [[UIImage imageNamed:@"green-btn.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
            [followButton setBackgroundImage:followButtonImage forState:UIControlStateNormal];
            
            UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithCustomView:followButton];
            self.navigationItem.rightBarButtonItem = rightButton;
        } else {
            self.navigationItem.rightBarButtonItem = NULL;
        }
        
        /*
         self.navigationItem.rightBarButtonItem = [self editButtonItem];   
         
         UIBarButtonItem* addbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:NULL];
         addbutton.style = UIBarButtonItemStyleBordered;
         self.navigationItem.leftBarButtonItem = addbutton;
         [addbutton release];
         */   
    }
}


-(void)willAppearIn:(UINavigationController *)navigationController
{
    ZZUINavigationBar* navbar = (ZZUINavigationBar*)navigationController.navigationBar;
    navbar.translucent = NO; 
    navbar.tintColor = nil;
    [navbar setBackgroundWith:[UIImage imageNamed:@"nav-background.png"]];
}


-(void) newLogin:(BOOL)login
{
    // force reload of data on login/logout
    
    MLOG(@"AlbumsViewController: login/logout notification, invalidating data");
    
    
    if( [ZZSession currentSession] ){
        _userid = [ZZSession currentUser].user_id;
    }else{
        _userid = [gZZ defaultuserid];
    }
    
    _loaded = NO;
    [gAlbums getalbumsets:_userid];
    
    [albumtable reloadData];
    
    [self setupNavigationBar];
}


-(void) LoginNotification:(NSNotification*)notification
{
    MLOG(@"AlbumsViewController: LoginNotification");
    [self newLogin:YES];
}


-(void) LogoutNotification:(NSNotification*)notification
{
    MLOG(@"AlbumsViewController: LogoutNotification");
    [self newLogin:NO];
}


- (void) handleTimer:(NSTimer*)timer 
{    
    //MLOG(@"AlbumsViewController: handleTimer %@", self);
    
    // force reload of data if model updated
    unsigned long updated = [gAlbums albumsetsupdated:_userid];
    if (updated != 0 && _updated !=0 && updated > _updated) {
        MLOG(@"AlbumsViewController: have updated albums, invalidating data");
        
        _loaded = NO;
        [gAlbums getalbumsets:_userid];
        
        [albumtable reloadData];
    }
    
    
    if (_loaded)
        return;
    
	//MLOG(@"AlbumsViewController: handleTimer, waiting on data");
    
    if ([gAlbums albumsetloaded:_userid type:_albumstype]) {
        _updated = [[NSDate date] timeIntervalSince1970];
        _loaded = YES;
    }
    
    if (_loaded) {
        MLOG(@"AlbumsViewController: data is now loaded");
        [albumtable reloadData];
    }
} 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    MLOG(@"AlbumsViewController: shouldAutorotateToInterfaceOrientation: %d", interfaceOrientation);
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    NSLog(@"AlbumsViewController: didReceiveMemoryWarning");
    
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
    // flush in-memory image cache
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)viewDidUnload 
{
    NSLog(@"AlbumsViewController: viewDidUnload");
    
    [super viewDidUnload];

	// Release any retained subviews of the main view
    
    self.albumtable = nil;
    self.albumselectholder = nil;
    
    _albumstype = nil;
    _albumViewController = nil;
    
    [_timer invalidate];
    _timer = nil;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Login" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Logout" object:nil];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (!_loaded)
        return 0;
    
    _rowcount = 0;
    
    NSArray *myalbums = [gAlbums albumset:_userid type:_albumstype];
    if (myalbums)
        _rowcount = myalbums.count;
    
    _rowcount++;   // add footer
    
    MLOG(@"AlbumsViewController: numberOfRowsInSection: %d", _rowcount);
    
    return _rowcount;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    if (_albumViewController == nil)
        _albumViewController = [[AlbumViewController alloc] initWithNibName:@"AlbumView" bundle:[NSBundle mainBundle]];	
    
    int pos = [indexPath indexAtPosition: 1];
    NSArray *myalbums = [gAlbums albumset:_userid type:_albumstype];
    NSDictionary *albumdata = [myalbums objectAtIndex: pos];
    
    NSNumber *n; 
    
    n = [albumdata objectForKey:@"id"];
    ZZAlbumID albumid = [n unsignedLongLongValue];
    NSString* u = [albumdata objectForKey:@"user_id"];
    ZZUserID userid = [u longLongValue];  
    n = [albumdata objectForKey:@"updated_at"];
    unsigned long updated_at = [n unsignedLongValue];
    
    _albumViewController.albumid = albumid;
    _albumViewController.userid = userid;
    _albumViewController.updated_at = updated_at;
    _albumViewController.cache_version = [albumdata objectForKey:@"cache_version"];
    _albumViewController.albumname = [albumdata objectForKey:@"name"];
    
    [_albumViewController setDelegate:self];
    
    [_albumViewController loadData];
    
    MLOG(@"requesting Album view for album: %llu user: %llu updated_at %lu", albumid, userid, updated_at);
    
    [self.navigationController pushViewController:_albumViewController animated:YES];
}


-(NSString*)updatedAgo: (NSDate*)ndate 
{
    NSDate *currentDate = [NSDate date];	
    NSTimeInterval difference = [currentDate timeIntervalSinceDate:ndate];			
	
	int x;
	
	int diff = difference;
	int days = diff / 86400;
	x = diff % 86400;
	int hours = x / 3600;
	x = x % 3600;
	int mins = x / 60;
	//int secs = x % 60;
    
    NSString *astr = [[NSString alloc] initWithString:@""];
    
    if (days>0 && hours>0)
        astr = [astr stringByAppendingFormat:@"updated %d days, %d hours ago", days, hours];
    else if (hours>0)
        astr = [astr stringByAppendingFormat:@"updated %d hours ago", hours];
    else if (mins>0)
        astr = [astr stringByAppendingFormat:@"updated %d mins ago", mins];
    
    return astr;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    int pos = [indexPath indexAtPosition: 1];
    
    if (pos == _rowcount - 1)
        return kFooter_Height;
    
    return _rowheight;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSArray *myalbums = [gAlbums albumset:_userid type:_albumstype];
    
    // each element of myalbums contains:
    //	user_id				string		
    //	user_name			string		e.g., pbeisel
    //	updated_at			long, unix epoch time
    //	album_path			string		e.g., /pbeisel/recent
    //	profile_album		true | false
    //	name				string		e.g., recent
    //	id					string
    //	c_url				string		
    
    int pos = [indexPath indexAtPosition: 1];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"album"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"album"];
    } else {
        //NSLog(@"AlbumsViewController cell reused: %d", cell.contentView.subviews.count);
        for (UIView *view in cell.contentView.subviews) {
            
            // kill active downloads
            if ([view isKindOfClass:[UIImageView class]]) {
                UIImageView *albumimage = (UIImageView*)view;
                [albumimage cancelCurrentImageLoad];
            }
            [view removeFromSuperview];
        }
    }
    
    if (pos == _rowcount - 1) {
        // footer
        UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, kFooter_Height)];
        [cell.contentView addSubview:footer];
        
        return cell;        
    }
    
    //NSString *cellIdentifier = [NSString stringWithFormat: @"s%d:%d", [ indexPath indexAtPosition: 0 ], [ indexPath indexAtPosition:1 ]];
    //MLOG(@"AlbumsViewController:  cellForRowAtIndexPath: %@", cellIdentifier);
    
    NSDictionary *albumdata = [myalbums objectAtIndex: pos];

        
    [UIFactory setAlbumsCell:albumdata cell:cell withDisclosure:YES];
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView 
{
    return;
    
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
}


- (NSInteger)segmentFromType: (NSString*)type
{
    if ([type isEqualToString:@"all"]) {
        return 0;
    } else if ([type isEqualToString:@"my"]) {
        return 1;
    } else if ([type isEqualToString:@"liked"]) {
        return 2;
    } else
        return 3;
}


- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    switch (segmentIndex) {
        case 0:
            // all albums
            MLOG(@"switching to 'all' albums");
            _albumstype = @"all";
            [gZZ setStringForSetting:[ZZSession currentUser].user_id setting:@"albums_type" value:@"all"];
            _loaded = NO;
            
            [albumtable reloadData];
            [albumtable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            
            break;            
            
        case 1:
            // my albums
            MLOG(@"switching to 'my' albums");
            _albumstype = @"my";
            [gZZ setStringForSetting:[ZZSession currentUser].user_id setting:@"albums_type" value:@"my"];
            _loaded = NO;
            
            [albumtable reloadData];
            [albumtable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            
            break;
            
        case 2:
            // liked albums
            MLOG(@"switching to 'liked' albums");
            _albumstype = @"liked";
            [gZZ setStringForSetting:[ZZSession currentUser].user_id setting:@"albums_type" value:@"liked"];
            _loaded = NO;
            
            [albumtable reloadData];
            [albumtable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            
            break;
            
        case 3:
            // invited albums
            MLOG(@"switching to 'invited' albums");
            _albumstype = @"invited";
            [gZZ setStringForSetting:[ZZSession currentUser].user_id setting:@"albums_type" value:@"invited"];
            _loaded = NO;
            
            [albumtable reloadData];
            [albumtable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            
            break;        
        default:
            break;
    }
    
    [self postZZAViewEvent];
}


- (void) albumViewControllerDone:(ZZUserID)userid albumid:(ZZAlbumID)albumid
{
    [gV switchTabbar:kTABBAR_MainBar selectedTab:0];
    [self.navigationController popViewControllerAnimated:YES];
    
    //[_albumViewController setDelegate:nil];
    //_albumViewController = nil;
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




@end
