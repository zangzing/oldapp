//
//  ZZIdentity.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/5/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"

NSString * const kIdentityServiceArray[]={
    ZZAPI_SERVICE_FACEBOOK,
    ZZAPI_SERVICE_TWITTER,
    ZZAPI_SERVICE_GOOGLE
};


@implementation ZZIdentities

@synthesize identities;


//
// Init the session from a dict whenever the session is coming 
// from disk or cache
//
- (id)initWithDictionary:(NSMutableDictionary *)serverJson
{
    self = [super init];
    
    if( self ){
        identities = serverJson;
        MLOG(@"Identities set from serverJson");
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder
{	
    self = [super init ];
    if( self ){
        identities       = [decoder decodeObjectForKey:@"identities"];
        MLOG(@"Loaded Identities From Cache");
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:identities forKey:@"identities"];
    MLOG(@"Saved Identities To Cache");
}

-(BOOL)updateCredentials:(ZZIdentityService)service 
                        credentials:(NSString *)credentials
                            success:(void (^)(void))success 
                            failure:(void(^)(NSError *error))failure
{
    [[ZZAPIClient sharedClient] updateIdentities:service 
                                     credentials:credentials
                                         success:^(NSDictionary *identityHash){
                                             [identities setObject:identityHash forKey:[ZZIdentities identityServiceToString: service]];
                                         } 
                                         failure:^(NSError *error){
                                             MLOG(@"Unable to update identities with service %@", [ZZIdentities identityServiceToString:service]);
                                         }];
    return YES;
}

-(BOOL) hasCredentials:(ZZIdentityService)service
{    
    NSDictionary *id = [identities objectForKey: [ZZIdentities identityServiceToString: service]];
    if( id ){       
        return [[id valueForKey:@"has_credentials"] boolValue];
    }else{
        // we are only dealing with FB and twitter for now, otherwise go get this identity
        return NO; 
    }
}
-(BOOL) credentialsValid:(ZZIdentityService)service
{
    NSDictionary *id = [identities objectForKey: [ZZIdentities identityServiceToString: service]];
    if( id ){       
        return  [[id valueForKey:@"credentials_valid"] boolValue];
    }else{
        // we are only dealing with FB and twitter for now, otherwise go get this identity
        return NO; 
    }
}


// Utility method to conver an identity service
// into a string value to be sent to the server
// The server expected values are strings not ints
+ (NSString*) identityServiceToString:(ZZIdentityService)service
{
    switch(service) {
        case ZZIdentityServiceFacebook:
            return ZZAPI_SERVICE_FACEBOOK;
        case ZZIdentityServiceTwitter:
            return ZZAPI_SERVICE_TWITTER;
        case ZZIdentityServiceGoogle:
            return ZZAPI_SERVICE_GOOGLE;
        default:
            [NSException raise:NSGenericException format:@"Unexpected ZZIdentityService."];
    }    
}


// Utility method to conver a service string into a service enum
+ (ZZIdentityService) stringToIdentityService:(NSString*)serviceStr
{
    for(int i=0; i < sizeof(kIdentityServiceArray)-1; i++)
    {
        if([(NSString*)kIdentityServiceArray[i] isEqual:serviceStr])
        {
            return (ZZIdentityService) i;
        }
    }
    [NSException raise:NSGenericException format:@"Unexpected String %@, unable to convert into ZZAPI IdentityService.", serviceStr];
    return -1;
}



@end
