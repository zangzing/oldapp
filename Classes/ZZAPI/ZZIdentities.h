//
//  ZZIdentity.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/5/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//
//  ZZIdentities is an object that belongs to a ZZUser
//  it really only makes sense for the current_user since it contains
//  their linked account info.
//
//  ZZIdentities contains a Hash of identity hashes named _identities. The
//  _identities hash is keyed using the identityServiceString
//
//  Each identity hash contains boolean flags for _hasCredentials and _credentialsValid
//  a user may query the hash through the appropriatly named methods using
//  ints or more appropriatel ZZIdentityService values to indicate interest in a specific
//  identity.
//



#import "ZZJSONModel.h"
#import "ZZBaseObject.h"


#ifndef ZZIDENTITY_DEFS

typedef enum{
    ZZIdentityServiceFacebook=0,
    ZZIdentityServiceTwitter=1,
    ZZIdentityServiceGoogle=2
} ZZIdentityService;

#define ZZAPI_SERVICE_FACEBOOK @"facebook"
#define ZZAPI_SERVICE_TWITTER  @"twitter"
#define ZZAPI_SERVICE_GOOGLE  @"google"
#endif


@interface ZZIdentities : ZZJSONModel

@property (nonatomic, strong) NSMutableDictionary *identities;

-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;


-(BOOL)updateCredentials:(ZZIdentityService)service 
             credentials:(NSString *)credentials
                 success:(void (^)(void))success 
                 failure:(void(^)(NSError *error))failure;
-(BOOL) hasCredentials:(ZZIdentityService)service;
-(BOOL) credentialsValid:(ZZIdentityService)service;

+ (NSString*) identityServiceToString:(ZZIdentityService)service;
+ (ZZIdentityService) stringToIdentityService:(NSString*)serviceStr;
@end
