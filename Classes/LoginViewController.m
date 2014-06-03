//
//  Login.m
//  ZangZing
//
//  Created by Phil Beisel on 8/20/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "ZZAPIClient.h"
#import "zzglobal.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "albums.h"

@implementation LoginViewController

@synthesize titlebar;
@synthesize logintable;
@synthesize loginactivity;
@synthesize errlabel;
@synthesize serverlabel;
@synthesize productionswitch;
@synthesize parent;
@synthesize serverPicker=_serverPicker;

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
    
    //logintable.separatorStyle = UITableViewCellSeparatorStyleNone;
    logintable.separatorColor = [UIColor clearColor];
    logintable.rowHeight = 40;
    
    loginactivity.hidden = YES;
    titlebar.topItem.title = @"Sign In";
    errlabel.text = @"";
    //serverlabel.text = [NSString stringWithFormat:@"You will be signed in to %@", [gZZ server:YES]];

    //facebook button
    UIImage *facebookButtonImage = [UIImage imageNamed:@"facebook-connect.png"] ;
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newButton setBackgroundImage:facebookButtonImage forState:UIControlStateNormal];
    newButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    newButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newButton.frame = CGRectMake(0, 0, 142, 25);
    _fbButton = newButton;
    [ _fbButton addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];    
    titlebar.topItem.leftBarButtonItem = cancelItem;

    [productionswitch addTarget:self action:@selector(toggleProductionSwitch:) forControlEvents: UIControlEventValueChanged];
     [_serverPicker selectRow:0 inComponent:0 animated:NO];
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return @"Sign in to ZangZing:";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    int x,y,width,height;
    UILabel *ul;
    
    int row = [indexPath indexAtPosition: 1];
    NSString *CellIdentifier = [ NSString stringWithFormat: @"s%d:%d", [ indexPath indexAtPosition: 0 ], [ indexPath indexAtPosition:1 ]];
    MLOG(@"LoginViewController:  cellForRowAtIndexPath: %@", CellIdentifier);
    
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
    switch (row) {
        case 0:
            x = 10;
            y = 10;
            height = 25;
            width = 80;
            
            ul = [[UILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
            ul.font = [UIFont boldSystemFontOfSize:14];
            [ul setBackgroundColor:[UIColor clearColor]];
            ul.text = @"Username:";
            [cell.contentView addSubview:ul];
            
            x += (width + 10);
            width = 170;
            
            _usernametext = [[UITextField alloc] initWithFrame:CGRectMake(x,y,width,height)];
            [_usernametext setDelegate:self];
            _usernametext.borderStyle = UITextBorderStyleRoundedRect;
            _usernametext.textColor = [UIColor blackColor]; 
            _usernametext.font = [UIFont systemFontOfSize:14];  
            _usernametext.backgroundColor = [UIColor whiteColor]; 
            _usernametext.autocorrectionType = UITextAutocorrectionTypeNo;	
            _usernametext.keyboardType = UIKeyboardTypeDefault;  
            _usernametext.returnKeyType = UIReturnKeyDone;  
            _usernametext.clearButtonMode = UITextFieldViewModeWhileEditing;	
            [cell.contentView addSubview:_usernametext];
           
            break;
            
        case 1:
            x = 10;
            y = 10;
            height = 25;
            width = 80;
            
            ul = [[UILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
            ul.font = [UIFont boldSystemFontOfSize:14];
            [ul setBackgroundColor:[UIColor clearColor]];
            ul.text = @"Password:";
            [cell.contentView addSubview:ul];
            
            x += (width + 10);
            width = 170;
            
            _passwordtext = [[UITextField alloc] initWithFrame:CGRectMake(x,y,width,height)];
            [_passwordtext setDelegate:self];
            _passwordtext.borderStyle = UITextBorderStyleRoundedRect;
            _passwordtext.textColor = [UIColor blackColor]; 
            _passwordtext.font = [UIFont systemFontOfSize:14];  
            _passwordtext.backgroundColor = [UIColor whiteColor]; 
            _passwordtext.autocorrectionType = UITextAutocorrectionTypeNo;	
            _passwordtext.keyboardType = UIKeyboardTypeDefault;  
            _passwordtext.returnKeyType = UIReturnKeyDone;  
            _passwordtext.clearButtonMode = UITextFieldViewModeWhileEditing;	
            _passwordtext.secureTextEntry = YES;
            [cell.contentView addSubview:_passwordtext];
            
            break;
            
        case 2:
            
            x = 190;
            y = 10;
            height = 25;
            width = 80;
            
            _signinbutton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [_signinbutton setTitle:@"Sign In" forState:UIControlStateNormal];
            [_signinbutton addTarget:self action:@selector(signin:) forControlEvents:UIControlEventTouchUpInside];
            _signinbutton.frame = CGRectMake(x,y,width,height);
            [cell.contentView addSubview:_signinbutton];
            _fbButton.frame =  CGRectMake(11, y, 142, 25);
            [cell.contentView addSubview:_fbButton];            
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}





-(void)cancelButtonPressed:(id)sender
{
    [parent doneLogin:self didLogin:NO];
}


-(void)toggleProductionSwitch:(id)sender
{
    if (productionswitch.isOn) {
        //serverlabel.text = [NSString stringWithFormat:@"You will be signed in to %@", [gZZ server:YES]];
        [serverlabel setNeedsDisplay];
    } else {
        //serverlabel.text = [NSString stringWithFormat:@"You will be signed in to %@", [gZZ server:NO]];
        [serverlabel setNeedsDisplay];        
    }
}


-(void) loginError
{
    [loginactivity stopAnimating];
    errlabel.text = @"Username or password was not valid";
    [errlabel setNeedsDisplay];
    _signinbutton.enabled = YES;
    [_signinbutton setNeedsDisplay];
    return;   
}


-(void)signin:(id)sender
{
    MLOG(@"signin");
    
    [_usernametext resignFirstResponder];
    [_passwordtext resignFirstResponder];
    
    NSString *username = _usernametext.text;
    NSString *pwd = _passwordtext.text;
    
    if (username.length == 0) {
        errlabel.text = @"You did not provide a username";
        [errlabel setNeedsDisplay];
        return;
    }
    
    if (pwd.length == 0) {
        errlabel.text = @"You did not provide a password";
        [errlabel setNeedsDisplay];
        return;
    }
    
    errlabel.text = @"";
    [errlabel setNeedsDisplay];
    
    _signinbutton.enabled = NO;
    [_signinbutton setNeedsDisplay];
    
    [loginactivity startAnimating];
    
    _username = [[NSString alloc]initWithString:username];
    _password = [[NSString alloc]initWithString:pwd];
    
    
    // kick off timer to do login (allows interface to refresh)
    //[NSTimer scheduledTimerWithTimeInterval: .1 target: self selector: @selector(handleLoginTimer:) userInfo: nil repeats: NO];
    
    //send call to server
    [ZZSession loginWithUsername:_username 
                             pwd:_password 
                         success:^{
                             // have new authenticated user
                             MLOG(@"have newly authenticated user");
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"Login" object:self];
                             [parent doneLogin:self didLogin:YES];
                         } 
                         failure:^(NSError *error) {
                             [self loginError];
                             return;
                         }
     ];
}

-(void)loginWithFacebook:(id)sender
{
    MLOG(@"attempt login with facebook");
    
    // These are OBJ-C BLOCKS you can read about them here: http://thirdcog.eu/pwcblocks/
    // they are just like javascript closures
    [loginactivity startAnimating];
    [[FacebookSessionController sharedController] 
     authorizeSessionWithSuccessBlock:^{ 
         // Notify controller of switch position change
         MLOG(@"Facebook Session Authorized, Attempting to login with Facebook");
         [ZZSession logout];
         [ZZSession loginWithFacebookWithSuccessBlock:^{
             // have new authenticated user
             MLOG(@"We have a facebook authenticated user");             
             [parent doneLogin:self didLogin:YES];             
            } 
                                              failure:^(NSError *error) {
                                                  [self loginError];
                                                  return;
                                              }
          ];
     } 
     
     onFailure:^{
         // User denied access to FB account, set switch to NO no need to notify controller
         MLOG(@"Facebook Session NOT Authorized, Unable to login with Facebook");                     
         [[[UIAlertView alloc] initWithTitle:@"Facebook" 
                                     message: NSLocalizedString( @"We need your authorization to share on Facebook. Please try again.", @"Error message when user did not authorize access to FB account")
                                    delegate:self 
                           cancelButtonTitle:@"OK" 
                           otherButtonTitles:nil] show];
     }
     ];    
}

#pragma mark UIViewPicker
// returns the # of columns in picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[ZZAPIClient sharedClient]devServerArray].count;
}



// returns width of column and height of row for each component. 
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse. 
// If you return back a different object, the old one will be released. the view will be centered in the row rect  
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[ZZAPIClient sharedClient] devServerArray] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSURL *serverURL = [NSURL URLWithString:[[[ZZAPIClient sharedClient] devServerArray] objectAtIndex:row]];
    [ZZAPIClient sharedClient].baseURL = serverURL;
}

@end
