//
//  NewAlbumViewController.m
//  ZangZing
//
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zzglobal.h"
#import "albums.h"
#import "photouploader.h"
#import "ZZAlbumPrivacySelector.h"
#import "ZZAPI.h"
#import "UIFactory.h"
#import "NewAlbumViewController.h"
#import "AlbumSettingsViewController.h"
#import "ZZAlbumShareTable.h"
#import "FacebookSessionController.h"



//Privacy Segemented Controller constants
static const NSInteger kAlbumPublicSegment   = 0;
static const NSInteger kAlbumHiddenSegment   = 1;
static const NSInteger kAlbumPasswordSegment = 2;


@implementation NewAlbumViewController

// UI Outlets
@synthesize albumShare=_albumShare;
@synthesize namePrivacy=_namePrivacy;

// Model ivars
@synthesize name=_name;
@synthesize privacy=_privacy;
@synthesize note=_note;
@synthesize facebookStreaming=_facebook;
@synthesize twitterStreaming=_twitter;
@synthesize whoCanDownload;
@synthesize whoCanUpload;
@synthesize whoCanBuy;

//To create a new album
- (id)initWithNewAlbum
{
    self = [super initWithNibName:@"NewAlbum" bundle:nil];
    if (self) {
        //DEFAULT VALUES FOR NEW ALBUMS
        editMode                = NO;
        self.name               = @"";
        _privacy                = kPublic;
        self.note               = @"";
        self.facebookStreaming  = NO;
        self.twitterStreaming   = NO;
        self.whoCanUpload       = kContributors;
        self.whoCanDownload     = kEveryone;
        self.whoCanBuy          = kEveryone;
    }
    return self;       
}

//To Edit an existing album
-(id)initWithExistingAlbum
{
    self = [super initWithNibName:@"NewAlbum" bundle:nil];
    if (self) {
        //Load existing album values onto view
        editMode            = YES;    
        self.name           = @"Existing Album Name";
        _privacy            = kHidden;
        self.whoCanUpload   = kContributors;
        self.whoCanDownload = kEveryone;
        self.whoCanBuy      = kOwner;
    }
    return self;    
}


