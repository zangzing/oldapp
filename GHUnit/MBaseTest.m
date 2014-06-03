//
//  UnitTest.m
//  UnitTest
//
//  Created by Mauricio Alvarez on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "MBaseTest.h"
#import "Moment.h"

@implementation MBaseTest

- (void)login
{
    [self prepare];
    [self login:^{[self notify:kGHUnitWaitStatusSuccess  forSelector:@selector(test100Login)];} 
        failure:^{[self notify:kGHUnitWaitStatusFailure  forSelector:@selector(test100Login)];}];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}


-(BOOL)login:(void (^)(void))success 
     failure:(void(^)(void))failure;
{
    //Login
    NSMutableDictionary *loginParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                                        MTESTINGUSER, @"email",
                                        MTESTINGPASSWORD, @"password",
                                        nil];
    //[self prepare];
    [[ZZAPIClient sharedClient] loginWithParams:loginParams 
                                        success:^(ZZSession *session) {
                                            //[self notify:kGHUnitWaitStatusSuccess forSelector:@selector(login:failure:)];
                                            success();
                                        } 
                                        failure:^(NSError *error) {
                                            //[self notify:kGHUnitWaitStatusFailure forSelector:@selector(login:failure:)];
                                            failure();
                                        }];
   
    // [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    return YES;
}

-(void) logout
{
    [ZZSession logout];
}


-(NameGenerator *)nameGenerator
{
    if( !_nameGenerator ){
        _nameGenerator = [[NameGenerator alloc] init];
    }
    return _nameGenerator;
}


- (void)setUp
{
    [super setUp];
    
}

- (void)tearDown
{
    [super tearDown];
}




@end
