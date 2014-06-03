//
//  ShareListViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 1/21/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zzglobal.h"
#import "UIFactory.h"
#import "ZZUINavigationBar.h"
#import "ShareListViewController.h"
#import "GroupEditViewController.h"
#import "SelectGroupViewController.h"
#import "EmailAddressViewController.h"
#import "NewPersonViewController.h"
#import "ABPeoplePickerNavigationController+ZZUINavigationBar.h"
#import "ZZSession.h"

#define kPeople_Section      0
#define kGroup_Section       1

@implementation ShareListViewController

@synthesize shareList=_shareList;
@synthesize addTableView=_addTableView;

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

    // nav bar
    [self useDefaultNavigationBarStyle];

    [self useCustomBackButton:@"Back" target:self action:@selector(backButtonAction:)];
    self.title = @"Email";
           
    _groups = [[ZZSession currentUser] getGroups];
    NSLog(@"groups: %d", _groups.count);
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _shareList) 
        return 2;
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _shareList) {
    
        BOOL nopeople = NO;
        if (_peopleShareList == nil || _peopleShareList.count == 0)
            nopeople = YES;
        
        BOOL nogroups = NO;
        if (_groupShareList == nil || _groupShareList.count == 0)
            nogroups = YES;
        
        if (section == kPeople_Section) {
            
            if (nopeople)
                return nil;
            return @"People";
        }
        if (section == kGroup_Section) {
            
            if (nogroups)
                return nil;
            return @"Groups";
        }
    }

    return NULL;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    if (tableView == _addTableView) {
    
        if (indexPath.row == 0) {
            
            UIActionSheet *pActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Search Address Book", @"Enter Email Address", nil];
            pActionSheet.tag = 1;
            pActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [pActionSheet showInView:self.view];
            
            return;
        }
        
        if (indexPath.row == 1) {
            
            SelectGroupViewController *selectGroupVC = [[SelectGroupViewController alloc] initWithNibName:@"SelectGroup" bundle:[NSBundle mainBundle]];
            selectGroupVC.delegate = self;
            selectGroupVC.allowTypeSelection = _asAlbumShareList;
            [selectGroupVC setExcludeGroups:_groupShareList];
            [self.navigationController pushViewController:selectGroupVC animated:YES];
            
            return;
        }
    }
    
    // tableView == _shareList
    
    [_shareList deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kPeople_Section) {
        
        if (indexPath.row == _peopleShareList.count) {
            
            // save as a group
            
            NSString *tempgroupname = [NSString stringWithFormat:@".%@", [ZZGlobal GetUUID]];
            
            NSError *error = nil;
            ZZGroup *tempGroup = [ZZGroup groupWithName:tempgroupname error:&error];   
            
            NSMutableArray *members = [[NSMutableArray alloc]init];
            for (ZZUser *user in _peopleShareList) {
                [members addObject:[NSNumber numberWithUnsignedLongLong: user.user_id]];
            }
            [tempGroup addMembers:members userNames:nil emails:nil];
                    
            GroupEditViewController *groupeditvc = [[GroupEditViewController alloc] initWithNibName:@"GroupEdit" bundle:[NSBundle mainBundle]];
            [groupeditvc setDelegate:self];
            [groupeditvc setGroup:tempGroup];
            [groupeditvc setGroupEditMode:kGroupNewMode];
            [groupeditvc setAllowGroupDelete:NO];
            [self.navigationController pushViewController:groupeditvc animated:YES];
            
            return;
        } else {
            
            // edit by NewPersonViewController or EmailAddressViewController 
            
            ZZUser *user = [_peopleShareList objectAtIndex:indexPath.row];
            
            if (!user.automatic) {
                
                NewPersonViewController *newperson = [[NewPersonViewController alloc] initWithNibName:@"NewPerson" bundle:[NSBundle mainBundle]];
                newperson.delegate = self;
                newperson.allowTypeSelection = _asAlbumShareList;
                newperson.mode = kPersonEditMode;
                [newperson setUser:user first:nil last:nil];
                [self.navigationController pushViewController:newperson animated:YES];

            } else {
            
                EmailAddressViewController *emailvc = [[EmailAddressViewController alloc] initWithNibName:@"EmailAddress" bundle:[NSBundle mainBundle]];
                emailvc.delegate = self;
                emailvc.allowTypeSelection = _asAlbumShareList;
                [emailvc setZZUser:user];
                [self.navigationController pushViewController:emailvc animated:YES];
            }
        }
    }
    
    if (indexPath.section == kGroup_Section) {
                
        ZZGroup *group = [_groupShareList objectAtIndex:indexPath.row];

        GroupEditViewController *groupeditvc = [[GroupEditViewController alloc] initWithNibName:@"GroupEdit" bundle:[NSBundle mainBundle]];
        [groupeditvc setDelegate:self];
        [groupeditvc setGroup:group];
        [groupeditvc setGroupEditMode:kGroupEditMode];
        [groupeditvc setAllowGroupDelete:YES];
        [self.navigationController pushViewController:groupeditvc animated:YES];
    }
}


