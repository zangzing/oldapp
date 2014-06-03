//
//  SelectAlbumViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 11/4/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import "zzglobal.h"
#import "albums.h"
#import "MainViewController.h"
#import "SelectAlbumViewController.h"
#import "ZZUINavigationBar.h"
#import "UIImageView+WebCache.h"
#import "NewAlbumViewController.h"
#import "UIFactory.h"
#import "ZZLabel.h"
#import "photouploader.h"

#define kRowHeight  109

@implementation SelectAlbumViewController

//@synthesize navbar;
@synthesize albumsTable;
@synthesize albumsSelectHolder;
@synthesize albumsSelect;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // data
    _albumstype = @"my";
    _userid = [ZZSession currentUser].user_id;
    
    [gAlbums getalbumsets:_userid];
    
    [gAlbums albumsetloaded:_userid type:@"my"];
    [gAlbums albumsetloaded:_userid type:@"liked"];
    [gAlbums albumsetloaded:_userid type:@"invited"];
    [gAlbums albumsetloaded:_userid type:@"all"];
    
    albumsTable.rowHeight = kRowHeight;
    
    [self setupNavigationBar];
    
    [ZZGlobal trackEvent:@"upload.album.select" xdata:nil];
}


- (void) setupNavigationBar
{    
    //MLOG(@"super SelectAlbumViewController: view.frame: x:%f y:%f width:%f height:%f", super.view.frame.origin.x,super.view.frame.origin.y,super.view.frame.size.width, super.view.frame.size.height);
    //MLOG(@"SelectAlbumViewController: view.frame: x:%f y:%f width:%f height:%f", self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height);

    
    self.navigationController.navigationBarHidden = NO;
    
    
    // nav bar
    [self useDefaultNavigationBarStyle];
    self.title = NSLocalizedString( @"Select Album",@"Navigation Bar Title when selecting an album for upload");
    [self useCustomBackButton:@"Back" target:self action:@selector(goBack:)];
    [self useGreenRightButton:NSLocalizedString( @"New Album", @"New Album button label from album selector") 
                       target:self 
                       action:@selector(newAlbumAction:)];
        
    
    NSDictionary *albumselectdef = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"All", @"My", @"Liked", @"Invited", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(77,30)], @"size", @"segment.png", @"button-image", @"segment-selected.png", @"button-highlight-image", @"segment-separator.png", @"divider-image", [NSNumber numberWithFloat:11.0], @"cap-width", [UIColor blackColor], @"button-color", [UIColor blackColor], @"button-highlight-color", nil];
    
    albumsSelect = [[ZZSegmentedControl alloc] initWithSegmentCount:4 selectedSegment:1 segmentdef:albumselectdef tag:0 delegate:self];
    albumsSelect.frame = CGRectMake(5, 7, albumsSelect.frame.size.width, albumsSelect.frame.size.height);    // adjust location
    [albumsSelectHolder addSubview:albumsSelect];
    
    UIImageView *segmentBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment-background.png"]];
    [albumsSelectHolder insertSubview:segmentBackgroundImage atIndex:0];
    
    UIImageView *navDropShadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seg-nav-drop-shadow.png"]];
    navDropShadowImage.frame = CGRectMake(0, 0, navDropShadowImage.image.size.width, navDropShadowImage.image.size.height);
    [albumsSelectHolder insertSubview:navDropShadowImage atIndex:1];
    
    //MLOG(@"albumsSelectHolder view.frame: x:%f y:%f width:%f height:%f", albumsSelectHolder.frame.origin.x,albumsSelectHolder.frame.origin.y,albumsSelectHolder.frame.size.width, albumsSelectHolder.frame.size.height);

    //MLOG(@"albumsTable view.frame: x:%f y:%f width:%f height:%f", albumsTable.frame.origin.x,albumsTable.frame.origin.y,albumsTable.frame.size.width, albumsTable.frame.size.height);
    
    //MLOG(@"albumsTable super frame: x:%f y:%f width:%f height:%f", albumsTable.superview.frame.origin.x,albumsTable.superview.frame.origin.y,albumsTable.superview.frame.size.width, albumsTable.superview.frame.size.height);
}


