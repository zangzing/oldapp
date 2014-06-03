//
//  Suite300UserInfo.m
//  Moment
//
//  Created by Mauricio Alvarez on 5/15/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"
#import "MBaseTest.h"
@interface Suite300User : MBaseTest

@end


@implementation Suite300User

- (void)test100Login
{
    [self login];
}

-(void) test200GetUserWithId
{
    if( ![ZZSession currentSession]){
        GHFail(@"You must execute test100Login before executing this test");
    }
    
    [self prepare];
    [[ZZAPIClient sharedClient] getUserWithId:[ZZSession currentUser].user_id
                                      success:^(ZZUser *user) {
                                          GHAssertEquals([ZZSession currentUser].user_id, user.user_id, @"Returned user does not match requested user");
                                          GHAssertNotNil(user.username, @"Username should not be nil");
                                          GHAssertEqualStrings([ZZSession currentUser].username, user.username, @"Returned username does not match requested user id");
                                          [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test200GetUserWithId)]; 
                                      } failure:^(NSError *error) {
                                          [self notify:kGHUnitWaitStatusFailure forSelector:@selector(test200GetUserWithId)]; 
                                      }];
     [self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
}



@end