-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            // search address book
            
            ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];            
            picker.peoplePickerDelegate = self;
            
            [self presentModalViewController:picker animated:YES];
            return;
        }
        
        if (buttonIndex == 1) {
            // enter email address
            
            EmailAddressViewController *emailvc = [[EmailAddressViewController alloc] initWithNibName:@"EmailAddress" bundle:[NSBundle mainBundle]];
            emailvc.delegate = self;
            emailvc.allowTypeSelection = _asAlbumShareList;
            [self.navigationController pushViewController:emailvc animated:YES];
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if ((_groupShareList && _groupShareList.count > 0) || (_peopleShareList && _peopleShareList.count > 0))
        [self useGrayEditRightButton:self action:@selector(editButtonAction:)];
    else    
        [self clearRightButton];
    
    
    if (tableView == _addTableView)
        return 2;
 

    // tableView == _shareList
    int rows = 0;

    if (section == kPeople_Section) {
        if (_peopleShareList.count == 0)
            rows = 0;
        else
            rows = _peopleShareList.count + 1;
    }
        
    if (section == kGroup_Section) {
        
        if (_groupShareList)
            rows = _groupShareList.count;
        else
            rows = 1;
    }
    
    BOOL nopeople = NO;
    if (_peopleShareList == nil || _peopleShareList.count == 0)
        nopeople = YES;
    
    BOOL nogroups = NO;
    if (_groupShareList == nil || _groupShareList.count == 0)
        nogroups = YES;
    
    _shareList.hidden = NO;
    if (nopeople && nogroups) {
        _shareList.hidden = YES;
        
        if (_editing) {
            _editing = NO;
            [_shareList setEditing:NO];
        }
    }
    
    return rows;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _addTableView)
        return UITableViewCellEditingStyleNone;
    
    // tableView == _shareList
    if (indexPath.section == kPeople_Section) {
        
        if (indexPath.row == _peopleShareList.count && _peopleShareList.count > 0) 
            return UITableViewCellEditingStyleNone;
        
        return UITableViewCellEditingStyleDelete;
    }
    
    if (indexPath.section == kGroup_Section) {

        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _addTableView)
        return NO;

    // tableView == _shareList
    if (indexPath.section == kPeople_Section) {
        
        if (indexPath.row == _peopleShareList.count && _peopleShareList.count > 0) 
            return NO;
        
        return YES;
    }
    
    if (indexPath.section == kGroup_Section) {

        return YES;
    }
    
    return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.section == kPeople_Section) {
            int sharelistindex = indexPath.row;
            [_peopleShareList removeObjectAtIndex:sharelistindex];
            [_shareList reloadData];
            
            return;
        }
        
        if (indexPath.section == kGroup_Section) {
            int grouplistindex = indexPath.row;
            [_groupShareList removeObjectAtIndex:grouplistindex];
            [_shareList reloadData];
            
            return;
        }
    }    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    int pos = indexPath.row;
    
    if (tableView == _addTableView) {
        
        NSString *title;
        if (pos == 0)
            title = @"Add Person";
        else
            title = @"Add Group";
        
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone; 

        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(43, 0, 320, 44)];
        textLabel.text = title;
        textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        textLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:textLabel];
        
        UIImage *addimage = [UIImage imageNamed:@"plus-icon-green.png"];
        UIImageView *addimageView = [[UIImageView alloc] initWithImage:addimage];
        addimageView.frame = CGRectMake(6,7,addimage.size.width,addimage.size.height); 
        [cell.contentView addSubview:addimageView];
        
        return cell;
    }

    
    // tableView == _shareList
    if (indexPath.section == kPeople_Section) {
        
        if (pos == _peopleShareList.count && _peopleShareList.count > 0) {
            
            cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
            cell.textLabel.text = @"Save Group";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue; 
            
        } else {
            
            ZZUser *user = [_peopleShareList objectAtIndex:pos];
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"User"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue; 
            
            [UIFactory setUserProfileCell:user cell:cell showSharePermission:_asAlbumShareList];
            
            cell.detailTextLabel.hidden = _editing;
        }
    }
    
    if (indexPath.section == kGroup_Section) {
        
        ZZGroup *group = [_groupShareList objectAtIndex:pos];
        
        NSString *groupName = group.name;
                
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Group"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.textLabel.text = groupName;    
        
        if (_asAlbumShareList) {

            cell.detailTextLabel.hidden = _editing;
            
            if (group.sharePermission == kShareAsViewer) {
                cell.detailTextLabel.text = @"View";
            } else if (group.sharePermission == kShareAsContributor) {
                cell.detailTextLabel.text = @"Add";
            } else
                cell.detailTextLabel.text = @"Admin";
        }
    }
    
    return cell;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{ 
    [self dismissModalViewControllerAnimated:YES];
    
    NSString *first, *last;
    
    first = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    last = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emails);
    CFRelease(emails);
    
    if (!emailAddresses || emailAddresses.count == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Add Person" message:@"This contact does not have any email addresses." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }

    NSError *error=nil;
    NSArray *findUsers=nil;
    NSArray *emailsNotFound=nil;
    [ZZUser findOrCreateUsers:nil userNames:nil emails:emailAddresses findOnly:YES users:&findUsers emailsNotFound:&emailsNotFound error:&error];
    
    // several possible result combinations
    
    
    if (findUsers.count == 1) {
        // ZZ user for selected contact
        // present NewPersonViewController; selection for just contributor|viewer type
        
        ZZUser *user = [findUsers objectAtIndex:0];
        user.sharePermission = kShareAsContributor;
        
        NewPersonViewController *newperson = [[NewPersonViewController alloc] initWithNibName:@"NewPerson" bundle:[NSBundle mainBundle]];
        newperson.delegate = self;
        newperson.allowTypeSelection = _asAlbumShareList;
        newperson.mode = kPersonNewMode;
        [newperson setUser:user first:first last:last];
        [self.navigationController pushViewController:newperson animated:YES];
        
        return NO;
        
    } else {
    
        NewPersonViewController *newperson = [[NewPersonViewController alloc] initWithNibName:@"NewPerson" bundle:[NSBundle mainBundle]];
        newperson.delegate = self;
        newperson.allowTypeSelection = _asAlbumShareList;
        newperson.mode = kPersonNewMode;
        [newperson setContact:emailAddresses first:first last:last];
        [self.navigationController pushViewController:newperson animated:YES];
        
        return NO;
        
    }

    return NO;
}


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}


