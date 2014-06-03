//
//  Login.h
//  ZangZing
//
//  Created by Phil Beisel on 8/20/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZBaseViewController.h"


@class SettingsViewController;

@interface LoginViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
UIPickerViewDelegate, UIPickerViewDataSource  > {
    
    UINavigationBar *titlebar;
    UITableView *logintable;
    UIActivityIndicatorView *loginactivity;
    UILabel *errlabel;
    UILabel *serverlabel;
    UISwitch *productionswitch;
    UIButton * _fbButton;
    
    NSString *_username;
    NSString *_password;
    UITextField *_usernametext;
    UITextField *_passwordtext;
    UIButton *_signinbutton;
    UIPickerView *_serverPicker;
    
    SettingsViewController *__unsafe_unretained parent;
}

@property (nonatomic, strong) IBOutlet UILabel *errlabel;
@property (nonatomic, strong) IBOutlet UILabel *serverlabel;
@property (nonatomic, strong) IBOutlet UINavigationBar *titlebar;
@property (nonatomic, strong) IBOutlet UITableView *logintable;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loginactivity;
@property (nonatomic, strong) IBOutlet UISwitch *productionswitch;
@property (nonatomic, strong) IBOutlet UIPickerView *serverPicker;
@property(nonatomic, unsafe_unretained) SettingsViewController *parent;

-(void)loginWithFacebook:(id)sender;


@end
