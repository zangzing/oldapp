//
//  SplashViewController.h
//  Moment
//
//  Created by Mauricio Alvarez on 5/22/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "MBaseViewController.h"

@class SplashViewController;

@protocol SplashDelegate <NSObject>

@optional
- (void)splashScreenDidAppear:(SplashViewController *)splashScreen;
- (void)splashScreenWillDisappear:(SplashViewController *)splashScreen;
- (void)splashScreenDidDisappear:(SplashViewController *)splashScreen;

@end

@interface SplashViewController : MBaseViewController

@property (nonatomic, retain) UIImage *splashImage;
@property (nonatomic, assign) BOOL showsStatusBarOnDismissal;
@property (nonatomic, assign) IBOutlet id<SplashDelegate> delegate;

- (void)hide;

@end

