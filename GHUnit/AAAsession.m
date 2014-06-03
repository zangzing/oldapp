//
//  Identity.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "MBaseTest.h"
#import "Moment.h"


@interface AAAsession : MBaseTest{
    NSString *email;
    NSString *password;
    NSString *name;
    NSString *username;
}
@end


@implementation AAAsession


- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}




-(void)test100CreateAccount
{
    
    email =    [[[self nameGenerator] getName:NO male:NO prefix:NO postfix:NO] stringByAppendingString:@"@example.com"];
    name  =    [[self nameGenerator] getName];
    password = [[[self nameGenerator] getName:NO male:NO prefix:NO postfix:NO]stringByAppendingString:@"-PASS#$@#$WORD"];
    username = [[self nameGenerator] getName:NO male:NO prefix:NO postfix:NO];
    username = [username lowercaseString];
    MLOG(@"email:%@\n name:%@\n password:%@\n username:%@", email, name, password, username);
    NSMutableDictionary *createParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                                        email, @"email",
                                         name, @"name",
                                         password, @"password",
                                         username, @"username",
                                         [NSNumber numberWithBool:YES], @"create",
                                         nil];
    [self prepare];
    [[ZZAPIClient sharedClient] loginWithParams:createParams 
                                        success:^(ZZSession *session) {
                                            GHAssertNotNil( session, @"Return session is null, unable to login");
                                            GHAssertTrue( [session.username isEqualToString:username], @"session username:%@ was not the same as %@", session.username, username);
                                            GHAssertTrue( session.user_id>0, @"UserId is not set");
                                            GHAssertNotNil( session.user_credentials, @"User Credentials are not set");
                                            [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test100CreateAccount)];
                                            [session logout];
                                        } 
                                        failure:^(NSError *error) {
                                            [self notify:kGHUnitWaitStatusFailure forSelector:@selector(test100CreateAccount)];
                                        }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0]; 
}

- (void)test200LoginWithUsername
{   
    
    if( email == nil || password == nil ){
        //must create account first
        GHFail(@"Must create account first by running test100CreateAccount");
    }
    
    //Login
    NSMutableDictionary *loginParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                                         email, @"email",
                                         password, @"password",
                                         nil];
    [self prepare];

    [[ZZAPIClient sharedClient] loginWithParams:loginParams 
                                                             success:^(ZZSession *session) {
                                                                 GHAssertNotNil( session, @"Return session is null, unable to login");
                                                                 GHAssertTrue( [session.username isEqualToString:username], @"session username was not the same as logged in");
                                                                 GHAssertTrue( session.user_id>0, @"UserId is not set");
                                                                 GHAssertNotNil( session.user_credentials, @"User Credentials are not set");
                                                                 [session logout];
                                                                 [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test200LoginWithUsername)];
                                                             } 
                                                             failure:^(NSError *error) {
                                                                 [self notify:kGHUnitWaitStatusFailure forSelector:@selector(test200LoginWithUsername)];
                                                             }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];    
}

@end
