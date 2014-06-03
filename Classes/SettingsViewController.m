//
//  SettingsViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 8/20/11.
//  Copyright 2011 ZangZing. All rights reserved.
//


#import "zzglobal.h"
#import "albums.h"
#import "photouploader.h"
#import "LoginViewController.h"
#import "UploadDiagnosticsViewController.h"
#import "SettingsViewController.h"
#import "SystemViewController.h"
#import "ShareListViewController.h"
#import "ZZLabel.h"
#import "Reachability.h"

#define RANDOM_INT(__MIN__, __MAX__)    ((__MIN__) + arc4random() % ((__MAX__+1) - (__MIN__)))

@implementation SettingsViewController

@synthesize versionlabel;
@synthesize slabel;
@synthesize signinbutton;
@synthesize signoutbutton;
@synthesize titlebar;
@synthesize uploadWifiOnlySwitch;

@synthesize uploadstatus;
@synthesize uploadprogress;
@synthesize uploadstatusview;

@synthesize testbutton;
@synthesize pushlogbutton;
@synthesize clearlogbutton;

@synthesize memLabel;
@synthesize bytesLeftLabel;

@synthesize systemStatsButton;


/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

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
    
    titlebar.topItem.title = @"Your Settings";
    
    versionlabel.text = [gZZ version];
    
    [self setLoginLabel];    
    [signinbutton addTarget:self action:@selector(signin:) forControlEvents:UIControlEventTouchUpInside];
    [signoutbutton addTarget:self action:@selector(signout:) forControlEvents:UIControlEventTouchUpInside];
    
    
    uploadstatusview.hidden = YES;
    //[self updateUploadStatus];
    
    
    BOOL wifiOnly = NO;
    if( [ZZSession currentSession] ){
        NSInteger w = [gZZ integerForSetting:[ZZSession currentUser].user_id setting:@"uploader_wifi_only"];
        if (w == 1)
            wifiOnly = YES;
    }
    
    [uploadWifiOnlySwitch setOn:wifiOnly];
    
    [uploadWifiOnlySwitch addTarget:self action:@selector(toggleUploadWifiOnlySwitch:) forControlEvents: UIControlEventValueChanged];

    //***
    [testbutton addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [pushlogbutton addTarget:self action:@selector(pushLog:) forControlEvents:UIControlEventTouchUpInside];
    [clearlogbutton addTarget:self action:@selector(clearLog:) forControlEvents:UIControlEventTouchUpInside];
    [systemStatsButton addTarget:self action:@selector(systemStats:) forControlEvents:UIControlEventTouchUpInside];
    
    systemStatsButton.hidden = NO;
    
    NSString *role = [ZZSession currentSession].role;
    
    if (!role) 
        systemStatsButton.hidden = YES;
    else {
        if ([role isEqualToString:@"User"] || [role isEqualToString:@"Moderator"])
            systemStatsButton.hidden = YES;
    }

    [self updateMemory];
    [self switchToView];
}


-(void)toggleUploadWifiOnlySwitch:(id)sender
{
    if( [ZZSession currentSession]){
        if (uploadWifiOnlySwitch.isOn) {
            [gZZ setIntegerForSetting:[ZZSession currentUser].user_id setting:@"uploader_wifi_only" value:1];
        } else {
            [gZZ setIntegerForSetting:[ZZSession currentUser].user_id setting:@"uploader_wifi_only" value:0];
        }
        
        [gZZ saveSettings];
    }
}


-(void)switchToView
{
    MLOG(@"SettingsViewController: switchToView");

    _timer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];

}


-(void)switchFromView
{
    MLOG(@"SettingsViewController: switchFromView");

    [_timer invalidate];
    _timer = nil;
}


-(void)setLoginLabel
{
    if([ZZSession currentSession]) {
        NSString *s = [[NSString alloc]initWithFormat:@"%@ %@",@"Signed in as",[ZZSession currentUser].username];
        slabel.text = s;
        signoutbutton.hidden = NO;
    }
    else {
        slabel.text = @"Not signed in";
        signoutbutton.hidden = YES;
    }
    
    [slabel setNeedsDisplay];
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


-(void)signin:(id)sender
{
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
    if (vc) {
        vc.parent = self;
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:vc animated:YES];
    }
}


-(void)signout:(id)sender
{
    [ZZSession logout];
    [self setLoginLabel];
}


- (void)doneLogin:(LoginViewController *)loginViewController didLogin:(BOOL)didLogin
{
    MLOG(@"doneLogin");
    
    [self dismissModalViewControllerAnimated:YES];
    
    if (didLogin) {
        [self setLoginLabel];
        self.tabBarController.selectedIndex = 0;
        
        [gV switchToView:kTABBAR_MainBar selectedTab:0 viewController:NULL];
    }
}


