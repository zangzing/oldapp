//
//  DDDActivity.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/6/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"
#import "MBaseTest.h"




@interface Suite200Activity : MBaseTest

@end

@implementation Suite200Activity
- (void)setUp
{
    [super setUp];
        
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test100Login
{
    [self login];
}



- (void)test200GetActivity
{   
    if( ![ZZSession currentSession] ){
        GHFail(@"Must be logged in to run test200GetActivity");
    }
    
    [self prepare];
    [[ZZAPIClient sharedClient] getActivityForUser:[ZZSession currentUser].user_id 
                                           success:^(NSArray *activity){                                               
                                               
                                               
                                               GHAssertNotNil( activity, @"Activity Array is Nil");
                                               [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test200GetActivity)];                                           
                                           } 
                                           failure:^(NSError *error){
                                               [self notify:kGHUnitWaitStatusFailure forSelector:@selector(test200GetActivity) ];
                                           }
     ];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
}
@end
