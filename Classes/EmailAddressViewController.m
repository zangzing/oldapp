//
//  EmailAddressViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 1/29/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zzglobal.h"
#import "ZZUINavigationBar.h"
#import "EmailAddressViewController.h"

@implementation EmailAddressViewController

@synthesize emailaddresstable;
@synthesize allowTypeSelection=_allowTypeSelection;
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
    [self useDefaultNavigationBarStyle];
    
    if (_user) {
        self.title = @"Email";
        [self useCustomBackButton:@"Back" target:self action:@selector(backButtonAction:)];
    } else {
        self.title = @"Add Email";
        [self useCustomBackButton:@"Back" target:self action:@selector(backButtonAction:)];
        [self useGrayDoneRightButton:self action:@selector(doneButtonAction:)];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *bcolor = [UIColor colorWithRed: 221.0/255.0 green: 221.0/255.0 blue: 221.0/255.0 alpha: 1.0];
    [self.view setBackgroundColor:bcolor];
    [emailaddresstable setBackgroundColor:bcolor];
    
    [self setupNavigationBar];
    
    _sharetype = kShareAsContributor;
    
    if (_user) {
        _sharetype = _user.sharePermission;
    }
    
    if (_allowTypeSelection) {
        int selectedSegment = 0;
        
        if (_sharetype == kShareAsContributor)
            selectedSegment = 0;
        else if (_sharetype == kShareAsViewer)
            selectedSegment = 1;

        NSDictionary *persontypedef = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"Add Photos", @"View Photos", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(90,30)], @"size", @"segment.png", @"button-image", @"segment-selected.png", @"button-highlight-image", @"segment-separator.png", @"divider-image", [NSNumber numberWithFloat:11.0], @"cap-width", [UIColor blackColor], @"button-color", [UIColor blackColor], @"button-highlight-color", nil];
        
        _persontype = [[ZZSegmentedControl alloc] initWithSegmentCount:2 selectedSegment:selectedSegment segmentdef:persontypedef tag:0 delegate:self];
        _persontype.frame = CGRectMake(70, 70, _persontype.frame.size.width, _persontype.frame.size.height);    // adjust location
        
        [self.view addSubview:_persontype];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;  

    /*
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Name";
        
        _nametextfield = [[UITextField alloc] initWithFrame:CGRectMake(100,10,290,30)];
        [_nametextfield setDelegate:self];
        _nametextfield.borderStyle = UITextBorderStyleNone;
        _nametextfield.textColor = [UIColor blackColor]; 
        _nametextfield.backgroundColor = [UIColor clearColor];
        _nametextfield.font = [UIFont systemFontOfSize:16];  
        _nametextfield.keyboardType = UIKeyboardTypeDefault;  
        _nametextfield.returnKeyType = UIReturnKeyDone;  
        [cell.contentView addSubview:_nametextfield];
        
        if (_user) {
            _nametextfield.text = _user.name;
        } else {
            [_nametextfield becomeFirstResponder];
        }
    }
    */
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Email";
        
        _emailtextfield = [[UITextField alloc] initWithFrame:CGRectMake(100,10,200,30)];
        [_emailtextfield setDelegate:self];
        _emailtextfield.borderStyle = UITextBorderStyleNone;
        _emailtextfield.textColor = [UIColor blackColor]; 
        _emailtextfield.backgroundColor = [UIColor clearColor];
        _emailtextfield.font = [UIFont systemFontOfSize:16];  
        _emailtextfield.keyboardType = UIKeyboardTypeDefault;  
        _emailtextfield.returnKeyType = UIReturnKeyDone;  
        [cell.contentView addSubview:_emailtextfield];
        
        if (_user) {
            _emailtextfield.text = _user.email;
        } else {
            [_emailtextfield becomeFirstResponder];
        }
    }
    
    return cell;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO; 
}


- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    MLOG(@"textFieldDidBeginEditing");
}


- (void)textFieldDidEndEditing:(UITextField*)textField
{
    MLOG(@"textFieldDidEndEditing");
}


-(void)backButtonAction:(id)sender
{
    MLOG(@"backButtonAction");
    
    if (_user) {
        
        NSString *email = _emailtextfield.text;
        
        BOOL valid = [ZZGlobal validateEmail:email];
        if (!valid) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        [_delegate newEmailAddress:_user.user_id name:nil email:email sharePermission:_sharetype];

    } else {
        [_delegate newEmailAddressCancel];
    }
}

-(void)doneButtonAction:(id)sender
{
    // done is only called for the new user case
    
    NSString *email = _emailtextfield.text;
    
    BOOL valid = [ZZGlobal validateEmail:email];
    if (!valid) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [_delegate newEmailAddress:0 name:nil email:email sharePermission:_sharetype];
}

- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    if (segmentIndex == 0) 
        _sharetype = kShareAsContributor;
    else
        _sharetype = kShareAsViewer;
}

-(void)setZZUser:(ZZUser*)user
{
    _user = [[ZZUser alloc]initWithUser:user];
}


@end