-(void)backButtonAction:(id)sender
{
    MLOG(@"backButtonAction");
    
    [delegate shareListComplete:_peopleShareList groups:_groupShareList];
}



-(void)selectGroup:(id)sender
{
    MLOG(@"selectGroup");
}


-(void)setShareList:(BOOL)asAlbumShareList people:(NSArray*)people groups:(NSArray*)groups
{
    _asAlbumShareList = asAlbumShareList;
    
    // seed controller with people list / group list
    _peopleShareList = [[NSMutableArray alloc]initWithArray:people];
    _groupShareList = [[NSMutableArray alloc]initWithArray:groups];
}


- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}


-(void)cancelButtonAction:(id)sender
{
    _editing = NO;
    [_shareList reloadData];
    [_shareList setEditing:NO animated:YES];
    [self useGrayEditRightButton:self action:@selector(editButtonAction:)];    
}


-(void)editButtonAction:(id)sender
{
    _editing = YES;
    [_shareList reloadData];
    [_shareList setEditing:YES animated:YES];
    [self useGrayCancelRightButton:self action:@selector(cancelButtonAction:)];
}


- (void)newGroupComplete:(ZZGroup *)group
{ 
    [self.navigationController popViewControllerAnimated:YES];      

    NSMutableArray *userIDs = [[NSMutableArray alloc]initWithCapacity:_peopleShareList.count];
    for (ZZUser *user in _peopleShareList) {
        [userIDs addObject:[NSNumber numberWithUnsignedLongLong: user.user_id]];
    }
    
    // add users to group
    [group addMembers:userIDs userNames:NULL emails:NULL];
    
    // clear people list, users are now in the group
    [_peopleShareList removeAllObjects];

    // add new group
    ZZGroup *addGroup = [[ZZGroup alloc]initWithGroup:group];
    [_groupShareList addObject:addGroup];

    [_shareList reloadData];
}

