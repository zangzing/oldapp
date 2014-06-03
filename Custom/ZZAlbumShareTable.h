//
//  ZZAlbumShareTable.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 2/13/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef ZZALBUM_SHARE_TABLE_DEFINES
#define ZZALBUM_SHARE_TABLE_DEFINES
typedef enum{
    ZZAlbumShareTableDefaultStyle = 0,                       //With     message without settings
    ZZAlbumShareTableWithoutMessageStyle = 1,                //Without  message without settings
    ZZAlbumShareTableWithSettingsStyle = 2,                  //With     message with    settings
    ZZAlbumShareTableWithoutMessageWithSettingsStyle = 3     //Without  message with    settings
} ZZAlbumShareTableStyle;


typedef enum{
    ZZAlbumShareTableMessageRowStyle,
    ZZAlbumShareTableEmailRowStyle,
    ZZAlbumShareTableFacebookRowStyle,
    ZZAlbumShareTableTwitterRowStyle,
    ZZAlbumShareTableSettingsRowStyle
} ZZAlbumShareTableRowStyle;


// Table width
#define ZZAST_WIDTH                          320

// Table heights
#define ZZAST_ROW_HEIGHT                     44   
#define ZZAST_HEIGHT_DEFAULT                 ZZAST_ROW_HEIGHT*4
#define ZZAST_HEIGHT_WITHOUT_MSG             ZZAST_ROW_HEIGHT*3
#define ZZAST_HEIGHT_WITH_SETTINGS           ZZAST_ROW_HEIGHT*5   
#define ZZAST_HEIGHT_WO_MSG_WITH_SETTINGS    ZZAST_ROW_HEIGHT*4

//Animation duration
#define ZZAST_MOVEMENT_DURATION              0.3f

#endif


// Implement this protocol to be notified of changes to the table
@protocol ZZAlbumShareTableDelegate

@required

@optional
-(void)shareMessageChanged:(UITextField *)shareMessage;         //Called whenever the shareMessage textField DidFinishEditing
-(void)emailCellSelected:(UITableViewCell *)emailCell;          //Called when the emailCell is selected
-(void)facebookSwitchChanged:(UISwitch *)facebookSwitch;        //Called when the facebook switch is flicked on or off
-(void)twitterSwitchChanged:(UISwitch *)twitterSwitch;          //Called when the twitter switch is flicked on or off
-(void)settingsCellSelected:(UITableViewCell *)settingsCell;    //Called when the settings cell is selected
@end


@interface ZZAlbumShareTable : UITableView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
    NSObject <ZZAlbumShareTableDelegate> *_ZZASTDelegate;
    ZZAlbumShareTableStyle _ZZASTStyle;
    UITextField     *_shareMessageTextField;
    UITableViewCell *_emailCell;
    UISwitch        *_facebookSwitch;
    UISwitch        *_twitterSwitch;
    UITableViewCell *_settingsCell;
    
    int _offsetWhenEditingShareMessage;
    CGPoint _origin;
}

@property (nonatomic, retain) NSString *emailCellDetailText;  // Retrieve or set the auxilliary text on the email cell
@property (nonatomic, retain) NSString *shareMessage;         // The share message text field. Maybe null when the table style does not have a message
@property (nonatomic) BOOL facebook;                          // facebookSwitch.isOn
@property (nonatomic) BOOL twitter;                           // twitterSwitch.isOn
@property (nonatomic) int offsetWhenEditingShareMessage;      

-(id)   initWithStyle:(ZZAlbumShareTableStyle)style frame:(CGRect)frame;
-(void) setZZAlbumShareTableDelegate:(NSObject <ZZAlbumShareTableDelegate> *)delegate;
// Listen for switch change events
-(void) switchChanged:(UISwitch*)sender;
//Listen for table cells selected
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//convenience method to set the auxilliary text on email cell
-(void) setGroupDescription:(NSArray *)shareGroups people:(NSArray *) sharePeople;

-(NSDictionary*)getShareData;

@end