-(void)test:(id)sender
{

    UploadDiagnosticsViewController *vc = [[UploadDiagnosticsViewController alloc] initWithNibName:@"UploadDiagnostics" bundle:nil];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:vc animated:YES];
    return;
    
    /*
    NSString* str1= @"teststring";
    NSData* data1=[str1 dataUsingEncoding:NSUTF8StringEncoding];

    NSString* str2= @"teststring";
    NSData* data2=[str2 dataUsingEncoding:NSUTF8StringEncoding];
    
    time_t taken = (time_t) [[NSDate date] timeIntervalSince1970];

    [gPhotoUploader addPhoto:nil photoData:data1 taken:taken xdata:nil];
    [gPhotoUploader addPhoto:nil photoData:data2 taken:taken xdata:nil];

    [gPhotoUploader queuePhotos:3 albumid:3];
    */
}

-(void)testgroups
{

    NSString *name = @"ZangZingers";
    
    ZZGroup *newGroup = [ZZGroup groupWithName:name error:nil];
    
    //NSArray* mygroups = 
    [[ZZSession currentUser] getGroups];
     
    NSArray *emails = [[NSArray alloc]initWithObjects:@"pbeisel@gmail.com", nil];
     
    //NSArray *gresult = 
    [newGroup addMembers:nil userNames:nil emails:emails];
    
    NSLog(@"done test");
}

-(void)pushLog:(id)sender
{    
    
    // crash
    //NSString *x = NULL;
    //NSMutableDictionary *d = [[NSMutableDictionary alloc]init];
    //[d setObject:x forKey:x];
    
    //[self testgroups];
    //return;
    
    int logID =  RANDOM_INT(1000,10000);
    
    BOOL ok = [gZZ pushLogToS3:logID];
    
    if (ok) {
        
        NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
        [xdata setObject:[NSNumber numberWithInt:logID] forKey:@"id"];
        [ZZGlobal trackEvent:@"log.sent" xdata:xdata];
        
        NSString *msg = [NSString stringWithFormat:@"Your log file has been sent to ZangZing (#%d).", logID];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Log Sent" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 0;
        [alertView show];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Log Not Sent" message:@"Your log file could not be sent to ZangZing.  Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 0;
        [alertView show];        
    }
}


-(void)clearLog:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Clear Log" message:@"Are you sure you want to clear the log file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alertView addButtonWithTitle:@"Clear"];
    alertView.tag = 1;
    
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        // clear alert
        if (buttonIndex == 1) {
            // clear log file
            [ZZGlobal trackEvent:@"log.clear" xdata:nil];
            [MLog deleteLogFile];
        }
    }
}

-(void)systemStats:(id)sender
{
    SystemViewController *svc = [[SystemViewController alloc] initWithNibName:@"SystemView" bundle:nil];

    svc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:svc animated:YES];
}


-(void)updateUploadStatus
{
    BOOL suspended = [gPhotoUploader suspended];
    int readyCount = [gPhotoUploader readyToUploadCount];       // left to upload
    int totalCount = [gPhotoUploader totalReadyUpload];  
    
    float bytesToUpload = [gPhotoUploader bytesToUpload];
    float bytesUploaded = [gPhotoUploader bytesUploaded];
    
    //NSLog(@"bytesToUpload: %f, bytesUploaded %f", bytesToUpload, bytesUploaded);
    
    if (bytesUploaded > bytesToUpload)
        bytesToUpload = bytesUploaded;
    
    if (readyCount > 0) {
        uploadstatusview.hidden = NO;
        
        //uploadprogress.progress = (totalCount-readyCount)/totalCount;
        if (bytesToUpload > 0) {
            uploadprogress.progress = bytesUploaded/bytesToUpload;
        }
        
        uploadstatus.text = [NSString stringWithFormat:@"Uploading %d of %d Photos",(totalCount-readyCount)+1,totalCount];
        if (suspended)
            uploadstatus.text = [NSString stringWithFormat:@"%d Photos Waiting For Wifi Connection",(totalCount-readyCount)+1,totalCount];
        
        [uploadstatus setNeedsDisplay];
        
        if (bytesUploaded > 0) 
            bytesLeftLabel.text = [NSString stringWithFormat:@"%.2f MB left", (bytesToUpload-bytesUploaded) / 1024 / 1024];
        else
            bytesLeftLabel.text = @"";
        
        [bytesLeftLabel setNeedsDisplay];
    } else {
        uploadstatusview.hidden = YES;
    }
}


-(void)updateMemory
{
    NSString *mstr = [NSString stringWithFormat:@"%.2f MB (high %.2f MB) #%d", (double)[gZZ getMem]/1024/1024, (double)[gZZ getHighMem]/1024/1024, [gZZ getMemWarnings]];
    [memLabel setText:mstr];
}


- (void)handleTimer: (NSTimer*)timer 
{
    //[self updateUploadStatus];
    
    [self updateMemory];
}


@end
