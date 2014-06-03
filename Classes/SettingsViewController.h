//
//  SettingsViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 8/20/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "ZZTabBar.h"

#import "SelectAlbumViewController.h"

@class LoginViewController;

@interface SettingsViewController : ZZUIViewController <ZZTabBarViewController, UIAlertViewDelegate>  {
    
    UILabel *versionlabel;
    UILabel *slabel;
    UIButton *signinbutton;
    UIButton *signoutbutton;
    UINavigationBar *titlebar;
    UILabel *networklabel;
    UISwitch *uploadWifiOnlySwitch;
    
    UILabel *uploadstatus;
    UIProgressView *uploadprogress;
    UIView *uploadstatusview;
    
    UIButton *testbutton;
    UIButton *pushlogbutton;
    UIButton *clearlogbutton;
    
    UILabel *memLabel;
    UILabel *bytesLeftLabel;
    
    UIButton *systemStatsButton;
    
    NSTimer *_timer;
}

@property (nonatomic, strong) IBOutlet UILabel *versionlabel;
@property (nonatomic, strong) IBOutlet UILabel *slabel;
@property (nonatomic, strong) IBOutlet UIButton *signinbutton;
@property (nonatomic, strong) IBOutlet UIButton *signoutbutton;
@property (nonatomic, strong) IBOutlet UINavigationBar *titlebar;
@property (nonatomic, strong) IBOutlet UISwitch *uploadWifiOnlySwitch;

@property (nonatomic, strong) IBOutlet UILabel *uploadstatus;
@property (nonatomic, strong) IBOutlet UIProgressView *uploadprogress;
@property (nonatomic, strong) IBOutlet UIView *uploadstatusview;

@property (nonatomic, strong) IBOutlet UIButton *testbutton;
@property (nonatomic, strong) IBOutlet UIButton *pushlogbutton;
@property (nonatomic, strong) IBOutlet UIButton *clearlogbutton;

@property (nonatomic, strong) IBOutlet UILabel *memLabel;
@property (nonatomic, strong) IBOutlet UILabel *bytesLeftLabel;

@property (nonatomic, strong) IBOutlet UIButton *systemStatsButton;

-(void)updateMemory;
-(void)updateUploadStatus;

-(void)setLoginLabel;
-(void)doneLogin:(LoginViewController *)loginViewController didLogin:(BOOL)didLogin;

@end
