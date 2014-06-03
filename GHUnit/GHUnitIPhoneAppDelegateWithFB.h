//
//  GHUnitIPhoneAppDelegateWithFB.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/9/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <GHUnitIOS/GHUnitIphoneAppDelegate.h> 

@interface GHUnitIPhoneAppDelegateWithFB : GHUnitIPhoneAppDelegate
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

@end
