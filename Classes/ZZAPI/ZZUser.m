//
//  ZZUser.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/31/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZGroup.h"
#import "ZZAPIClient.h"
#import "albums.h"
#import "ZZUser.h"

@implementation ZZUser

@synthesize user_id;
@synthesize my_group_id;
@synthesize username;
@synthesize profile_photo_url;
@synthesize first_name;
@synthesize last_name;
@synthesize email;
@synthesize automatic;
@synthesize auto_by_contact;

@synthesize sharePermission;

//For KVC make sure identites gets set to ZZIDentities object
-(void) setValue:(id)value forKey:(NSString *)key
{
    if([key isEqualToString:@"identities"]){
        identities = [[ZZIdentities alloc] initWithDictionary:value];
    } else {
        [super setValue:value forKey:key];
    }
}

//For KVC. "id" is not a valid key because it is a reserved word
//so we replace id with user_id
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if([key isEqualToString:@"id"]){
        user_id = [value unsignedLongLongValue];        
    }else [super setValue:value forUndefinedKey:key];
}

#pragma mark - NSCoding protocol
- (id) initWithCoder:(NSCoder *)decoder
{	
    self = [super init ];
    if( self ){
        user_id             = [[decoder decodeObjectForKey:@"user_id"] unsignedLongLongValue];
        my_group_id         = [decoder decodeObjectForKey:@"my_group_id"];
        username            = [decoder decodeObjectForKey:@"username"];
        profile_photo_url   = [decoder decodeObjectForKey:@"profile_photo_url"];
        first_name          = [decoder decodeObjectForKey:@"first_name"];
        last_name           = [decoder decodeObjectForKey:@"last_name"];
        email               = [decoder decodeObjectForKey:@"email"];
        automatic           = [[decoder decodeObjectForKey:@"automatic"] boolValue];
        auto_by_contact     = [[decoder decodeObjectForKey:@"auto_by_contact"] boolValue];
        identities          = [decoder decodeObjectForKey:@"identities"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:user_id] forKey:@"user_id"];
    [encoder encodeObject:my_group_id forKey:@"my_group_id"];
    [encoder encodeObject:username forKey:@"username"];
    [encoder  encodeObject:profile_photo_url forKey:@"profile_photo_url"];
    [encoder encodeObject:first_name  forKey:@"first_name"];
    [encoder encodeObject:last_name forKey:@"last_name"];
    [encoder encodeObject:email forKey:@"email"];
    [encoder encodeObject:[NSNumber numberWithBool:automatic] forKey:@"automatic"];
    [encoder encodeObject:[NSNumber numberWithBool:auto_by_contact] forKey:@"auto_by_contact"] ;
    [encoder encodeObject:identities forKey:@"identities"];
} 



-(id)initWithUser:(ZZUser*)user
{
    self = [super init];
    if (self && user) {
        user_id = user.user_id;
        my_group_id = user.my_group_id;
        if (user.username)
            username = [NSString stringWithString:user.username];
        if (user.profile_photo_url && ![user.profile_photo_url isKindOfClass:[NSNull class]])
            profile_photo_url = [NSString stringWithString:user.profile_photo_url];
        if (user.first_name)
            first_name = [NSString stringWithString:user.first_name];
        if (user.last_name)
            last_name = [NSString stringWithString:user.last_name];
        if (user.email)
            email = [NSString stringWithString:user.email];
        automatic = user.automatic;
        auto_by_contact = user.auto_by_contact;
        sharePermission = user.sharePermission;
    }
    return self;
}

//
// Returns a properly formated "First" user name.
// it handles the cases where there is only first or last
// The possesive flag adss the appropriate suffix.
//

-(NSString*) displayFirstName
{
    NSString *name = first_name;
    if (name.length == 0) {
        name = last_name;
    }
    return name; 
}

-(NSString*) displayPossesiveFirstName
{
    NSString *name = [self displayFirstName];
    if ([name hasSuffix:@"s"])
        name = [name stringByAppendingString:@"'"];
    else
        name = [name stringByAppendingString:@"'s"];

    return name; 
}


