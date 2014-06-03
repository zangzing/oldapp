//
//  MAnalytics.h
//  Moment
//
//  Created by Mauricio Alvarez on 5/11/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface MAnalytics : AFHTTPClient
{
    NSMutableArray *eventQueue;
    BOOL           haveStoredEvents;
    NSTimeInterval lastRun;
}

+ (MAnalytics *)defaultAnalytics;
-(void) trackEvent:(NSString*)event xdata:(NSDictionary*)xdata;
-(void) trackException:(NSString*)event exception:(NSException*)exception;
-(void) pushEvents;
-(BOOL) pushEvents:(BOOL)onlyStore;
-(void) pushStoredEvents;
-(BOOL) pushEventData:(NSData*)eventData;
-(void) startEvents;
-(void) resumeEvents;


@end
