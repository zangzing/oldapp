//
//  zziphoneAppDelegate.h
//  zziphone
//
//  Created by Phil Beisel on 7/11/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "SplashViewController.h"

#ifndef APPDELEGATE_DEFS
#define APPDELEGATE_DEFS

#define ZANGZING_URL_SCHEME  @"zangzing"

#endif



@class MainViewController;

@interface MomentAppDelegate : NSObject <UIApplicationDelegate>{
    UIWindow *window;

}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UIViewController *rootViewController;
@property (nonatomic, strong) IBOutlet SplashViewController *splashViewController;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;



@end