//
// Returns "First Last"
//

-(NSString*) displayName
{
        NSString *name = [NSString stringWithFormat:@"%@ %@", first_name, last_name ];
        return name;
}

//
// First Name or Me for logged in user
//
-(NSString*) displayNameOrMe{
    if ( user_id == [ZZSession currentUser].user_id) {
        return @"Me";
    }
    return [self displayName ];
}

//
// Returns a nicely formated "First Last" name string
// it handles spaces and formatting correctly even if
// first or last are missing.
//
-(NSString*)name
{
    NSString* name = NULL;
    
    if(first_name || last_name) {
        
        if (first_name && first_name.length > 0 && last_name && last_name.length > 0)
            name = [NSString stringWithFormat:@"%@ %@", first_name, last_name];
        else if (first_name && first_name.length > 0)
            name = first_name;
        else if (last_name&& last_name.length > 0)
            name = last_name;
    }    
    return name;
}

//# Gets all groups the user.
//#
//# This is called as (GET):
//#
//# /zz_api/users/groups/all
//#
//# Executed in the context of the current signed in user
//#
//# Input:
//#
//# Returns an array of all the users groups.  See zz_api_info for details.
//#
//# [
//#   hash of group - see zz_api_info
//# ...
//# ]
-(NSArray *)getGroups
{   
     
//    ASIHTTPRequest *request = [self createGETRequest:[self createURL:ZZAPI_GROUP_GET_FOR_USER_URL  ssl:NO]];    
//    [request startSynchronous];
//    
//    int result = [self decodeRequestStatus:request message:@"Getting All Groups For logged in user"];
//    if (result == ZZAPI_SUCCESS ){
//        NSArray *groups= [self decodeRequestResponseAsArray:request message:@"Getting All Groups For logged in user"];
//        if( groups ){
//            NSMutableArray *zzGroupArray = [[NSMutableArray alloc] init];
//            for( int i=0; i< groups.count; i++){
//                ZZGroup *newGroup = [[ZZGroup alloc] initWithNSDictionary:[groups objectAtIndex: i]];
//            [zzGroupArray addObject: newGroup];
//            }
//            return zzGroupArray;
//        }
//    }
    return NULL;
}




/*
# Finds or creates users.
#
# This will find existing users and in the email case create automatic users
# for emails that do not map to a current user. Finding by user_ids and user_names
# do not auto create users, only via email.  For emails, if the user is found
# we return it with the additional email context added to that user object.  If the
# email user is not found we create a new automatic users.  You can specify the
# First, Last name to user by specifying the fully qualified email such as:
# Joe Smith <joe_smith@somewhere.com>.  This will result in a user with the first name
# set to Joe, and last name set to Smith, email set to joe_smith@somewhere.com
#
# This is called as (POST):
#
# /zz_api/users/find_or_create
#
# This call requires the caller to be logged in.
#
# Input:
# {
#   :user_ids => [ array of user ids to find ],
#   :user_names => [ array of user names to find ],
#   :emails => [ array of emails to find or create ],
# }
#
#
# Returns:
# fetches and returns all users found or created in the form
#
# [
#   user_info_hash - the hash containing the user info as returned in the user info call
#   ...
# ]
#
*/


+(NSArray*)findUsers:(NSArray*)userIDs userNames:(NSArray *)userNames emails:(NSArray *)emails error:(NSError **) anError
{
    NSArray *users = nil;
    NSArray *emailsNotFound = nil;
    
    [ZZUser findOrCreateUsers:userIDs userNames:userNames emails:emails findOnly:YES users:&users emailsNotFound:&emailsNotFound error:anError];
    
    return users;
}


