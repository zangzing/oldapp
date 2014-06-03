//
//  GroupEditViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 1/22/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "albums.h"
#import "zzglobal.h"
#import "UIFactory.h"
#import "UIImageView+WebCache.h"
#import "ZZUINavigationBar.h"
#import "ZZGradientButton.h"
#import "ZZSegmentedControl.h"
#import "EmailAddressViewController.h"
#import "NewPersonViewController.h"
#import "GroupEditViewController.h"

#define kGroup_Section      0
#define kMembers_Section    1

@implementation GroupEditViewController

@synthesize grouplist;
@synthesize delegate=_delegate;

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


-(void)setupNavigationBar
{    
    // nav bar
    [self useDefaultNavigationBarStyle];
    self.title = @"Groups";
    
    if (_mode == kGroupNewMode) {
        [self useGrayCancelRightButton:self action:@selector(backButtonAction:)];
    } else {
        [self useCustomBackButton:@"Back" target:self action:@selector(backButtonAction:)];        
    }
    
    [self useGrayEditRightButton:self action:@selector(editButtonAction:)];
}


- (void)viewDidLoad
{
    MLOG(@"GroupEditViewController:viewDidLoad, group: %llu", _group.id);
    
    [super viewDidLoad];
    
    UIColor *bcolor = [UIColor colorWithRed: 221.0/255.0 green: 221.0/255.0 blue: 221.0/255.0 alpha: 1.0];
    [self.view setBackgroundColor:bcolor];
    [grouplist setBackgroundColor:bcolor];
    
    
    if (_mode == kGroupNewMode) {
        
        _saveButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 355, 330, 70)];
        _saveButtonView.backgroundColor = [UIColor blackColor];
        _saveButtonView.alpha = 0.4;
        _saveButtonView.hidden = YES;
        [self.view addSubview:_saveButtonView];
        
        _saveButton = [UIFactory screenWideGreenButton: NSLocalizedString(@"Save Group", @"Save Group Button Text") frame:CGRectMake(9, 363, 302, 46)];
        [self.view addSubview:_saveButton];
        [_saveButton addTarget:self action:@selector(saveGroupAction:) forControlEvents:UIControlEventTouchUpInside];    

    } else {
        
        if (_allowGroupDelete) {
            
            _deleteButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 355, 330, 70)];    
            _deleteButtonView.backgroundColor = [UIColor blackColor];
            _deleteButtonView.alpha = 0.4;
            _deleteButtonView.hidden = YES;
            [self.view addSubview:_deleteButtonView];
            
            _deleteButton = [UIFactory screenWideRedButton: NSLocalizedString(@"Delete Group", @"Delete Group Button Text") frame:CGRectMake(9, 363, 302, 46)];
            [self.view addSubview:_deleteButton];
            
            [_deleteButton addTarget:self action:@selector(deleteGroup) forControlEvents:UIControlEventTouchUpInside];
            
            _deleteButton.hidden = YES;
            _deleteButtonView.hidden = YES;
        }

    }
    
    [self setupNavigationBar];
    
    _changed = NO;
    _members = _group.members; 
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


-(void)setAllowGroupDelete:(BOOL)allowDelete
{
    _allowGroupDelete = allowDelete;
}


-(void)setGroupEditMode:(ZZGroupEditMode)mode
{
    _mode = mode;
}


