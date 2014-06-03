//
//  SavePhotoViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 10/19/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//


#import "albums.h"
#import "photouploader.h"
#import "UIFactory.h"
#import "ZZLabel.h"
#import "ZZUINavigationBar.h"
#import "UIImageView+WebCache.h"
#import "SelectAlbumViewController.h"
#import "SavePhotoViewController.h"
#import "CameraViewController.h"
#import "ZZCache.h"

#define kRowHeight1                       78

@implementation SavePhotoViewController

@synthesize addButton;
@synthesize albumShare=_albumShare;
@synthesize albumselect;
@synthesize sharemessagecontainer;

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
    [self useDefaultNavigationBarStyle];

    
    _animateforedit = YES;

   [self setBackgroundImage: [gPhotoUploader lastPhotoScreenSize]]; 
     
    //Add large green "Upload Button" at the foot of the screen
    addButton = [UIFactory screenWideGreenButton: NSLocalizedString(@"Upload",@"SavePhotoVC Green-Upload-Button Label") 
                                                        frame:CGRectMake(9, 368, 302, 44)];
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];    
    [self.view addSubview:addButton];

    albumselect.tableHeaderView = nil;
    albumselect.tableFooterView = nil;
    albumselect.backgroundView = nil;
    albumselect.alpha = 1;
    albumselect.backgroundColor = [UIColor clearColor];
    albumselect.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _albumShare = [[ZZAlbumShareTable alloc] initWithStyle:ZZAlbumShareTableDefaultStyle frame: CGRectMake(0, 168, 0, 0)];
    [_albumShare setZZAlbumShareTableDelegate: self];   
    _albumShare.offsetWhenEditingShareMessage = 0;
    [self.view addSubview:_albumShare];

    BOOL set = NO;

    _setuserid = [ZZSession currentUser].user_id;

    if ([gAlbums getLastAlbumID] != 0) {
        // use last visited album
        
        // can we add to this album?
        BOOL canadd = [gAlbums canAdd:[gAlbums getLastAlbumUserID] albumid:[gAlbums getLastAlbumID]];
        if (canadd) {
            _setalbumid = [gAlbums getLastAlbumID];
            //_setuserid = [gAlbums getLastAlbumUserID];
            
            set = YES;
        }
    } 
    
    if (!set) {
        // use last saved album
        
        NSNumber *lastSelectedAlbumIDForSave = [gZZ numberForSetting:[ZZSession currentUser].user_id setting:@"lastSelectedAlbumIDForSave"];
        if (lastSelectedAlbumIDForSave) {
            //NSNumber *lastSelectedUserIDForSave = [gZZ numberForSetting:[gZZ loggedinuserid] setting:@"lastSelectedUserIDForSave"];
            
            _setalbumid = [lastSelectedAlbumIDForSave unsignedLongLongValue];
            //_setuserid = [lastSelectedUserIDForSave unsignedLongLongValue];
            
            set = YES;
        }
    }
    
    if (!set) {
        // pick first album in 'my'
        NSDictionary *albumdata = [gAlbums getAddable];
        if (albumdata) {
            NSNumber *a = [albumdata objectForKey:@"id"];        
            //NSString *u = [albumdata objectForKey:@"user_id"];
            
            _setalbumid = [a unsignedLongLongValue];
            //_setuserid = [u longLongValue];
        }
    }

    NSString *suffix = @"s";
    if ([gPhotoUploader photoCount] == 1) 
        suffix = @"";
    NSString *title = [NSString stringWithFormat:@"Upload %d Photo%@", [gPhotoUploader photoCount], suffix];
    self.title = title;
    
    [self useCustomBackButton:@"Back" target:self action:@selector(cancelButtonAction:)];
    
    [self setupSharing];
    [_albumShare setGroupDescription:_shareGroups people:_sharePeople];
}