-(void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    int pos = [indexPath indexAtPosition: 1];
    MLOG(@"SelectAlbumViewController: didSelectRowAtIndexPath: %d", pos);

    NSArray *myalbums = [gAlbums albumset:_userid type:_albumstype];
    NSNumber *index = [_myalbumaddindices objectAtIndex:pos];
    NSDictionary *albumdata = [myalbums objectAtIndex: [index intValue]];
    
    NSString *u;
    u= [albumdata valueForKey:@"id"];
    ZZAlbumID albumid = [u longLongValue];
    u= [albumdata valueForKey:@"user_id"];
    ZZUserID userid = [u longLongValue];
    NSString *albumname = [albumdata valueForKey:@"name"];

    [ZZGlobal trackEvent:@"album.select" xdata:nil];
    
    [delegate selectedAlbum:userid albumid:albumid albumName:albumname];
}


-(void)goBack:(id)sender
{
    [delegate cancelAlbumSelect];
}

#pragma mark NewAlbumViewController methods
// New Album button action
-(void)newAlbumAction:(id)sender
{
    NewAlbumViewController *newAlbumViewController = [[NewAlbumViewController alloc] initWithNewAlbum];
    [newAlbumViewController setNewAlbumViewDelegate:self];
    
    //Create new Nav Controller for New Album
    UINib *nib = [UINib nibWithNibName:@"NavController" bundle:nil]; 
    UINavigationController *newAlbumNavController = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [newAlbumNavController setViewControllers:[NSArray arrayWithObject:newAlbumViewController]];
    [self presentModalViewController:newAlbumNavController animated:YES];
}

 //Called whenever newAlbum process is canceled
-(void)newAlbumCreationCanceled
{
    [self dismissModalViewControllerAnimated:YES];   
}
-(void)newAlbumCreated:(ZZAlbum *)newAlbum
{
    [self dismissModalViewControllerAnimated:YES];
    [delegate uploadToSelectedAlbum:newAlbum];
}



-(BOOL)canAdd:(NSDictionary*)albumdata
{
    NSString *u = [albumdata objectForKey:@"user_id"];
    ZZUserID userid = [u longLongValue];
    if (userid == [ZZSession currentUser].user_id)
        return YES;
    
    NSString *role = [albumdata objectForKey:@"my_role"];
    if (role && [role isKindOfClass:[NSString class]] && [role isEqualToString:ZZAPI_ALBUM_PERMISSION_CONTRIB])      
        return YES;
    
    NSNumber *all_can_contrib = [albumdata objectForKey:@"all_can_contrib"];
    if (all_can_contrib && [all_can_contrib isKindOfClass:[NSString class]]) {
        BOOL can = [all_can_contrib boolValue];
        if (can)
            return YES;
    }
        
    return NO;
}


