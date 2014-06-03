//
//  PeopleViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 8/30/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "ZZSegmentedControl.h"
#import "ZZTabBar.h"

@interface PeopleViewController : ZZUIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, ZZSegmentedControlDelegate, ZZTabBarViewController> {
    
	UITableView *peopletable;	
    UIView *peopleselectholder;
    ZZSegmentedControl *peopleselect;
}

@property (nonatomic, strong) IBOutlet UITableView *peopletable;
@property (nonatomic, strong) ZZSegmentedControl *peopleselect;
@property (nonatomic, strong) IBOutlet UIView *peopleselectholder;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

-(IBAction) handleSwipe:(UISwipeGestureRecognizer *)recognizer; 


@end