-(void)setupSharing
{
    ZZSharePermission perm = [gAlbums sharePermission:_setuserid albumid:_setalbumid];
    
    if (perm == kShareAsAdmin) {
        
        _usingAlbumShareList = YES;
        _albumShareList = [[ZZShareList alloc]initWithAlbumID:_setalbumid];
        
        _sharePeople = _albumShareList.users;
        _shareGroups = _albumShareList.groups;
        
    } else {
        
        // for kShareAsContributor
        
        _usingAlbumShareList = NO;

        _sharePeople = [[NSArray alloc]init];
        _shareGroups = [[NSArray alloc]init];
    }    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(NSDictionary*)getShareData
{
    NSDictionary *data = [_albumShare getShareData];
    NSMutableDictionary *shareData = [[NSMutableDictionary alloc]initWithDictionary:data];
    
    NSMutableArray *viewers = [[NSMutableArray alloc]init];
    NSMutableArray *contributors = [[NSMutableArray alloc]init];
    
    for (ZZUser *user in _sharePeople) {
        if (_usingAlbumShareList && user.sharePermission == kShareAsContributor)
            [contributors addObject:user.my_group_id];
        else
            [viewers addObject:user.my_group_id];
    }
    
    for (ZZGroup *group in _shareGroups) {
        if (_usingAlbumShareList && group.sharePermission == kShareAsContributor)
            [contributors addObject:[NSNumber numberWithUnsignedLongLong:group.id]];
        else
            [viewers addObject:[NSNumber numberWithUnsignedLongLong:group.id]];
    }
    
    [shareData setValue:viewers forKey:@"viewers"];
    [shareData setValue:contributors forKey:@"contributors"];
    
    return shareData;
}

-(void)addButtonAction:(id)sender
{
    MLOG(@"addButtonAction");
    
    NSDictionary *shareData = [self getShareData];
    [delegate addPhotoAction:_setuserid albumid:_setalbumid shareData:shareData];
}


-(void)cancelButtonAction:(id)sender
{
    MLOG(@"cancelButtonAction");
    
    [delegate cancelPhotoAction];
}


- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int pos = [indexPath indexAtPosition: 1];

    if (tableView == albumselect) {
        switch (pos) {
            case 0:
                return 112.0;
                break;
                
            case 1:
                return 44.0;
                break;
        }
    }
    
    return 44.0;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    
    if (tableView == albumselect) {
        
        _selectAlbumVC = [[SelectAlbumViewController alloc] initWithNibName:@"SelectAlbumView" bundle:[NSBundle mainBundle]];
        [_selectAlbumVC setDelegate:self];
        [self.navigationController pushViewController:_selectAlbumVC animated:YES];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (tableView == albumselect)
        return 2;
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    int x,y,height,width;

    UITableViewCell *cell;
    int pos = [indexPath indexAtPosition: 1];

    if (tableView == albumselect) {
        
        // albumselect
        
        switch (pos) {
            case 0:
            {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;

                
                NSDictionary *albumdata = [gAlbums getAlbumData:[ZZSession currentUser].user_id albumid:_setalbumid];
                if (albumdata) {
                    NSString *albumname = [albumdata valueForKey:@"name"];
                    NSString *albumcover = NULL;
                    
                    NSObject *a = [albumdata objectForKey:@"cover_base"];
                    if (a && a != [NSNull null]) {
                        NSDictionary *photosizes = [albumdata objectForKey:@"cover_sizes"];
                        if (photosizes) {
                            NSString *photokey;
                            if ([gZZ isHiResScreen]) 
                                photokey = [photosizes objectForKey:@"iphone_cover_ret"];
                            else
                                photokey = [photosizes objectForKey:@"iphone_cover"];
                            albumcover = (NSString*)a;
                            albumcover = [albumcover stringByReplacingOccurrencesOfString:@"#{size}" withString:photokey];
                        }
                    } 
                    
                    if (!albumcover)
                        albumcover = [albumdata objectForKey:@"c_url"];
                
                    //NSNumber *updated_at = [albumdata valueForKey:@"updated_at"];
                    NSString *u = [albumdata valueForKey:@"user_id"];
                    ZZUserID userid = [u longLongValue];
                    NSString *by = [[ZZCache getCachedUser:userid] displayNameOrMe];
                    //NSNumber *photos_ready_count = [albumdata valueForKey:@"photos_ready_count"];
                    
                    
                    int frameleft = 10;
                    int frametop = 10;
                    //int framebottom = 5;
                    
                    // frame
                    UIImage *frameimage = [UIImage imageNamed:@"albums-frame-2.png"];
                    UIImageView *frameimageView = [[UIImageView alloc] initWithImage:frameimage];
                    frameimageView.frame = CGRectMake(frameleft,frametop,frameimage.size.width,frameimage.size.height); 
                    [cell.contentView addSubview:frameimageView];
                    
                    
                    int x_border = 5;
                    int y_border = 5;
                    int thumb_height = 82;
                    int thumb_width = 270;

                    
                    // thumbnail
                    x = x_border;
                    y = y_border;
                    height = thumb_height;
                    width = thumb_width;
                    
                    UIImageView *albumImage = NULL;
                    
                    albumImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
                    albumImage.frame = CGRectMake(x,y,width,height); 
                    albumImage.bounds = CGRectMake(0,0,width,height); 
                    albumImage.clipsToBounds = YES;
                    albumImage.contentMode = UIViewContentModeScaleAspectFill;
                    if (albumcover && [albumcover isKindOfClass:[NSString class]])        // albumcurl can be NSNull
                        [albumImage setImageWithURL_SD:[NSURL URLWithString:albumcover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                    [frameimageView addSubview:albumImage];
                    
                    
                    // overlay
                    x = 0;
                    y = thumb_height - 35;
                    height = 40;
                    width = thumb_width;
                    
                    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(x,y,width,height)];
                    [overlay setBackgroundColor:[UIColor colorWithRed: 0.0/255.0 green: 0.0/255.0 blue: 0.0/255.0 alpha: 0.6]];
                    [albumImage addSubview:overlay]; 
                    
                
                    // album name
                    x = 5;
                    y = 0;
                    height = 24;
                    width = 256;
                    
                    ZZUILabel *albumnameLabel = [[ZZUILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
                    y+=height;
                    albumnameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]; //[UIFont boldSystemFontOfSize:14];
                    [albumnameLabel setTextColor:[UIColor whiteColor]];  
                    [albumnameLabel setBackgroundColor:[UIColor clearColor]];
                    [overlay addSubview:albumnameLabel];
                    
                    albumnameLabel.text = albumname;
                    
                    // album owner  e.g., by Phil Beisel
                    if (by) {
                        x = 5;
                        y = 14;
                        height = 24;
                        width = 256;
                        
                        ZZUILabel *byLabel = [[ZZUILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
                        y+=height;
                        byLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
                        byLabel.textColor = [UIColor whiteColor];
                        [byLabel setBackgroundColor:[UIColor clearColor]];
                        
                        byLabel.text = [NSString stringWithFormat:@"by %@", by]; 
                        [overlay addSubview:byLabel];
                    }
                }
                
                return cell;   
            }
                break;
                
            case 1:
            {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
                cell.textLabel.text = @"Choose or Create New Album";
                cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;  
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                return cell;
            }
                break;
        }

    } 
    
    return NULL;
}

#pragma mark SelectAlbumViewControllerDelegate methods
- (void) uploadToSelectedAlbum:(ZZAlbum *)selectedAlbum
{
    [self.navigationController popViewControllerAnimated:YES];
    _selectAlbumVC = nil;
    
    _setalbumid = selectedAlbum.album_id;
    _setuserid = selectedAlbum.user_id;

    [gZZ setNumberForSetting:[ZZSession currentUser].user_id setting:@"lastSelectedAlbumIDForSave" value:[NSNumber numberWithUnsignedLongLong:_setalbumid]];
    [gZZ setNumberForSetting:[ZZSession currentUser].user_id setting:@"lastSelectedUserIDForSave" value:[NSNumber numberWithUnsignedLongLong:_setuserid]];
    [gZZ setStringForSetting:[ZZSession currentUser].user_id setting:@"lastSelectedAlbumNameForSave" value: selectedAlbum.name ];
    [gZZ saveSettings];
    
    [delegate addPhotoAction:_setuserid albumid:_setalbumid shareData:NULL];
}

- (void) selectedAlbum:(ZZUserID)userid albumid:(ZZAlbumID)albumid albumName:(NSString*)albumName
{ 
    [self.navigationController popViewControllerAnimated:YES];
    _selectAlbumVC = nil;
 
    _setalbumid = albumid;
    //_setuserid = userid;
    
    [gZZ setNumberForSetting:[ZZSession currentUser].user_id setting:@"lastSelectedAlbumIDForSave" value:[NSNumber numberWithUnsignedLongLong:_setalbumid]];
    [gZZ setNumberForSetting:[ZZSession currentUser].user_id setting:@"lastSelectedUserIDForSave" value:[NSNumber numberWithUnsignedLongLong:_setuserid]];
    [gZZ setStringForSetting:[ZZSession currentUser].user_id setting:@"lastSelectedAlbumNameForSave" value:albumName];
    [gZZ saveSettings];
    
    [self setupSharing];
    [_albumShare setGroupDescription:_shareGroups people:_sharePeople];

    [albumselect reloadData];
}


- (void) cancelAlbumSelect
{
    [self.navigationController popViewControllerAnimated:YES];
    _selectAlbumVC = nil;
}


-(void)emailCellSelected:(UITableViewCell *)emailCell
{
    ShareListViewController *sharelistVC = [[ShareListViewController alloc] initWithNibName:@"ShareList" bundle:[NSBundle mainBundle]];
    [sharelistVC setDelegate:self];
    [sharelistVC setShareList:_usingAlbumShareList people:_sharePeople groups:_shareGroups];
    [self.navigationController pushViewController:sharelistVC animated:YES];
}


-(void)shareListComplete:(NSArray*)people groups:(NSArray*)groups
{
    _sharePeople = people;
    _shareGroups = groups;
    
    [_albumShare setGroupDescription:_shareGroups people:_sharePeople];
    
    if (_usingAlbumShareList) {
        
        // commit people/groups to album share list
        [_albumShareList setMembers:people groups:groups];
    }
    
    [_albumShare setGroupDescription:_shareGroups people:_sharePeople];
    
    [self.navigationController popViewControllerAnimated:YES];    
}


-(void)facebookSwitchChanged:(UISwitch *)facebookSwitch
{
    //TODO SOMETHING WITH THE FACEBOOK SWITCH
    //facebookSwitch.isOn; this is a BOOL function that tells you if the switch is on or off
}

-(void)twitterSwitchChanged:(UISwitch *)twitterSwitch
{
#ifndef DEBUG
    if( twitterSwitch.isOn ){
        [self showUnderConstructionAlert];
        [twitterSwitch setOn: NO];
    }
#endif
    
}


@end