-(BOOL)canAddLiked:(NSDictionary*)albumdata
{
    // for liked albums, test the user_id and all_can_contrib flag
    // if they don't pass, dig up the album in 'invited' list and test it
    
    NSString *u = [albumdata objectForKey:@"user_id"];
    ZZUserID userid = [u longLongValue];
    if (userid == [ZZSession currentUser].user_id)
        return YES;
    
    NSNumber *all_can_contrib = [albumdata objectForKey:@"all_can_contrib"];
    if (all_can_contrib && [all_can_contrib isKindOfClass:[NSString class]]) {
        BOOL can = [all_can_contrib boolValue];
        if (can)
            return YES;
    }
    
    NSString *a = [albumdata objectForKey:@"id"];
    ZZUserID albumid = [a longLongValue];
    
    // find album in 'invited' list and test it
    NSArray *invitedalbums = [gAlbums albumset:_userid type:@"invited"];
    if (invitedalbums) {
        for (int i = 0; i < invitedalbums.count; i++) {
            NSDictionary *likedalbumdata = [invitedalbums objectAtIndex: i];
            NSString *la = [likedalbumdata objectForKey:@"id"];
            ZZUserID likedalbumid = [la longLongValue];
            
            if (likedalbumid == albumid) {
                return [self canAdd:likedalbumdata];
            }
        }
    }
    
    return NO;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    int rows = 0;
    
    _myalbumaddindices = [[NSMutableArray alloc]init];
    
    NSArray *myalbums = [gAlbums albumset:_userid type:_albumstype];
    if (myalbums) {
        for (int i = 0; i < myalbums.count; i++) {
            NSDictionary *albumdata = [myalbums objectAtIndex: i];
            
            if ([_albumstype isEqualToString:@"liked"]) {
                
                if ([self canAddLiked:albumdata]) {
                    rows++;
                    [_myalbumaddindices addObject:[NSNumber numberWithInt:i]];
                }                
            } else {
                
                if ([self canAdd:albumdata]) {
                    rows++;
                    [_myalbumaddindices addObject:[NSNumber numberWithInt:i]];
                }
            }
        }
    }
            
    MLOG(@"SelectAlbumViewController: numberOfRowsInSection: %d", rows);
    
    return rows;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
#define nTitle 1		// name
#define nBy 2           // by
#define nImage 3		// image
#define nUpdated 4      // updated (ago)
#define nCounts 5       // counts
    
    //int x;
    //int y;
    //int height;
    //int width;
    
    int pos = [indexPath indexAtPosition: 1];
    //MLOG(@"SelectAlbumViewController: cellForRowAtIndexPath: %d", pos);
    
    //NSString *cellIdentifier = [NSString stringWithFormat: @"s%d:%d", [ indexPath indexAtPosition: 0 ], [ indexPath indexAtPosition:1 ]];
    //MLOG(@"AlbumsViewController:  cellForRowAtIndexPath: %@", cellIdentifier);
    
    NSArray *myalbums = [gAlbums albumset:_userid type:_albumstype];
    NSNumber *index = [_myalbumaddindices objectAtIndex:pos];
    NSDictionary *albumdata = [myalbums objectAtIndex: [index intValue]];
    
    //NSString *albumname = [albumdata valueForKey:@"name"];
    //NSString *albumcover = [albumdata objectForKey:@"c_url"];
    
    //NSString *u = [albumdata valueForKey:@"user_id"];
    //ZZUserID userid = [u longLongValue];
    //NSString *by = [gUserInfo getUserDisplayNameOrMe:userid];
    //NSNumber *photos_ready_count = [albumdata valueForKey:@"photos_ready_count"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"album"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"album"];
    } else {
        for (UIView *view in cell.contentView.subviews) {
            
            // kill active downloads
            if ([view isKindOfClass:[UIImageView class]]) {
                UIImageView *albumimage = (UIImageView*)view;
                [albumimage cancelCurrentImageLoad];
            }
            [view removeFromSuperview];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [UIFactory setAlbumsCell:albumdata cell:cell withDisclosure:NO];
    
    return cell;
}


-(void)touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    switch (segmentIndex) {
        case 0:
            // all albums
            MLOG(@"switching to 'all' albums");
            _albumstype = @"all";            
            break;            
            
        case 1:
            // my albums
            MLOG(@"switching to 'my' albums");
            _albumstype = @"my";
            break;
            
        case 2:
            // liked albums
            MLOG(@"switching to 'liked' albums");
            _albumstype = @"liked";
            break;
            
        case 3:
            // invited albums
            MLOG(@"switching to 'invited' albums");
            _albumstype = @"invited";
            break;   
            
        default:
            break;
    }
    
    [albumsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [albumsTable reloadData];    
}


-(void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}




@end
