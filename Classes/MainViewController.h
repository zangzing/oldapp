//
//  MainViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 8/29/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZTabBar.h"

@class CameraViewController;

@interface ZZUIViewController : UIViewController {
@private
    
}

-(void)switchToView;
-(void)switchFromView;
-(void)actionView:(NSString*)action;

@end


@interface MainViewController : UIViewController <ZZTabBarDelegate, UINavigationControllerDelegate> {
    
    ZZTabBar *tabbar;           
    NSArray *_tabbarItems;      // current tabbar items
    NSDictionary *_tabbarSpec;  // current tabbar spec
    
    NSArray *_bar1;
    NSArray *_bar2;
    NSArray *_bar3; 
    NSArray *_bar4;
    NSArray *_bar5;
    
    NSDictionary *_barspec1;
    NSDictionary *_barspec2;
    NSDictionary *_barspec3;
    NSDictionary *_barspec4;
    NSDictionary *_barspec5;
    
    NSUInteger _activebar;
    NSInteger _settab;
    ZZUIViewController* _setviewcontroller;
    ZZUIViewController* _actionviewcontroller;      // current action target
    BOOL _wasfullscreen;                            // previous view
    BOOL _isfullscreen;                             // current view
    
    NSTimeInterval _timerInterval;
    NSTimer *_timer;
    UIView *_uploadingStatus;
    UILabel *_uploadingLabel;
    UIProgressView *_uploadingProgress;
    unsigned long long _uploadingPhase;
}

@property (nonatomic, strong) ZZTabBar* tabbar;

// tab bar
-(void)switchTabbar:(NSUInteger)bar selectedTab:(NSInteger)selectedTab;
-(void)switchTabbar:(NSUInteger)bar selectedTab:(NSInteger)selectedTab actionViewController:(ZZUIViewController*)actionViewController;
-(void)hideTabbar:(BOOL)hidden;
-(void)setTabbarText:(NSString*)text;

// view
-(void)switchToView:(NSUInteger)bar selectedTab:(NSInteger)selectedTab viewController:(ZZUIViewController*)viewController;
-(void)setToViewController;

// misc
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;

-(BOOL)isFullScreen;


@end

extern MainViewController *gV;