-(void)selectGroupDone:(ZZGroup *) group
{
    [self.navigationController popViewControllerAnimated:YES];          
    
    BOOL addable = YES;
    
    // avoid adding duplicates
    for (ZZGroup *groupInList in _groupShareList) {        
        if(groupInList.id == group.id){
            addable = NO;
            break;            
        }
    }
    
    if (addable) {
        // add new group
        ZZGroup *addGroup = [[ZZGroup alloc]initWithGroup:group];
        [_groupShareList addObject:addGroup];        
        [_shareList reloadData];
    }else{    
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Add Group" message:@"The group is already in the list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}


-(void)selectGroupCancel
{
    [self.navigationController popViewControllerAnimated:YES];          
}


-(void)newEmailAddress:(ZZUserID)userID name:(NSString*)name email:(NSString*)email sharePermission:(ZZSharePermission)sharePermission
{
    [self.navigationController popViewControllerAnimated:NO];          
    
    NSString *first = nil;
    NSString *last = nil;
    
    NSArray *parts = [name componentsSeparatedByString: @" "];
    if (parts.count > 0) {
        if (parts.count == 1) {
            last = [parts objectAtIndex:0];
        } else {
            first = [parts objectAtIndex:0];
            NSMutableArray *partm = [[NSMutableArray alloc]initWithArray:parts];
            [partm removeObjectAtIndex:0];
            last = [partm componentsJoinedByString: @" "];
        }
    }
    
    if (userID != 0) {
        // allow simply update if only info that changed is the viewer/contributor type
        
        ZZUser *user = nil;
        
        int i = 0;
        for (ZZUser *u in _peopleShareList) {
            if (u.user_id == userID ) {
                user = u;
                break;
            }
            
            i++;
        }
        
        if (user && [user.email isEqualToString:email] && [user.first_name isEqualToString:first] && [user.last_name isEqualToString:last]) {
            user.sharePermission = sharePermission;
            [_shareList reloadData];
            return;
        }
        
        
        // delete existing user from _peopleShareList
        [_peopleShareList removeObjectAtIndex:i];
    }
    
    
    //
    // new user
    //
    
    BOOL addable = YES;
    
    // avoid adding duplicates
    for (ZZUser *u in _peopleShareList) {
        if ([u.email isEqualToString:email]) {
            addable = NO;
            break;
        }
    }
    
    if (!addable){
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Add Person" message:@"A person with that email is already on your share list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];

        return;
    }

    NSString *fqemail = [ZZGlobal fullyQualifiedEmailAddress:email first:first last:last];
    
    NSError *error = nil;
    NSArray *findusers = [ZZUser findOrCreateUsers:nil userNames:nil emails:[NSArray arrayWithObject: fqemail] error:&error];
    if (findusers && findusers.count > 0) {  
        ZZUser *user = [findusers objectAtIndex:0];
        user.sharePermission = sharePermission;
        [_peopleShareList addObject:user];
        [_shareList reloadData];
    }    
}