-(void)setGroup:(ZZGroup *)group
{
    _group = [[ZZGroup alloc]initWithGroup:group];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kGroup_Section)
        return 1;
    
    if (section == kMembers_Section) {
        
        if (_saveButtonView)
            _saveButtonView.hidden = YES;
        
        if (_members) {
            
            if (_members.count > 4) {
                if (_saveButtonView)
                    _saveButtonView.hidden = NO;
            }
            
            return _members.count + 1;
        }
        
        return 1;
    }

    return 0;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kMembers_Section && indexPath.row != 0)
        return YES;
    return  NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // *** are you sure alert ?
        
        if (indexPath.section == kMembers_Section && indexPath.row != 0) {
            
            int pos = indexPath.row;
            ZZUser *user = [_members objectAtIndex:pos-1];
                    
            MLOG(@"delete user: %@", user.user_id);
            
            NSArray *nmembers = [_group removeMembers:[NSArray arrayWithObject:[NSNumber numberWithUnsignedLongLong:user.user_id]]];
            if (nmembers)
                _members = nmembers;
            [grouplist reloadData];
        }
        
    }    
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kMembers_Section && indexPath.row != 0)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    if (indexPath.section == kGroup_Section && _mode == kGroupEditMode) {
    
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = @"";
        
        _groupname = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 280, 44)];
        _groupname.font = cell.textLabel.font;
        _groupname.adjustsFontSizeToFitWidth = NO;
        _groupname.backgroundColor = [UIColor clearColor];
        _groupname.autocorrectionType = UITextAutocorrectionTypeNo;
        _groupname.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _groupname.textAlignment = UITextAlignmentLeft;
        _groupname.keyboardType = UIKeyboardTypeDefault;
        _groupname.returnKeyType = UIReturnKeyDone;
        //_groupname.clearButtonMode =  UITextFieldViewModeWhileEditing;
        _groupname.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _groupname.delegate = self;
        _groupname.text = _group.name;
                
        [cell addSubview:_groupname];
        
        [_groupname becomeFirstResponder];
        
        return;
    }
    
    if (indexPath.section == kMembers_Section) {
        
        if (indexPath.row == 0) {
            UIActionSheet *pActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Search Address Book", @"Enter Email Address", nil];
            pActionSheet.tag = 2;
            pActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [pActionSheet showInView:self.view];
            
            return;
        }
        
    }
    
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
        newperson.allowTypeSelection = NO;
        newperson.mode = kPersonNewMode;
        [newperson setUser:user first:first last:last];
        [self.navigationController pushViewController:newperson animated:YES];
        
        return NO;
        
    } else {
        
        NewPersonViewController *newperson = [[NewPersonViewController alloc] initWithNibName:@"NewPerson" bundle:[NSBundle mainBundle]];
        newperson.delegate = self;
        newperson.allowTypeSelection = NO;
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


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
//  if (section == kGroup_Section && _mode == kGroupNewMode) {
    if (section == kGroup_Section) {
        
        int selectedSegment = 0;
        if (_group.sharePermission == kShareAsViewer)
            selectedSegment = 1;
        else if (_group.sharePermission == kShareAsContributor)
            selectedSegment = 0;
        
        UIView *footerview = [[UIView alloc]init];
        
        NSDictionary *grouptypedef = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"Add Photos", @"View Photos", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(90,30)], @"size", @"segment.png", @"button-image", @"segment-selected.png", @"button-highlight-image", @"segment-separator.png", @"divider-image", [NSNumber numberWithFloat:11.0], @"cap-width", [UIColor blackColor], @"button-color", [UIColor blackColor], @"button-highlight-color", nil];
        
        ZZSegmentedControl *grouptype = [[ZZSegmentedControl alloc] initWithSegmentCount:2 selectedSegment:selectedSegment segmentdef:grouptypedef tag:0 delegate:self];
        grouptype.frame = CGRectMake(70, 10, grouptype.frame.size.width, grouptype.frame.size.height);    // adjust location
                
        [footerview addSubview:grouptype];
        
        return footerview;
    }
    
    return NULL;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//  if (section == kGroup_Section && _mode == kGroupNewMode) {
    if (section == kGroup_Section) {
        
        return 50.0;
    }
    
    return 0;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == kGroup_Section) {
        
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (_mode == kGroupNewMode) {
            
            if (_groupname == NULL) {
                _groupname = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 280, 44)];
                _groupname.font = [UIFont boldSystemFontOfSize:16.0];
                _groupname.adjustsFontSizeToFitWidth = NO;
                _groupname.backgroundColor = [UIColor clearColor];
                _groupname.autocorrectionType = UITextAutocorrectionTypeNo;
                _groupname.autocapitalizationType = UITextAutocapitalizationTypeWords;
                _groupname.textAlignment = UITextAlignmentLeft;
                _groupname.keyboardType = UIKeyboardTypeDefault;
                _groupname.returnKeyType = UIReturnKeyDone;
                //_groupname.clearButtonMode =  UITextFieldViewModeWhileEditing;
                _groupname.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                _groupname.placeholder = @"New Group Name";
                _groupname.delegate = self;
                                            
                [_groupname becomeFirstResponder];
            }
            
            [cell addSubview:_groupname];

        } else {
    
            cell.textLabel.text = _group.name;
        }
        return cell;
    }
    
    if (indexPath.section == kMembers_Section) {
        
        int pos = indexPath.row;
        
        if (pos == 0) {
            
            NSString *title = @"Add Person";

            cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone; 
            
            UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(43, 2, 320, 40)];
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
        
        // user rows
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone; 
        
        ZZUser *user = [_members objectAtIndex:pos-1];
        
        [UIFactory setUserProfileCell:user cell:cell showSharePermission:NO];        
        return cell;
    }
    return NULL;
}


-(void)backButtonAction:(id)sender
{
    MLOG(@"backButtonAction");
    
    // new group; not committed, delete
    if (_mode == kGroupNewMode) {
        [_group delete];
        _group = NULL;
    }
    
    [_delegate groupEditComplete:_group changed:_changed];     
}


