//
//  GroupNewViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 1/25/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zzglobal.h"
#import "albums.h"
#import "ZZUINavigationBar.h"
#import "GroupNewViewController.h"

@implementation GroupNewViewController

@synthesize grouptableview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _group = NULL;
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

-(void)setupNavigationBar:(NSString*)title
{    
    [self useDefaultNavigationBarStyle];
    self.title = title;
    [self useCustomBackButton:@"Back" target:self action:@selector(backButtonAction:)];

    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title;
    if (_group == NULL) 
        title = @"New Group";
    else
        title = @"Rename Group";
        
        [self setupNavigationBar:title];
    
    UIColor *bcolor = [UIColor colorWithRed: 221.0/255.0 green: 221.0/255.0 blue: 221.0/255.0 alpha: 1.0];
    [self.view setBackgroundColor:bcolor];
    [grouptableview setBackgroundColor:bcolor];
    
    _closing = NO;
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    _groupnametext = [[UITextField alloc] initWithFrame:CGRectMake(5,10,290,30)];
    [_groupnametext setDelegate:self];
    _groupnametext.borderStyle = UITextBorderStyleNone;
    _groupnametext.textColor = [UIColor blackColor]; 
    _groupnametext.backgroundColor = [UIColor clearColor];
    _groupnametext.font = [UIFont systemFontOfSize:16];  
    //_groupnametext.autocorrectionType = UITextAutocorrectionTypeNo;	
    _groupnametext.keyboardType = UIKeyboardTypeDefault;  
    _groupnametext.returnKeyType = UIReturnKeyDone;  
    //_groupnametext.clearButtonMode = UITextFieldViewModeWhileEditing; 
    [cell.contentView addSubview:_groupnametext];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;  
    
    [_groupnametext becomeFirstResponder];
    
    if (_group == NULL) {
        _groupnametext.placeholder = @"New Group Name"; 
    } else {
        _groupnametext.text = _group.name;
    }
    
    return cell;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO; 
}


-(void)renameGroup
{
    NSString* groupname = _groupnametext.text;
    groupname = [groupname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (groupname.length == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:@"The group name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        [_groupnametext becomeFirstResponder];
        return;
    }
    
    if (groupname.length > kGroupNameLengthMax) {
        
        NSString *lenErr = [NSString stringWithFormat:@"The group name cannot be longer than %d characters.", kGroupNameLengthMax];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:lenErr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        [_groupnametext becomeFirstResponder];
        return;
    }
    
    BOOL rename = YES;
    
    // original name?  
    if ([groupname isEqualToString: _group.name])
        rename = NO;
    
    if (rename) {        
        ZZGroup *modifiedGroup = [_group updateName:groupname]; 
        if( modifiedGroup == NULL) {
            NSString *errStr;            
            if (_group.lastCallError.code == 409) {
                errStr = [NSString stringWithFormat:@"The group name '%@' already exists.  Please provide a different name.", groupname];
            } else {
                errStr = [NSString stringWithFormat:@"Cannot create group; error: %d", [_group.lastCallError.userInfo valueForKey:NSLocalizedFailureReasonErrorKey]];
            }
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:errStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            [_groupnametext becomeFirstResponder];
            return;
        }
    }
    
    if (rename)
        [delegate newGroupRenamed:_group name:groupname];
    else
        [delegate newGroupCancel];
}


- (void)createGroup
{
    NSString* groupname = _groupnametext.text;
    groupname = [groupname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (groupname.length == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:@"You must provide a group name to create a new group." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        [_groupnametext becomeFirstResponder];
        return;
    }
    
    if (groupname.length > kGroupNameLengthMax) {
        
        NSString *lenErr = [NSString stringWithFormat:@"The group name cannot be longer than %d characters.", kGroupNameLengthMax];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:lenErr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        [_groupnametext becomeFirstResponder];
        return;
    }
    
    NSError *error = nil;
    ZZGroup *newGroup = [ZZGroup groupWithName:groupname error:&error];   
    if( newGroup == NULL) {

        NSString *errStr;
        if ( error.code == 409) {
            errStr = [NSString stringWithFormat:@"The group name '%@' already exists.  Please provide a different name.", groupname];
        } else {
            errStr = [NSString stringWithFormat:@"Unable to create new group; error: %d", [error.userInfo valueForKey:NSLocalizedFailureReasonErrorKey]];
        }
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Groups" message:errStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        [_groupnametext becomeFirstResponder];
        return;
    }
    _group = newGroup;
    [delegate newGroupComplete:_group];
}

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    MLOG(@"textFieldDidBeginEditing");

}


- (void)textFieldDidEndEditing:(UITextField*)textField
{
    MLOG(@"textFieldDidEndEditing");
    
    if (_closing)
        return;
    
    [self createGroup];
}



-(void)backButtonAction:(id)sender
{
    MLOG(@"backButtonAction");
    
    _closing = YES;
    [delegate newGroupCancel];
}



-(void)doneButtonAction:(id)sender
{
    MLOG(@"doneButtonAction");
    
    _closing = YES;
    
    if (_group == NULL)
        [self createGroup];
    else
        [self renameGroup];
}


-(void)setGroup:(ZZGroup *)group
{
    _group = [[ZZGroup alloc]initWithGroup:group];;
}

- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}



@end