-(void)newEmailAddressCancel
{
    [self.navigationController popViewControllerAnimated:YES];          
}


-(void)reSync
{
    // refresh _groups from server
   
    _groups = [[ZZSession currentUser] getGroups];
    
    for( int i=0; i < _groupShareList.count; i++){
        ZZGroup *groupInList = [_groupShareList objectAtIndex:i];
        for(ZZGroup *group in _groups){
            if( groupInList.id == group.id ){                
                // refresh groups in share list with the groups that just
                // arrived from the server
                group.sharePermission = groupInList.sharePermission;
                [_groupShareList replaceObjectAtIndex:i withObject:group];
                break;
            }
        }
    }
}


-(void)groupEditComplete:(ZZGroup*)group changed:(BOOL)changed;
{
    if (changed) {
        
        [self reSync];
        
        // update group if viewer/contributor type changed
        for( int i=0; i < _groupShareList.count; i++) {
            ZZGroup *groupInList = [_groupShareList objectAtIndex:i];
            if (groupInList.id == group.id) {
                groupInList.sharePermission = group.sharePermission;
            }
        }
        
        [_shareList reloadData];
    }
    
    [self.navigationController popViewControllerAnimated:YES];          
}


-(void)groupEditNew:(ZZGroup *)group
{
    [_peopleShareList removeAllObjects];
    
    // add new group
    ZZGroup *addGroup = [[ZZGroup alloc]initWithGroup:group];
    [_groupShareList addObject:addGroup];
    
    [_shareList reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];          
}


-(void)groupEditDeleteGroup:(ZZGroupID)groupid;
{
    [self.navigationController popViewControllerAnimated:YES];          

    int i = 0;
    int deleteIndex = -1;    
    for (ZZGroup *groupInList in _groupShareList) {        
        if (groupInList.id == groupid) {
            deleteIndex = i;
        }        
        i++;
    }
    
    if (deleteIndex != -1) {
        [_groupShareList removeObjectAtIndex:deleteIndex];
        [_shareList reloadData];
    }    
}


-(void)getGroups:(BOOL)init
{
    
}


-(void)toggleShareListItem:(int)index
{
    
}


-(void)newPersonAdded:(ZZUser*)user
{
    // NewPersonViewControllerDelegate
    
    [self.navigationController popViewControllerAnimated:YES]; 

    BOOL addable = YES;
    
    // avoid adding duplicates
    for (ZZUser *u in _peopleShareList) {
        if ([u.email isEqualToString:user.email]) {
            addable = NO;
            break;
        }
    }
    
    if (!addable){
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Add Person" message:@"A person with that email is already on your share list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    ZZUser *addUser = [[ZZUser alloc]initWithUser:user];
    [_peopleShareList addObject:addUser];
    
    [_shareList reloadData];
}


-(void)newPersonChanged:(ZZUser*)user
{
    [self.navigationController popViewControllerAnimated:YES]; 

    for (ZZUser *u in _peopleShareList) {
        if (u.user_id == user.user_id) {
            u.sharePermission = user.sharePermission;
        }
    }
    
    [_shareList reloadData];
}


-(void)newPersonCancel
{
    // NewPersonViewControllerDelegate
    
    [self.navigationController popViewControllerAnimated:YES]; 
}




@end
