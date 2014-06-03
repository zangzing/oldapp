//
//  FacebookSessionController.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 2/27/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//
#import "Moment.h"
#import <Accounts/Accounts.h>


static FacebookSessionController *sharedController = nil;

@implementation FacebookSessionController
@synthesize facebook=_facebook;

+(FacebookSessionController *) sharedController
{
    
    static FacebookSessionController *sharedController;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedController = [[self alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:FACEBOOK_DEFAULTS_TOKEN_KEY] 
            && [defaults objectForKey:FACEBOOK_DEFAULTS_EXPDATE_KEY]) {
            sharedController.facebook.accessToken = [defaults objectForKey:FACEBOOK_DEFAULTS_TOKEN_KEY];
            sharedController.facebook.expirationDate = [defaults objectForKey:FACEBOOK_DEFAULTS_EXPDATE_KEY];
        }
    });
    return sharedController;
}

- (id) init
{
    self = [super init];
    if( self ){
        _facebook = [[Facebook alloc] initWithAppId: FACEBOOK_APP_ID_STRING 
                                    urlSchemeSuffix: FACEBOOK_SCHEME_SUFFIX_STRING 
                                        andDelegate:self];
       
        MLOG(@"Facebook Session Controller Initialized FACEBOOK_URL_SCHEME_IS %@", FACEBOOK_URL_SCHEME_STRING);
        return self;
    }
    return nil;
}

-(BOOL) authorized
{
    if([ZZSession currentSession] && 
       [[ZZSession currentUser].identities credentialsValid: ZZIdentityServiceFacebook] == YES){
        return YES;
    }
    return [_facebook isSessionValid];
}

-(void) authorizeSessionWithSuccessBlock:(void(^)(void))onSuccess  onFailure:(void(^)(void))onFailure
{
    //Is user logged in and does she have authorized FB
    if([ZZSession currentSession] && 
       [[ZZSession currentUser].identities credentialsValid: ZZIdentityServiceFacebook] == YES ){
        onSuccess();
        return;
    }
    
    //Is local fb session authorized
    if( [_facebook isSessionValid] ){
        onSuccess();
        return;
    }
    //User does not have a facebook token neither local nor in the server
    
    //authorize local _facebook session 
    _onSuccess = [onSuccess copy];
    _onFailure = [onFailure copy];
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_photos",
                            @"user_photo_video_tags",
                            @"friends_photo_video_tags",
                            @"friends_photos",
                            @"publish_stream",
                            @"offline_access",
                            @"read_friendlists",
                            @"email",
                            nil];
    [_facebook authorize:permissions];
}

-(NSString *)credentials
{
    return _facebook.accessToken;
}

// Used to clear all facebook credentials from defaults
// used for logout mainly
-(void) clearCredentials
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:FACEBOOK_DEFAULTS_TOKEN_KEY];
    [defaults removeObjectForKey:FACEBOOK_DEFAULTS_EXPDATE_KEY];
    [defaults synchronize];
    DLOG(@"CredentialsCleared");
}

-(BOOL) handleOpenURL:url
{
    return [_facebook handleOpenURL:url];
}

#pragma mark Facebook Session delegate

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:FACEBOOK_DEFAULTS_TOKEN_KEY];
    [defaults setObject:[_facebook expirationDate] forKey:FACEBOOK_DEFAULTS_EXPDATE_KEY];
    [defaults synchronize];
    DLOG(@"Facebook session established, user logged into facebook, updating identities");   
    
    //If there is a logged in user, update the identies
    if([ZZSession currentSession] ){
        [ [ZZSession currentUser].identities updateCredentials:ZZIdentityServiceFacebook 
                                                   credentials:[_facebook accessToken]
                                                   success:^{
                                                       DLOG(@"CurrentUser identities updated with recently authorized fb credentials");
                                                       if( _onSuccess ){
                                                           _onSuccess();
                                                       }
                                                   } failure:^(NSError *error) {
                                                       DLOG(@"ERROR CurrentUser identities  could not updated with fb credentials %@", error);
                                                       if( _onFailure ){
                                                           _onFailure();
                                                       }
                                                   }
         ];
    } else {
        if( _onSuccess ){
            _onSuccess();
        }
    }
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    DLOG(@"Facebook user did not login.");
    if( _onFailure ){
        _onFailure();
    }
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt
{
    DLOG(@"Facebook token extended, user re-authorized us on facebook");
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    DLOG(@"Facebook user did not logout");
    [self clearCredentials];
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    DLOG(@"Facebook Session Invalidated");

}


- (void)getAccounts 
{
//    ACAccountStore *_accountStore = [[ACAccountStore alloc] init];
//    ACAccountType *accountTypeTwitter = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    [_accountStore requestAccessToAccountsWithType:accountTypeTwitter
//                             withCompletionHandler:^(BOOL granted, NSError *error) {
//                                 if(granted) {
//                                     dispatch_sync(dispatch_get_main_queue(), ^{
//                                         NSArray *_accounts = [_accountStore accountsWithAccountType:accountTypeTwitter];
//                                         MLOG(@"Retrieved Twitter Accounts %@",_accounts);
//                                     });
//                                 }
//                             }];
}


#pragma mark Facebook Request Delegate
/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    
}



@end
