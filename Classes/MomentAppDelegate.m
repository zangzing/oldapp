//
//  zziphoneAppDelegate.m
//  zziphone
//
//  Created by Phil Beisel on 7/11/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "Moment.h"
#import "MomentAppDelegate.h"
#import "SlideOutController.h"

#import <BugSense-iOS/BugSenseCrashController.h>
#import "FacebookSessionController.h"




@implementation MomentAppDelegate
@synthesize window;
@synthesize splashViewController;
@synthesize rootViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    //BugSenseCrashController
    NSMutableDictionary *crashID = [[NSMutableDictionary alloc]initWithCapacity:5];
    [crashID setObject:[OpenUDID value] forKey:@"UID"];
    [crashID setObject:[[UIDevice currentDevice] name] forKey:@"name"];
    [crashID setObject:[Moment version] forKey:@"version"];
    [BugSenseCrashController sharedInstanceWithBugSenseAPIKey:@"34aebcdb" userDictionary:crashID sendImmediately:YES];
    

    //Initialize Main Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];

    //Create and Customize slideOutController
    SlideOutController *slideOutController = [[SlideOutController alloc] init];
    slideOutController.title = @"SlideOutController";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: slideOutController];
#if EXPERIEMENTAL_ORIENTATION_SUPPORT
    UINavigationController *container = [[UINavigationController alloc] init];
    [container setNavigationBarHidden:YES animated:NO];
    [container setViewControllers:[NSArray arrayWithObject:navController] animated:NO];
    self.rootViewController = container;
#else
    self.rootViewController = navController;
#endif
    
    //Create & Customize SplashScreen
    self.splashViewController = [[SplashViewController alloc] init];
    self.splashViewController.showsStatusBarOnDismissal = YES;
    self.splashViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    

    // Add the view controller's view to the window and display.
    [self.window addSubview:rootViewController.view];
    [self.rootViewController presentModalViewController:self.splashViewController animated:NO];
    [self.window makeKeyAndVisible];       
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    MLOG(@"applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    MLOG(@"applicationDidEnterBackground");
    
    //[gV applicationDidEnterBackground];
    [[MAnalytics defaultAnalytics] pushEvents:YES];
    //[gZZ saveSettings];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    MLOG(@"applicationWillEnterForeground");
    
    //[gV applicationWillEnterForeground];
    [[MAnalytics defaultAnalytics] resumeEvents];
     //[gPhotoUploader applicationWillEnterForeground];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    MLOG(@"applicationDidBecomeActive");
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    
    MLOG(@"zziphoneAppDelegate:: applicationWillTerminate");
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    
    MLOG(@"applicationDidReceiveMemoryWarning");
    
    //[gZZ reportMemoryWarning];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //[gAlbums memoryWarning];
}
#pragma mark -
// 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    MLOG(@"Url received for opening: %@",url);
    if( [url.scheme  isEqualToString:ZANGZING_URL_SCHEME] ){
        MLOG(@"Processing Zangzing url: %@",url);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[url absoluteString] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //[alert show];        
        return YES;
    }
    if( [url.scheme  isEqualToString:FACEBOOK_URL_SCHEME_STRING] ){
        MLOG(@"Processing Facebook url: %@",url);
        return [[FacebookSessionController sharedController].facebook handleOpenURL:url];

    }
    return NO;
}


#pragma mark SplashScreen Delegate
- (void)splashScreenDidAppear:(SplashViewController *)splashView
{
    MLOG(@"splashScreenDidAppear!");
}

- (void)splashScreenWillDisappear:(SplashViewController *)splashView 
{
    MLOG(@"splashScreenWillDisappear!");
}

- (void)splashScreenDidDisappear:(SplashViewController *)splashView  
{
    self.splashViewController = nil;
}
#pragma mark - 



@end