-(void)cancelButtonAction:(id)sender
{
    if (_deleteButton) {
        _deleteButtonView.hidden = YES;
        _deleteButton.hidden = YES;
    }
    
    [grouplist setEditing:NO animated:YES];
    
    [self useGrayEditRightButton:self action:@selector(editButtonAction:)];
}


-(void)editButtonAction:(id)sender
{
    if (_deleteButton) {
        if (_members && _members.count > 4)
            _deleteButtonView.hidden = NO;
        
        _deleteButton.hidden = NO;
    }
    
    [grouplist setEditing:YES animated:YES];
    
    [self useGrayCancelRightButton:self action:@selector(cancelButtonAction:)];
}


-(void)deleteGroup
{
    MLOG(@"deleteGroup");
    
    NSString *message = @"Are you sure you want to delete this group?";
    
    UIActionSheet *pActionSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Group" otherButtonTitles:nil, nil];
    pActionSheet.tag = 1;
    pActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [pActionSheet showInView:self.view];
}


-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            // delete
            ZZGroupID groupId = _group.id;
            [_group delete];
            [_delegate groupEditDeleteGroup:groupId];
        }
    }
    
    if (actionSheet.tag == 2) {
        
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
            emailvc.allowTypeSelection = NO;
            [self.navigationController pushViewController:emailvc animated:YES];
        }
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO; 
}


- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    MLOG(@"textFieldDidBeginEditing");
}


-(BOOL)setGroupName:(NSString*)groupname rename:(BOOL)rename
{
    NSString *errStr; 

    groupname = [groupname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];    
    
    if (groupname && groupname.length > 0) {
        
        
        errStr = [ZZGroup validName:groupname];
        if (errStr != NULL) {
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:errStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];   
            
            return NO;
        }
        
        ZZGroup *modifiedGroup = [_group updateName:groupname]; 
        
        if (_group.lastCallError.code == 0) {
            _group = modifiedGroup;
            _changed = YES;
        } else {
            
            if (_group.lastCallError.code == 409) 
                errStr = [NSString stringWithFormat:@"The group name '%@' already exists.  Please provide a different name.", groupname];
            else 
                errStr = [NSString stringWithFormat:@"Cannot create group; error: %d", [_group.lastCallError.userInfo valueForKey:NSLocalizedFailureReasonErrorKey]];
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:errStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];  
            
            return NO;
        }
    } else {
        
        // if groupname is empty and this is a new group, alert
        
        if (!rename) {
            
            errStr = @"You must name this group.";
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:errStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];   
            
            return NO;
        }
        
    }
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField*)textField
{
    MLOG(@"textFieldDidEndEditing");
    
    // rename on end editing for edit mode only
    if (_mode == kGroupEditMode) {
        [self setGroupName:_groupname.text rename:YES];
    }
}


-(void)newEmailAddress:(ZZUserID)userID name:(NSString*)name email:(NSString*)email sharePermission:(ZZSharePermission)sharePermission    
{
    [self.navigationController popViewControllerAnimated:YES];          
    
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
    
    NSString *fqemail = [ZZGlobal fullyQualifiedEmailAddress:email first:first last:last];
    
    // find_or_create user
    NSError *error=nil;
    NSArray *findusers = [ZZUser findOrCreateUsers:nil userNames:nil emails:[[NSArray alloc]initWithObjects:fqemail, nil] error:&error];
    
    if( findusers != NULL) {
        
        ZZUser *user = [findusers objectAtIndex:0];
        
        _members = [_group addMembers:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedLongLong:user.user_id], nil] userNames:NULL emails:NULL];

        //TODO: Error validation for the find and the add

        [grouplist reloadData];
    }
}


-(void)newPersonAdded:(ZZUser*)user
{
    MLOG(@"newPersonAdded");
    
    _members = [_group addMembers:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedLongLong:user.user_id], nil] userNames:NULL emails:NULL];
    [grouplist reloadData];

    [self.navigationController popViewControllerAnimated:YES]; 
}


-(void)newPersonChanged:(ZZUser*)user
{
    MLOG(@"newPersonChanged");
    
    [self.navigationController popViewControllerAnimated:YES]; 
}



-(void)saveGroupAction:(id)sender
{
    MLOG(@"saveGroupAction");
    
    BOOL ok = [self setGroupName:_groupname.text rename:NO];
    if (ok) {
        [_delegate groupEditNew:_group];
    }
}

-(void)newEmailAddressCancel
{
    [self.navigationController popViewControllerAnimated:YES];          
}


- (void)touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    _changed = YES;
    
    if (segmentIndex == 0) 
        _group.sharePermission = kShareAsContributor;
    else
        _group.sharePermission = kShareAsViewer;
}

-(void)newPersonCancel
{
    
}




@end
