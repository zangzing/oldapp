//
//  NewAlbumViewController.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/18/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZBaseViewController.h"
#import "AlbumSettingsViewController.h"
#import "WhoOptionsViewController.h"
#import "ZZAlbumPrivacySelector.h"
#import "ZZAlbumShareTable.h"
#import "ShareListViewcontroller.h"


// Implement this protocol to be notified of changes to the table
@protocol NewAlbumViewControllerDelegate
@required
-(void)newAlbumCreationCanceled;                //Called whenever newAlbum process is canceled
-(void)newAlbumCreated:(ZZAlbum *)newAlbum;     //Called when a new album has successfully been created
@end


#ifndef ALBUM_NAME_PROMPT 
#define ALBUM_NAME_PROMPT @"Album Name"
#define SHARE_NOTE_PROMPT @"Add note about the album..."
#endif



@interface NewAlbumViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  
WhoOptionsViewDelegate, ZZAlbumShareTableDelegate, ShareListViewControllerDelegate> {
 
    //Delegate
    NSObject <NewAlbumViewControllerDelegate> *_newAlbumViewDelegate;
     
    // These are for the album name and  privacy group
    UITableView *_namePrivacy;
    UITextField *_albumName;
    ZZAlbumPrivacySelector *_privacySelector;
    
    
    // Album share table
    ZZAlbumShareTable *_zzasTable;
    
    //Album Settings
    AlbumSettingsViewController *_settingsController;
    
    // These iVars are the album model
    BOOL editMode;
    NSString *_name;
    ZZAPIAlbumPrivacy _privacy;    
    NSString *_note;
    NSArray *_shareGroups;
    NSArray *_sharePeople;
    ZZShareList *_albumShareList;
    BOOL _facebook;
    BOOL _twitter;
    ZZAPIAlbumWhoOption whoCanDownload;
    ZZAPIAlbumWhoOption whoCanUpload;
    ZZAPIAlbumWhoOption whoCanBuy;        
}

@property (atomic, retain) IBOutlet  UITableView *namePrivacy;
@property (atomic, retain) IBOutlet  UITableView *albumShare;

@property (nonatomic, retain) NSString *name;
@property (nonatomic) ZZAPIAlbumPrivacy privacy;
@property (nonatomic, retain) NSString *note;
@property (nonatomic) BOOL facebookStreaming;
@property (nonatomic) BOOL twitterStreaming;
@property (nonatomic) ZZAPIAlbumWhoOption whoCanDownload;
@property (nonatomic) ZZAPIAlbumWhoOption whoCanUpload;
@property (nonatomic) ZZAPIAlbumWhoOption whoCanBuy;


- (id) initWithNewAlbum;  //Used to create new albums
- (id) initWithExistingAlbum; //USed to edit existing albums
- (void) setNewAlbumViewDelegate: (NSObject <NewAlbumViewControllerDelegate> *) theDelegate;

- (IBAction) privacyChanged:(id)sender;
- (IBAction) backgroundTap:(id)sender;
- (IBAction) saveAlbum:(id)sender;
@end
