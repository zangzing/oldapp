//
//  ActivityViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 8/29/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBaseViewController.h"
#import "ZZTabBar.h"
#import "ZZAPI.h"
#import "TTTAttributedLabel.h"

@interface ActivityViewController : MBaseViewController <ZZTabBarViewController, UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableArray *_activityArray;    
    UITableView *_activityTable;
    NSInteger _activityCount;
    
 
   
    //for date formatting
    NSDateFormatter *_mdf;
    NSDateFormatter *_dateFormatter;
    
}

@property (nonatomic, retain) IBOutlet UITableView *_activityTable;
@end
