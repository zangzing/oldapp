//
//  UnitTest.h
//  UnitTest
//
//  Created by Mauricio Alvarez on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import "Moment.h"
#import "NameGenerator.h"

#ifndef ZZBASETEST_DEFS
#define ZZBASETEST_DEFS
#define MTESTINGUSER        @"mauricio"
#define MTESTINGPASSWORD    @"azucar"
#endif

@interface MBaseTest : GHAsyncTestCase{
    
    
    ZZSession *_session;
    NameGenerator *_nameGenerator;
}

@property (nonatomic,readonly) NameGenerator *nameGenerator;
-(BOOL)login;
-(BOOL)login:(void (^)(void))success 
     failure:(void(^)(void))failure;

@end
