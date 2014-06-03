//
//  ZZAlbumShareTable.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 2/13/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZAlbumShareTable.h"
#import "zzglobal.h"

@implementation ZZAlbumShareTable

@synthesize offsetWhenEditingShareMessage=_offsetWhenEditingShareMessage;

//Array with the heights for each style
static int styleHeights[] ={
                     ZZAST_HEIGHT_DEFAULT,
                     ZZAST_HEIGHT_WITHOUT_MSG,
                     ZZAST_HEIGHT_WITH_SETTINGS,
                     ZZAST_HEIGHT_WO_MSG_WITH_SETTINGS
};

//Array with cell types per style
static int rowStyles[4][5]={
    {ZZAlbumShareTableMessageRowStyle, ZZAlbumShareTableEmailRowStyle,    ZZAlbumShareTableFacebookRowStyle, ZZAlbumShareTableTwitterRowStyle, -1 }, // +msg -settings
    {ZZAlbumShareTableEmailRowStyle,   ZZAlbumShareTableFacebookRowStyle, ZZAlbumShareTableTwitterRowStyle,  -1, -1 },                               // -msg -settings
    {ZZAlbumShareTableMessageRowStyle, ZZAlbumShareTableEmailRowStyle,    ZZAlbumShareTableFacebookRowStyle, ZZAlbumShareTableTwitterRowStyle, ZZAlbumShareTableSettingsRowStyle }, // +msg +settings
    {ZZAlbumShareTableEmailRowStyle,   ZZAlbumShareTableFacebookRowStyle, ZZAlbumShareTableTwitterRowStyle,  ZZAlbumShareTableSettingsRowStyle, -1 }, // -msg +settings
};

