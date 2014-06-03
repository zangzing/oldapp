//
//  ZZGroup.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZGroup.h"



@implementation ZZGroup

@synthesize id=_groupID;
@synthesize userID=_userID;
@synthesize user=_user;
@synthesize name=_name;
@synthesize sharePermission=_sharePermission;


//# Creates a group for the current user.
//#
//# This is called as (POST):
//#
//# /zz_api/groups/create
//#
//# Executed in the context of the current signed in user
//#
//# Input:
//#
//# {
//#   :name => the name of the group
//# }
//#
//#
//# Returns the group info - see zz_api_info
//#
+ (ZZGroup *) groupWithName:(NSString *)name error:(NSError **)anError
{
    ZZGroup *emptyGroup = [ZZGroup alloc];  //used to reach instance methods
    // create the request body 
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue: name forKey: @"name"];
        
    //create and send the request synchronously
    ASIHTTPRequest *request = [emptyGroup createPOSTRequest:[emptyGroup createURL:ZZAPI_GROUP_CREATE_URL  ssl:NO] body:body];    
    [request startSynchronous];
        
    int result = [emptyGroup decodeRequestStatus:request message:@"Creating Group in ZZGroup#initWithName"];
    if (result == ZZAPI_SUCCESS ){
        NSDictionary *newGroupHash = [emptyGroup decodeRequestResponseAsDictionary:request message:@"Creating Group in ZZGroup#initWithName"];
        ZZGroup *newGroup = [[ZZGroup alloc] initWithNSDictionary:newGroupHash];
        return newGroup;
    }
    if( anError != nil ){
        *anError = emptyGroup.lastCallError;
    }
    return NULL;
}

//
//# Gets info about the group.
//#
//# This is called as (GET):
//#
//# /zz_api/groups/:group_id
//#
//# Executed in the context of the current signed in user.
//#
//# Input:
//#
//# Returns the group info.  When the group is a wrapper around a single user
//# the user field will be present.  From this you can extract the user
//# related info.  For non wrapped groups the user field will be missing. You
//# can get detailed info about the users by calling zz_api_members
//#
//# {
//#    :id => the group id
//#    :user_id => the owning user
//#    :name => the name of the group
//#    :user => {
//#        :id => users id,
//#        :my_group_id => the group that wraps just this user,
//#        :username => user name,
//#        :profile_photo_url => the url to the profile photo, nil if none,
//#        :first_name => first_name,
//#        :last_name => last_name,
//#        :email => email for this user (this will only be present for automatic users and in cases where you looked up the user via email)
//#        :automatic => true if an automatic user (one that has not created an account)
//#        :auto_by_contact => true if automatic user and was created simply by referencing (i.e. we added automatic as result of group or permission operation)
//#                            if automatic is set and this is false it means we have a user that has actually sent a photo in on that address
//#    },
//# }
-(id) initWithID:(ZZGroupID)groupID
{
    self = [super init];
    if( self ){
        //create and send the request synchronously
        NSString *url = [NSString stringWithFormat:ZZAPI_GROUP_INFO_URL,groupID];        
        ASIHTTPRequest *request = [self createGETRequest:[self createURL:url  ssl:NO]];    
        [request startSynchronous];
        
        int result = [self decodeRequestStatus:request message:@"Getting Group Info in ZZGroup#initWithID"];
        if (result == ZZAPI_SUCCESS ){
            _serverHash = [self decodeRequestResponseAsDictionary:request message:@"Getting Group Info in ZZGroup#initWithID"];
            if( _serverHash ){
                _groupID = [[_serverHash valueForKey:@"id"] unsignedLongLongValue];
                _userID  = [[_serverHash valueForKey:@"user_id"] unsignedLongLongValue];
                _name    = [_serverHash valueForKey: @"name"];
                NSDictionary *potentialUser    = [_serverHash valueForKey: @"user"];    
                _user = [[ZZUser alloc] initWithDictionary:(NSMutableDictionary *)potentialUser];                    
                return self;
            }
        }
    }
    return NULL;
}


