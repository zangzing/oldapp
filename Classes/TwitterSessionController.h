//
//  TwitterSessionController.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 2/27/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "ZZAPI.h"

#ifndef TWITTER_DEFS
#define TWITTER_DEFS
// Two levels of preprocessor stringizer operands to make
// values of build settings macros into NSString *

#endif


@interface TwitterSessionController : NSObject 
{
    ZZIdentities *_identities;
    void(^_onSuccess)();
    void(^_onFailure)();
}

@property (nonatomic, readonly) BOOL authorized;

-(id) init;
-(void) authorizeSession:(void(^)(void))onSuccess  onFailure:(void(^)(void))onFailure;
-(void) getAccounts;

@end
