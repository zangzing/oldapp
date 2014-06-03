//
//  UploadDiagnosticsViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 11/21/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadDiagnosticsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *log;
    UINavigationBar *navbar;

    UILabel *statuslabel1;
    UILabel *statuslabel2;
    UILabel *statuslabel3;
    
    int _logcount;
}

@property (nonatomic, strong) IBOutlet UITableView *log;
@property (nonatomic, strong) IBOutlet UINavigationBar *navbar;
@property (nonatomic, strong) IBOutlet UILabel *statuslabel1;
@property (nonatomic, strong) IBOutlet UILabel *statuslabel2;
@property (nonatomic, strong) IBOutlet UILabel *statuslabel3;

-(void)refresh;

@end