-(id) initWithStyle:(ZZAlbumShareTableStyle)style frame:(CGRect)theFrame
{
    _ZZASTStyle = style;
    
    CGRect newFrame;
    //calculate the table size and modify the size for the given frame
    newFrame = theFrame;
    newFrame.size = CGSizeMake(ZZAST_WIDTH, styleHeights[style]+20);
    
    _offsetWhenEditingShareMessage = 5;
    
    if (self = [super initWithFrame:newFrame style:UITableViewStyleGrouped]) {
        // This is the "Trick", set the delegates to self.
        self.dataSource = self;
        self.delegate = self;  
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = NO;
        
        // Instantiate table UIControls
    
        // setup share message editor if the style needs it        
        if( _ZZASTStyle == ZZAlbumShareTableDefaultStyle || _ZZASTStyle == ZZAlbumShareTableWithSettingsStyle){    
            _shareMessageTextField  = [[UITextField alloc]initWithFrame:CGRectMake(0,0,0,0)];
            _shareMessageTextField.borderStyle = UITextBorderStyleRoundedRect;
            _shareMessageTextField.textColor = [UIColor blackColor]; 
            _shareMessageTextField.font = [UIFont systemFontOfSize:16];  
            _shareMessageTextField.placeholder = @"Add a share message...";  
            _shareMessageTextField.backgroundColor = [UIColor clearColor]; 
            _shareMessageTextField.autocorrectionType = UITextAutocorrectionTypeNo;	
            _shareMessageTextField.keyboardType = UIKeyboardTypeDefault;  
            _shareMessageTextField.returnKeyType = UIReturnKeyDone; 
            _shareMessageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _shareMessageTextField.delegate = self;	
        }
        
        // setup the facebook switch
        _facebookSwitch = [[UISwitch alloc]initWithFrame:CGRectZero];
        [_facebookSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        
        //setup the twitte switch
        _twitterSwitch = [[UISwitch alloc]initWithFrame:CGRectZero];
        [_twitterSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = @"Email";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;  
        _emailCell = cell;
        
        return self;
    }    
    return NULL;
}

-(void) setZZAlbumShareTableDelegate:(NSObject <ZZAlbumShareTableDelegate> *)delegate{
    _ZZASTDelegate = delegate;
}
#pragma mark Table View Delegates

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;    
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {  
    switch (_ZZASTStyle){
        case ZZAlbumShareTableDefaultStyle: 
            return 4;
        case ZZAlbumShareTableWithoutMessageStyle:
            return 3;
        case ZZAlbumShareTableWithSettingsStyle:
            return 5;
        case ZZAlbumShareTableWithoutMessageWithSettingsStyle:
            return 4;
    }
} 

- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Find out what style of row we have from the style and the row index
    // We search for the style in a 2D array defined at the top of this file.
    ZZAlbumShareTableRowStyle rowStyle = rowStyles[ _ZZASTStyle ][indexPath.row];

    
    UITableViewCell *cell;
    
    //produce the appropriate cell style
    switch (rowStyle) {        
        case ZZAlbumShareTableMessageRowStyle:
            cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];            
            _shareMessageTextField.frame = CGRectMake(11, 7, 278, 29);
            [cell.contentView addSubview:_shareMessageTextField];            
            //cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;  
            break;            
            
        case ZZAlbumShareTableEmailRowStyle:
            cell = _emailCell;
            break;
        
        case ZZAlbumShareTableFacebookRowStyle:
            cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
            cell.textLabel.text = @"Facebook";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];            
            cell.selectionStyle = UITableViewCellSelectionStyleNone; 
            CGRect fbFrame = _facebookSwitch.frame;
            _facebookSwitch.frame = CGRectMake(cell.frame.size.width - fbFrame.size.width - 25, 8,
                                               fbFrame.size.width, fbFrame.size.height);
            [cell.contentView addSubview:_facebookSwitch];
            break;            

        case ZZAlbumShareTableTwitterRowStyle:
            cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
            cell.textLabel.text = @"Twitter";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect tFrame = _twitterSwitch.frame;
            _twitterSwitch.frame = CGRectMake(cell.frame.size.width - tFrame.size.width - 25, 8, 
                                              tFrame.size.width, tFrame.size.height);
            [cell.contentView addSubview:_twitterSwitch];
            break;
            
        case ZZAlbumShareTableSettingsRowStyle:
            cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
            cell.textLabel.text = NSLocalizedString( @"Settings", @"Album Share Table Settings Cell Label");
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];            
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            _settingsCell = cell;
            break;            
            
        default:
            [NSException raise:@"Invalid ZZAlbumShareTableRowStyle" 
                        format:@"RowStyle %i is not a supported style", rowStyle];
            break;
    }    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Cancel share message editing 
    [_shareMessageTextField resignFirstResponder]; 
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if( selectedCell == _emailCell){
        if( [_ZZASTDelegate respondsToSelector:@selector(emailCellSelected:) ] ){
            [_ZZASTDelegate emailCellSelected:_emailCell];
        }        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if( selectedCell == _settingsCell){
        if( [_ZZASTDelegate respondsToSelector:@selector(settingsCellSelected:) ] ){
            [_ZZASTDelegate settingsCellSelected:_settingsCell];
        }                
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }        
}

#pragma mark share Message TextField View Delegates

// Scroll the whole view up so that the Message field is at the top
// save the original location of the ZZAStable so we can return it there
- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    if( textField == _shareMessageTextField ){
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: ZZAST_MOVEMENT_DURATION ];
        
        _origin = self.frame.origin; //save original location
        self.superview.frame = CGRectOffset(self.superview.frame, 0, (self.frame.origin.y+_offsetWhenEditingShareMessage)*-1);
        [UIView commitAnimations];
    }
}

// Animate the view to return the ZZAStable back to its original location and
// save the changes
- (void)textFieldDidEndEditing:(UITextField*)textField
{
    if( textField == _shareMessageTextField ){
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: ZZAST_MOVEMENT_DURATION ];
        self.superview.frame = CGRectOffset(self.superview.frame, 0, _origin.y+_offsetWhenEditingShareMessage);
        [UIView commitAnimations];
        if( [_ZZASTDelegate respondsToSelector:@selector(shareMessageChanged:) ] ){
            [_ZZASTDelegate shareMessageChanged:_shareMessageTextField];
        }
    }
}

// Resign first responder whenever you click the keyboard done button
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_shareMessageTextField resignFirstResponder];
    return YES;
}
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}
#pragma mark property setters getters
-(NSString *)emailCellDetailText
{
    return _emailCell.detailTextLabel.text;
}
-(void)setEmailCellDetailText:(NSString *)detailText
{
    _emailCell.detailTextLabel.text = detailText;
}
-(NSString *)shareMessage
{
    return _shareMessageTextField.text;
}
-(void)setShareMessage:(NSString *)newMsg;
{
    _shareMessageTextField.text = newMsg;
}

