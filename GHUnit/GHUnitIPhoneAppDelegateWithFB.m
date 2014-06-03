//
//  GHUnitIPhoneAppDelegateWithFB.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/9/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "GHUnitIPhoneAppDelegateWithFB.h"
#import "MomentAppDelegate.h"
#import "FacebookSessionController.h"
#import "Moment.h"

@implementation GHUnitIPhoneAppDelegateWithFB

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self application:application handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{

    NSString *zzScheme = ZANGZING_URL_SCHEME;
    NSString *fbScheme = FACEBOOK_URL_SCHEME_STRING;
    
    MLOG(@"Url received for opening: %@",url);
    if( [url.scheme  isEqualToString:zzScheme] ){
        MLOG(@"Processing Zangzing url: %@",url);
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[url absoluteString] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //[alert show];        
    }
    if( [url.scheme  isEqualToString:fbScheme] ){
        MLOG(@"Processing Facebook url: %@",url);
        //[facebook handleOpenURL:url];
    }
    return YES;
}

 
@end
