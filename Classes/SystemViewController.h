//
//  SystemViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 2/6/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZSystem.h"
#import "ZZBaseViewController.h"

@interface SystemViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UINavigationBar *_navBar;
    UITableView *_systemStats;
    UIButton *_updateButton;
    
    NSDictionary *_sysData;

    NSNumberFormatter *_formatter;
    NSTimer *_timer;
    

    ZZSystem *_systemZZAPI;
}

@property (nonatomic, retain) IBOutlet  UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet  UITableView *systemStats;
@property (nonatomic, retain) IBOutlet  UIButton *updateButton;


@end
