//  main.m
//  zziphone
//
//  Created by Phil Beisel on 7/11/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "Moment.h"
#import "MomentAppDelegate.h"

int main(int argc, char *argv[]) {
	
    @autoreleasepool {
    
        MLOG(@"---------------- MOMENT START ---------------------");
        MLOG(@"Moment Version           : %@", [Moment version]);
        MLOG(@"Device Name              : %@", [[UIDevice currentDevice] name]);
        MLOG(@"Device Localized Model   : %@", [[UIDevice currentDevice] localizedModel]);
        MLOG(@"Device System Name       : %@", [[UIDevice currentDevice] systemName]);
        MLOG(@"Device System Version    : %@", [[UIDevice currentDevice] systemVersion]);
        
        //Initialize Analitycs
        [[MAnalytics defaultAnalytics] startEvents];
        
        //gAlbums = [[Albums alloc] init];
        //gPhotoUploader = [[PhotoUploader alloc]init];
        
        //[gZZ start];

        int retVal = UIApplicationMain(argc, argv, nil, @"MomentAppDelegate" );
        return 0;
    }
}