-(id)initWithGroup:(ZZGroup*)group
{
    self = [super init];
    if (self) {
        _groupID = group.id;
        _userID = group.userID;
        _name = [NSString stringWithString:group.name];
        _user = [[ZZUser alloc]initWithUser:group.user];
        _sharePermission = group.sharePermission;
    }
    return self;
}


- (ZZGroup*)updateName:(NSString*)newName
{
    // create the request body 
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue: newName forKey: @"name"];
    
    //create and send the request synchronously
    NSString *url = [NSString stringWithFormat: ZZAPI_GROUP_UPDATE_URL,_groupID];        
    ASIHTTPRequest *request = [self createPOSTRequest:[self createURL:url  ssl:NO] body:body];    
    [request startSynchronous];
    
    int result = [self decodeRequestStatus:request message:@"Error Setting name for ZZGroup"];
    if (result == ZZAPI_SUCCESS ){
        _serverHash = [self decodeRequestResponseAsDictionary:request message:@"Error Setting name for ZZGroup"];
        if( _serverHash ){
            _groupID = [[_serverHash objectForKey:@"id"] unsignedLongLongValue];
            _userID  = [[_serverHash objectForKey:@"user_id"] unsignedLongLongValue];
            _name    = [_serverHash valueForKey: @"name"];
            _user    = [_serverHash valueForKey: @"user"];    
            return self;
        }
    }
    return NULL;
}

//# Destroys a group for the current user.
//#
//# This is called as (DELETE):
//#
//# /zz_api/groups/:group_id
//#
//# Executed in the context of the current signed in user
//#
//#
//# Returns nothing
-(BOOL) delete{
    NSString *url = [NSString stringWithFormat: ZZAPI_GROUP_DELETE_URL,_groupID];        
    ASIHTTPRequest *request = [self createPOSTRequest:[self createURL:url  ssl:NO] body:NULL];    
    [request startSynchronous];
    
    int result = [self decodeRequestStatus:request message:@"Deleting ZZGroup"];
    if (result == ZZAPI_SUCCESS ){
        _serverHash = NULL;
        _userID  = 0;
        _groupID = 0;
        _name    = NULL;
        _user    = NULL;
        return YES;
    }
    return NO;
}


//# Get the current members of the group.
//#
//# This is called as (GET):
//#
//# /zz_api/groups/:group_id/members
//#
//# Executed in the context of the current signed in user
//#
//#
//# Returns:
//#
//# [
//# {
//#  :group_id => group we belong to,
//#  :user => see user portion of info returned from zz_api_info
//# }
//# ...
//# ]
//#
-(NSArray *)members
{
    //create and send the request synchronously
    NSString *url = [NSString stringWithFormat: ZZAPI_GROUP_GET_USERS_URL,_groupID];        
    ASIHTTPRequest *request = [self createGETRequest:[self createURL:url  ssl:NO]];    
    [request startSynchronous];
    
    int result = [self decodeRequestStatus:request message:@"Adding members to ZZGroup"];
    if (result == ZZAPI_SUCCESS ){
        NSArray *groupMembersArray = [self decodeRequestResponseAsArray:request message:@"Adding members to ZZGroup"];
        if( groupMembersArray ){
            NSMutableArray *members = [[NSMutableArray alloc] init];
            for( int i=0; i < groupMembersArray.count; i++){
                ZZUser *user = [[ZZUser alloc] initWithDictionary:[[groupMembersArray objectAtIndex:i] valueForKey:@"user"]];
                [ members addObject:user];
            }            
            return members;
        }
    }
    return NULL;
}