+(NSArray*)findOrCreateUsers:(NSArray*)userIDs userNames:(NSArray*)userNames emails:(NSArray*)emails error:(NSError**) anError
{
    NSArray *users = nil;
    NSArray *emailsNotFound = nil;
    
    [ZZUser findOrCreateUsers:userIDs userNames:userNames emails:emails findOnly:NO users:&users emailsNotFound:&emailsNotFound error:anError];
    
    return users;    
}


+(void)findOrCreateUsers:(NSArray*)userIDs userNames:(NSArray*)userNames emails:(NSArray*)emails findOnly:(BOOL)findOnly users:(NSArray**)users emailsNotFound:(NSArray**)emailsNotFound error:(NSError**) anError
{
//    // base level find_or_create call
//    
//    // create the request body 
//    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
//    if( userIDs ){
//        [body setValue: userIDs   forKey: @"user_ids"];
//    }else{
//        [body setValue: [NSMutableArray array]   forKey: @"user_ids"];
//    }
//    if( userNames ){
//        [body setValue: userNames forKey: @"user_names"];
//    }else{
//        [body setValue: [NSMutableArray array] forKey: @"user_names"];
//    }
//    if( emails ){
//        [body setValue: emails    forKey: @"emails"];
//    }else{
//        [body setValue: [NSMutableArray array]     forKey: @"emails"];        
//    }
//    
//    if (findOnly) {
//        // set the create flag to FALSE (the default is TRUE)
//        [body setValue:[NSNumber numberWithBool:NO] forKey:@"create"];
//    }
//    
//    ZZUser *emptyUser = [[ZZUser alloc]init];
//    
//    //create and send the request synchronously
//    ASIHTTPRequest *request = [emptyUser createPOSTRequest:[emptyUser createURL:ZZAPI_FIND_OR_CREATE_USERS  ssl:NO] body:body];    
//    [request startSynchronous];
//    
//    int result = [emptyUser decodeRequestStatus:request message:@"Find or create users" ];
//    if (result == ZZAPI_SUCCESS ){
//        NSDictionary *response = [emptyUser decodeRequestResponseAsDictionary:request message:@"Find or create users"];
//        
//        NSArray *userDictionaries = [response objectForKey:@"users"];
//        NSMutableArray *r_users = [[NSMutableArray alloc] init];
//        for(int i=0; i < userDictionaries.count; i++){
//            ZZUser *user = [[ZZUser alloc] initWithNSDictionary:[userDictionaries objectAtIndex:i]];
//            [r_users addObject: user];
//        }  
//        *users = r_users;
//        
//        NSMutableArray *r_emailsNotFound = [[NSMutableArray alloc] init];
//        NSDictionary *errors = [response objectForKey:@"not_found"];
//        if (errors) {
//            NSArray *emails = [errors objectForKey:@"emails"];
//            if (emails) {
//                for(int i=0; i < emails.count; i++){
//                    NSDictionary *emailEntry = [emails objectAtIndex:i];
//                    if (emailEntry) {
//                        NSString *token = [emailEntry objectForKey:@"token"];
//                        [r_emailsNotFound addObject:token];
//                    }
//                } 
//            }
//        }
//        *emailsNotFound = r_emailsNotFound;
//        
//        return;
//    }
//    
//    *anError = emptyUser.lastCallError;
//    MLOG(@"ZZUsers:findOrCreateUsers error: %@", *anError);
}  


-(ZZIdentities *) identities
{
    return identities;
}



-(BOOL)getAlbumSetWithSuccessBlock:(void (^)(ZZAlbumSet *albumSet))success     
                           failure:(void(^)(NSError *error))failure;

{
    ZZAlbumInfo *cachedAlbumInfo = [ZZCache getCachedAlbumInfoForUser: self];
    if( cachedAlbumInfo  && ![ZZCache isAlbumInfoStale:cachedAlbumInfo ]){
        
    }else{    
        [[ZZAPIClient sharedClient] getAlbumInfoForUser:self 
                                                success:^(ZZAlbumInfo *albumInfo) {
                                                    
                                                }
                                                failure:^(NSError *error) {
                                                    
                                                }];
    }   
    return YES;
}
@end