- (void) setNewAlbumViewDelegate: (NSObject <NewAlbumViewControllerDelegate> *) theDelegate
{
    _newAlbumViewDelegate = theDelegate;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self useDefaultNavigationBarStyle];
    // Add custom "Cancel" Back Button  with default cancel action (it will pop view)
    [self useGrayCancelRightButton:self action:@selector(cancelNewAlbum:)];
    [self setBackgroundImage:[gPhotoUploader lastPhotoScreenSize]];
   
  
    // Create custom AlbumPrivacy Selector and album name text field 
    // to be used in the namePrivacy table from xib
    // We set it up here so we can initialize it with the album and 
    // register an action to receive events. The table delegate methods
    // will use _privacySelector to build the right cell
    _privacySelector = [[ZZAlbumPrivacySelector alloc]initWithAlbumPrivacy:self.privacy]; 
    [_privacySelector addTarget:self action:@selector(privacyChanged:) forControlEvents:UIControlEventTouchDown]; //register to receive events

    _albumName = [[UITextField alloc] initWithFrame:CGRectMake( 10, 0, 280, 44)];
    _albumName.font = [UIFont boldSystemFontOfSize:16.0];
    _albumName.adjustsFontSizeToFitWidth = NO;
    _albumName.backgroundColor = [UIColor clearColor];
    _albumName.autocorrectionType = UITextAutocorrectionTypeNo;
    _albumName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _albumName.textAlignment = UITextAlignmentLeft;
    _albumName.keyboardType = UIKeyboardTypeDefault;
    _albumName.returnKeyType = UIReturnKeyDone;
    _albumName.clearButtonMode =  UITextFieldViewModeWhileEditing;
    _albumName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _albumName.placeholder = NSLocalizedString(ALBUM_NAME_PROMPT, @"Prompt to enter album name in new album screen");
    _albumName.delegate = self;
    _namePrivacy.separatorStyle = UITableViewCellSeparatorStyleNone;
    _namePrivacy.scrollEnabled = NO;
    _namePrivacy.backgroundColor = [UIColor clearColor];
    
    //Setup VIew according to mode    
    if( editMode ){
        //EDIT MODE
        self.title          = self.name;
        _albumName.text      = self.name;
        self.privacy        = _privacy; //Force the setter to setup the UI
        //Hide share note from album share table
    }else{
        //NEW ALBUM
        self.title          = @"New Album";
        self.privacy        = _privacy; //Force the setter to setup the UI
        //show share note
        //Add green button at the end
        UIButton *createButton = [UIFactory screenWideGreenButton: NSLocalizedString(@"Create and Upload",@"New Album View Create and Upload Green Button") 
                                                            frame:CGRectMake(9, 368, 302, 44)];
        [createButton addTarget:self action:@selector(saveAlbum:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:createButton];

    }
    
    _sharePeople = [[NSArray alloc]init];
    _shareGroups = [[NSArray alloc]init];
    
    _zzasTable= [[ZZAlbumShareTable alloc] initWithStyle:ZZAlbumShareTableWithSettingsStyle frame: CGRectMake( 0, 133, 0, 0 )];

    [_zzasTable setZZAlbumShareTableDelegate: self];                                                                                                                       
    [self.view addSubview:_zzasTable];
    [_albumName becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == _namePrivacy){
        return 2;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CGFloat height = 44.0;
    if( tableView == _namePrivacy){
        switch( indexPath.row){
            case 0:
                break;
            case 1:
                return _privacySelector.frame.size.height+20;
                break;
        }
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if( tableView == _namePrivacy){
        switch( indexPath.row){
            case 0:
                [cell.contentView addSubview:_albumName];
                break;
            case 1:
                [cell.contentView addSubview:_privacySelector];
                break;
        }
        return cell;
    }
    
    return NULL;
}

#pragma mark AlbumName TextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{    
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    _name = textField.text;
    MLOG( @"Album Name set to %@",_name );
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_albumName resignFirstResponder];
    return YES;
}

//This action is fired when the user taps outside the keyboard and then we hide it
- (IBAction)backgroundTap:(id)sender
{
    [_albumName resignFirstResponder];
}

#pragma mark WhoOptions View Delegate
// WhoOptionsDelegate implementation.
// whenever a user changes the who options on an album,
// the model is changed here
- (void)didChangeWhoOption:(WhoOptionsViewStyle)style whoOption:(ZZAPIAlbumWhoOption)option
{
    switch( style ){        
        case WhoOptionsViewUploadStyle:
            self.whoCanUpload = option;
            break;
        case WhoOptionsViewDownloadStyle:
            self.whoCanDownload = option;
            break;
        default:
        case WhoOptionsViewBuyStyle:
            self.whoCanBuy = option;
            break;            
    }
}

// Fired when done button is pressed
- (IBAction)cancelNewAlbum:(id)sender
{
    if( _newAlbumViewDelegate && [_newAlbumViewDelegate respondsToSelector:@selector(newAlbumCreationCanceled)] ){
        [ _newAlbumViewDelegate newAlbumCreationCanceled];
    }
}