//# Adds members in the group.  Will create automatic users
//# for emails that do not map to a current user.
//#
//# This is called as (POST):
//#
//# /zz_api/groups/:group_id/add_members
//#
//# Executed in the context of the current signed in user
//#
//# Input:
//# {
//#   :user_ids => [ array of user ids to add ],
//#   :user_names => [ array of user names to add ],
//#   :emails => [ array of emails to add ],
//# }
//#
//#
//# Returns:
//# fetches and returns all members as in members call
//#
-(NSArray *)addMembers:(NSArray *)userIDs userNames:(NSArray *)userNames emails:(NSArray *)emails
{
   
    // create the request body 
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    if( userIDs ){
        [body setValue: userIDs   forKey: @"user_ids"];
    }else{
        [body setValue: [NSMutableArray array]   forKey: @"user_ids"];
    }
    if( userNames ){
        [body setValue: userNames forKey: @"user_names"];
    }else{
        [body setValue: [NSMutableArray array] forKey: @"user_names"];
    }
    if( emails ){
        [body setValue: emails    forKey: @"emails"];
    }else{
        [body setValue: [NSMutableArray array]     forKey: @"emails"];        
    }
    
    //create and send the request synchronously
    NSString *url = [NSString stringWithFormat: ZZAPI_GROUP_ADD_MEMBERS,_groupID];        
    ASIHTTPRequest *request = [self createPOSTRequest:[self createURL:url  ssl:NO] body:body];    
    [request startSynchronous];
    
    int result = [self decodeRequestStatus:request message:@"Adding members to ZZGroup"];
    if (result == ZZAPI_SUCCESS ){
        NSArray *groupMembersArray = [self decodeRequestResponseAsArray:request message:@"Adding members to ZZGroup"];
        if( groupMembersArray ){
            NSMutableArray *members = [[NSMutableArray alloc] init];
            for( int i=0; i < groupMembersArray.count; i++){
                ZZUser *user = [[ZZUser alloc] initWithDictionary:[[groupMembersArray objectAtIndex:i] valueForKey:@"user"]];
                [ members addObject:user];
            }            
            return members;
        }
    }
    return NULL;
}


//# Remove members from the group based on user_ids
//#
//# This is called as (DELETE):
//#
//# /zz_api/groups/:group_id/remove_members
//#
//# Executed in the context of the current signed in user
//#
//# Input:
//# {
//#   :user_ids => [
//#     user_id - the user id to delete
//#   ...
//#   ]
//# }
//#
//#
//# Returns:
//# fetches and returns all members as in get members call
//#
-(NSArray *)removeMembers:(NSArray *)userIDs
{
    // create the request body 
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue: userIDs forKey: @"user_ids"];
    
    //create and send the request synchronously
    NSString *url = [NSString stringWithFormat: ZZAPI_GROUP_REMOVE_MEMBERS_URL,_groupID];
    ASIHTTPRequest *request = [self createPOSTRequest:[self createURL:url  ssl:NO] body:body];    
    [request startSynchronous];
    
    int result = [self decodeRequestStatus:request message:@"Removing Members"];
    if (result == ZZAPI_SUCCESS ){
        NSArray *groupMembersArray = [self decodeRequestResponseAsArray:request message:@"Removing Members" ];
        if( groupMembersArray ){
            NSMutableArray *members = [[NSMutableArray alloc] init];
            for( int i=0; i < groupMembersArray.count; i++){
               ZZUser *user = [[ZZUser alloc] initWithDictionary:[[groupMembersArray objectAtIndex:i] valueForKey:@"user"]];
                [ members addObject:user];
            }            
            return members;
        }
    }
    return NULL;
}


- (id) initWithNSDictionary:(NSDictionary *)serverHash
{
    self = [super initWithNSDictionary:serverHash];
    if( self ){
        _groupID = [[serverHash objectForKey:@"id"] unsignedLongLongValue];
        _userID  = [[serverHash objectForKey:@"user_id"] unsignedLongLongValue];
        _name    = [serverHash valueForKey: @"name"];
        _user    = [serverHash valueForKey: @"user"];    
        return self;    
    }
    return NULL;
}


+ (NSString*)validName:(NSString*)name
{
    // return error string if name is not valid
    
    // cannot start with '.'
    if ([name hasPrefix:@"."]) {
        return @"Group names cannot start with the period character.";
    }
    
    // cannot contain '@'
    NSRange range = [name rangeOfString : @"@"];
    if (range.location != NSNotFound) {
        return @"Group names cannot contain the '@' character.";
    }
    
    if (name.length > kGroupNameLengthMax) {
        return [NSString stringWithFormat:@"Group names cannot be longer than %d characters.", kGroupNameLengthMax];
    }

    
    return NULL;
}



@end