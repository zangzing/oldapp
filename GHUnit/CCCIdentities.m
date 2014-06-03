//
//  CCCIdentities.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/8/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZBaseTest.h"
#import "ZZIdentities.h"
#import "FacebookSessionController.h"


@interface CCCIdentities : ZZBaseTest
{
    ZZIdentities *identities;
}
@end

@implementation CCCIdentities


- (void)setUp
{
    [super setUp];
    [self login];
    identities = [[ZZIdentities alloc] initWithStandardServices];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}



-(void) testAAAInitWithStandardIdentities
{
    STAssertNotNil( identities, @"Identities is null, unable to init with standard services");
    STAssertFalse( [identities hasCredentials:ZZIdentityServiceGoogle], @"Identities inited with the standard services should only have ids for fb and twitter. Google returned true");                  
}

-(void) testBBBUpdateFacebookIdentity
{
    NSDictionary *fbId = [identities  updateCredentials:ZZIdentityServiceFacebook credentials:@"BOGUS-CREDENTIAL-STRING"];
    STAssertNotNil( fbId , @"Update credentials returns a valid NSDictonary");
    STAssertTrue([identities hasCredentials:ZZIdentityServiceFacebook], @"The identities should have Facebook Credentials after facebook update");
    STAssertFalse([identities credentialsValid:ZZIdentityServiceFacebook], @"The identities should have Invalid Facebook Credentials after facebook update");
    FacebookSessionController *fbController = [[FacebookSessionController alloc] init];
    STAssertNotNil(fbController, @"FacebookController cannot initialize facebook session");
    //  [fbController authorizeSession];
}


@end