-(BOOL)facebook
{
    return _facebookSwitch.on;
}
-(void)setFacebook:(BOOL)isOn
{
    _facebookSwitch.on = isOn;
}
-(BOOL)twitter
{
    return _twitterSwitch.on;
}
-(void)setTwitter:(BOOL)isOn
{
    _twitterSwitch.on = isOn;
}

#pragma mark UISwitch event listeners

-(void) switchChanged:(UISwitch*)sender
{
    [_shareMessageTextField resignFirstResponder]; 
    if( sender == _facebookSwitch ){
        
        if( _facebookSwitch.isOn ){
            if( [FacebookSessionController sharedController].authorized == NO ){
                // These are OBJ-C BLOCKS you can read about them here: http://thirdcog.eu/pwcblocks/
                // they are just like javascript closures
                [_facebookSwitch setOn: NO];
                [[FacebookSessionController sharedController] authorizeSessionWithSuccessBlock:^{ 
                     // Notify controller of switch position change
                     MLOG(@"Facebook Session Authorized, ZZAlbumShareTable notifying controller of change");
                     [_facebookSwitch setOn: YES];
                     if( [_ZZASTDelegate respondsToSelector:@selector(facebookSwitchChanged:) ] ){
                         [_ZZASTDelegate facebookSwitchChanged:_facebookSwitch];
                     }   
                 } 
                 onFailure:^{
                     // User denied access to FB account, set switch to NO no need to notify controller
                     MLOG(@"Facebook Session NOT Authorized, ZZAlbumShareTable resetting button to OFF");                     
                     [[[UIAlertView alloc] initWithTitle:@"Facebook" 
                                                 message: NSLocalizedString( @"We need your authorization to share on Facebook. Please try again.", @"Error message when user did not authorize access to FB account")
                                                delegate:self 
                                       cancelButtonTitle:@"OK" 
                                       otherButtonTitles:nil] show];
                     [_facebookSwitch setOn: NO];
                 }
                 ];
            }else{
                //User already has valid credentials
                [_facebookSwitch setOn: YES];
                if( [_ZZASTDelegate respondsToSelector:@selector(facebookSwitchChanged:) ] ){
                    [_ZZASTDelegate facebookSwitchChanged:_facebookSwitch];
                }
            }
        }else{
            //user not logged in set switch to NO no need to notify controller
            [_facebookSwitch setOn: NO];        
        }
    } else if( sender == _twitterSwitch ){
        if( [_ZZASTDelegate respondsToSelector:@selector(twitterSwitchChanged:) ] ){
            [_ZZASTDelegate twitterSwitchChanged:_twitterSwitch];
        }   
    }
}

// Creates the string that goes in the email cell whenever you have chosen groups
// the string looks like "3 People & 2 Groups"
//
-(void) setGroupDescription:(NSArray *)shareGroups people:(NSArray *) sharePeople
{
    NSString *description = @"";
    
    NSString* people;
    if (sharePeople && sharePeople.count > 0) {
        
        int peoplecount = sharePeople.count;
        
        if (peoplecount > 0) {
            if (peoplecount == 1)
                people = @"1 Person";
            else
                people = [NSString stringWithFormat:@"%d People", peoplecount];
        }
    }
    
    NSString* groups;
    if (shareGroups && shareGroups.count > 0) {
        
        int groupcount = shareGroups.count;
        
        if (groupcount > 0) {
            if (groupcount == 1)
                groups = @"1 Group";
            else
                groups = [NSString stringWithFormat:@"%d Groups", groupcount];
        }
    }
    
    if (people || groups) {
        if (people && groups)
            description =  [NSString stringWithFormat:@"%@ & %@", people, groups];
        else if (people) 
            description =  people;
        else
            description = groups;
    }
    
    _emailCell.detailTextLabel.text = description;
    [self reloadData];
}


-(NSDictionary*)getShareData
{
    BOOL facebook_share = _facebookSwitch.on;
    BOOL twitter_share = _twitterSwitch.on;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc]initWithCapacity:3];
    
    [data setValue:_shareMessageTextField.text forKey:@"message"];
    [data setValue:[NSNumber numberWithBool:facebook_share] forKey:@"facebook"];
    [data setValue:[NSNumber numberWithBool:twitter_share] forKey:@"twitter"];
    
    return data;
}

@end