// Fired when done button is pressed
- (IBAction)saveAlbum:(id)sender
{
    MLOG( @"Album Ready To Save {\n\tname=>%@,\n\t privacy=>%i,\n\t share_msg=>%@,\n\t groups=>%@,\n\t facebook=>%@,\n\t twitter=>%@,\n\t whoDownload=>%i,\n\t whoUpload=>%i,\n\t whoBuy=> %i\n}", 
         self.name, 
         self.privacy, 
         self.note,
         _zzasTable.emailCellDetailText,
         (self.facebookStreaming ? @"YES": @"NO"),
         (self.twitterStreaming ? @"YES" : @"NO"),
         self.whoCanDownload, 
         self.whoCanUpload, 
         self.whoCanBuy );  
    
    //TODO:Check if there is a network connection
    
    //Validate Album Fields
    if( self.name.length <=0 ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Album Name", @"Error alert-box title when album name is null or not valid")
                                                        message: NSLocalizedString(@"Your album must have a name.", @"Error message when trying to create a new album wihtout a name") 
                                                      delegate:nil 
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }else{
        //All validations passed, time to create the album
        NSError *anError = nil;
        ZZAlbum *newAlbum = [ZZAlbum albumWithName: self.name 
                                           privacy: self.privacy 
                                 facebookStreaming:self.facebookStreaming
                                  twitterStreaming:self.twitterStreaming 
                                    whoCanDownload: self.whoCanDownload 
                                      whoCanUpload: self.whoCanUpload 
                                         whoCanBuy: self.whoCanBuy
                                             error: &anError];
        if( newAlbum == nil ){
            MLOG( @"New Album creation Failed with error %@", [anError localizedDescription] );
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [anError localizedDescription]
                                                            message: [anError localizedFailureReason]
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        }else{
            MLOG(@"New Album was created");
            
            if (_sharePeople.count > 0 || _shareGroups.count > 0) {
                _albumShareList = [[ZZShareList alloc]initWithAlbumID:newAlbum.album_id];
                [_albumShareList setMembers:_sharePeople groups:_shareGroups];
            }
            
            //If the group add was successful then call the delegate
            [gAlbums refreshalbumsets:newAlbum.user_id];
            if( _newAlbumViewDelegate && [_newAlbumViewDelegate respondsToSelector:@selector(newAlbumCreated:)] ){
                [ _newAlbumViewDelegate newAlbumCreated:newAlbum];
            }
        }
    }
}

#pragma mark PrivacySelector Methods

// Privacy setter, saves the privacy and updates the privacy
// tagline to reflect the new selection
- (void) setPrivacy:(ZZAPIAlbumPrivacy)newPrivacy
{
    _privacy = newPrivacy;
    if( _privacySelector ){
        _privacySelector.privacy = newPrivacy;
    }
}

// This action is fired when the privacy segmented controller changes value
- (IBAction)privacyChanged:(id)sender
{ 
    [_albumName resignFirstResponder];
    _privacy = [sender privacy];
    MLOG( @"NewAlbumView Controller Received privacyChanged with privacy = %i",_privacy );
    
}

#pragma mark ZZAlbumShareTable action methods
-(void)shareMessageChanged:(UITextField *)shareMessage
{
    _note = shareMessage.text;
}

-(void)emailCellSelected:(UITableViewCell *)emailCell
{
    ShareListViewController *sharelistVC = [[ShareListViewController alloc] initWithNibName:@"ShareList" bundle:[NSBundle mainBundle]];
    [sharelistVC setDelegate:self];
    [sharelistVC setShareList:YES people:_sharePeople groups:_shareGroups];
    [self.navigationController pushViewController:sharelistVC animated:YES];
}

-(void)facebookSwitchChanged:(UISwitch *)facebookSwitch
{
    _facebook = facebookSwitch.isOn;
}


-(void)twitterSwitchChanged:(UISwitch *)twitterSwitch
{
#ifdef DEBUG
    _twitter = twitterSwitch.isOn;
#else
    if( twitterSwitch.isOn ){
        [self showUnderConstructionAlert];
        [twitterSwitch setOn: NO];
    }
#endif

}
-(void)settingsCellSelected:(UITableViewCell *)settingsCell
{
    if( _settingsController == nil){ 
        _settingsController                  = [[AlbumSettingsViewController alloc] initWithNibName:@"AlbumSettings" bundle:nil];
        _settingsController.delegate         = self;
    }
    [self.navigationController pushViewController:_settingsController animated:YES]; 
}

#pragma mark ShareListViewControllerDelegate method
-(void)shareListComplete:(NSArray*)people groups:(NSArray*)groups
{
    _sharePeople = people;
    _shareGroups = groups;
        
    [_zzasTable setGroupDescription:_shareGroups people:_sharePeople];
    
    [self.navigationController popViewControllerAnimated:YES];    
}


@end
