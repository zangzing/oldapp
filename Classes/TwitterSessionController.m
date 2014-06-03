//
//  FacebookSessionController.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 2/27/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//
#import "zzglobal.h"
#import "TwitterSessionController.h"



@implementation TwitterSessionController

- (id) init
{
    self = [super init];
    if( self ){
        _identities = [ZZSession currentUser].identities;
        return self;
    }
    return nil;
}

-(BOOL) authorized
{
    
    if( [_identities credentialsValid: ZZIdentityServiceFacebook] == YES ){
        return YES;
    }else{
        return NO;
    }
}

-(void) authorizeSession:(void(^)(void))onSuccess  onFailure:(void(^)(void))onFailure
{
    if( [_identities credentialsValid: ZZIdentityServiceFacebook] == NO){        
        //User does not have a facebook token
    }
}


    //    MLOG(@"Facebook session established, user logged into facebook, updating identities");   
    //    [_identities updateCredentials:ZZIdentityServiceFacebook credentials:[_facebook accessToken]];
    //if( _onSuccess ){
    //    _onSuccess();
    //}


- (void)getAccounts 
{
    ACAccountStore *_accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeTwitter = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [_accountStore requestAccessToAccountsWithType:accountTypeTwitter
                             withCompletionHandler:^(BOOL granted, NSError *error) {
                                 if(granted) {
                                      MLOG(@"Twitter Account Store Access Granted");
                                     dispatch_sync(dispatch_get_main_queue(), ^{
                                         NSArray *_accounts = [_accountStore accountsWithAccountType:accountTypeTwitter];
                                         MLOG(@"Retrieved Twitter Accounts %@",_accounts);
                                         NSInteger accounts_count = [_accounts count];
                                         if( accounts_count <= 0 ){
                                             //No twitter accounts, display setup twitter account message           
                                         }else if( accounts_count == 1){
                                             // There is only one account, use it.                                             
                                         }else{
                                             // There are multiple Twitter accounts display a list
                                         }
                                     });
                                }
                             }];
}

@end
