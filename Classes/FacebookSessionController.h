//
//  FacebookSessionController.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 2/27/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

#ifndef FACEBOOK_DEFS
#define FACEBOOK_DEFS
// Two levels of preprocessor stringizer operands to make
// values of build settings macros into NSString *
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define FACEBOOK_APP_ID_STRING @ STRINGIZE2(FACEBOOK_APP_ID)
#define FACEBOOK_SCHEME_SUFFIX_STRING @ STRINGIZE2(FACEBOOK_SCHEME_SUFFIX)
//#define FACEBOOK_URL_SCHEME 
#define FACEBOOK_URL_SCHEME_STRING @"fb" FACEBOOK_APP_ID_STRING FACEBOOK_SCHEME_SUFFIX_STRING

#define FACEBOOK_DEFAULTS_TOKEN_KEY @"FBAccessTokenKey"
#define FACEBOOK_DEFAULTS_EXPDATE_KEY @"FBExpirationDateKey"
#endif


@interface FacebookSessionController : NSObject <FBSessionDelegate, FBRequestDelegate>
{
    Facebook *_facebook;
    void(^_onSuccess)();
    void(^_onFailure)();
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, readonly) BOOL authorized;
@property (nonatomic, readonly) NSString *credentials;

+(FacebookSessionController *) sharedController;

-(id) init;
-(void) authorizeSessionWithSuccessBlock:(void(^)(void))onSuccess  onFailure:(void(^)(void))onFailure;
-(BOOL) handleOpenURL:url;
-(void) getAccounts;
-(void) clearCredentials;

@end
