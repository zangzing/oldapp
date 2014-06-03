//
//  ZZShareList.m
//  ZangZing
//
//  Created by Phil Beisel on 2/17/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"

@implementation ZZShareList


@synthesize users=_users;
@synthesize groups=_groups;
@synthesize adminUsers=_adminUsers;


-(id)initWithAlbumID:(ZZAlbumID)albumID
{
    self = [super init];
    
    if (self) {
        // make share members request
        // /zz_api/albums/:album_id/sharing_edit
        
        _albumID = albumID;
    
        MLOG(@"ZZShareList initWithAlbumID: request for: %llu", albumID);
        NSString *url = [NSString stringWithFormat:ZZAPI_ALBUM_SHARING_EDIT_URL,albumID];        
        ASIHTTPRequest *request = [self createGETRequest:[self createURL:url  ssl:NO]];    
        [request startSynchronous];

        int result = [self decodeRequestStatus:request message:@"Getting album share members in ZZShareList#initWithAlbumID"];
        if(result == ZZAPI_SUCCESS) {
            
            NSDictionary *data = [self decodeRequestResponseAsDictionary:request message:@"Getting album share members in ZZShareList#initWithAlbumID"];
            NSArray *members = [data objectForKey:@"members"];
            [self setFromMembers:members];
        }
    }
    
    return self;
}


-(void)setMembers:(NSArray*)users groups:(NSArray*)groups
{
    // sync share permissions
    // 1. find and send deletes
    // 2. find and send all viewer adds/updates
    // 3. find and send all contrib adds/updates
    
    BOOL changed = NO;
    
    //
    // find deletes
    //
    NSMutableArray *deletes = [[NSMutableArray alloc]init];
    for (ZZUser *user in _users) {
        
        BOOL add_as_delete = YES;
        for (ZZUser *new_user in users) {
            if (new_user.user_id == user.user_id) {
                add_as_delete = NO;
                break;
            }
        }
        
        if (add_as_delete) {
            [deletes addObject:user.my_group_id];
        }
    }
    
    for (ZZGroup *group in _groups) {
        
        BOOL add_as_delete = YES;
        for (ZZGroup *new_group in groups) {
            if (new_group.id == group.id) {
                add_as_delete = NO;
                break;
            }
        }
        
        if (add_as_delete) {
            changed = YES;
            [deletes addObject:[NSNumber numberWithUnsignedLongLong:group.id]];
        }
    }
    
    //
    // send deletes
    //
    for (NSNumber* delete_group in deletes) {
        [self delete_member:delete_group];
    }
    
    
    // 
    // find adds/updates
    //
    
    NSMutableArray *addviewers = [[NSMutableArray alloc]init];
    NSMutableArray *addcontribs = [[NSMutableArray alloc]init];
    
    for (ZZUser *new_user in users) {
        
        BOOL add = YES;
        for (ZZUser *user in _users) {
            if (new_user.user_id == user.user_id) {
                add = NO;
                
                // if permission changed, also add
                if (new_user.sharePermission != user.sharePermission) {
                    add = YES;
                }
                
                break;
            }
        }
        
        if (add) {
            if (new_user.sharePermission == kShareAsViewer) {
                [addviewers addObject:new_user.my_group_id];
            } else if (new_user.sharePermission == kShareAsContributor) {
                [addcontribs addObject:new_user.my_group_id];
            }
        }
    }
    
    
    for (ZZGroup *new_group in groups) {
        
        BOOL add = YES;
        for (ZZGroup *group in _groups) {
            if (new_group.id == group.id) {
                add = NO;
                
                // if permission changed, also add
                if (new_group.sharePermission != group.sharePermission) {
                    add = YES;
                }
                
                break;
            }
        }
        
        if (add) {
            if (new_group.sharePermission == kShareAsViewer) {
                [addviewers addObject:[NSNumber numberWithUnsignedLongLong:new_group.id]];
            } else if (new_group.sharePermission == kShareAsContributor) {
                [addcontribs addObject:[NSNumber numberWithUnsignedLongLong:new_group.id]];
            }
        }
    }
    
    if (addcontribs.count > 0) {
        changed = YES;
        [self add_members:kShareAsContributor groupIDs:addcontribs];
    }
    if (addviewers.count > 0) {
        changed = YES;
        [self add_members:kShareAsViewer groupIDs:addviewers];
    }

    // reset _users and _groups
    if (changed) {
        _users = [[NSArray alloc]initWithArray:users];
        _groups = [[NSArray alloc]initWithArray:groups];
    }
}


-(int)delete_member:(NSNumber*)groupID;
{
    MLOG(@"ZZShareList delete_member: request for: %llu, deleting: %llu", _albumID, [groupID unsignedLongLongValue]);
    NSString *url = [NSString stringWithFormat:ZZAPI_ALBUM_SHARING_DELETE_MEMBER,_albumID];  
        
    // create the request body 
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    NSDictionary *member = [[NSDictionary alloc]initWithObjectsAndKeys:groupID, @"id", nil];
    [body setValue:member forKey:@"member"];
    
    //create and send the request synchronously
    ASIHTTPRequest *request = [self createPOSTRequest:[self createURL:url  ssl:NO] body:body];    
    [request startSynchronous];
    
    int result = [self decodeRequestStatus:request message:@"delete member in ZZShareList#delete_member"];
    
    return result;
}


-(void)add_members:(ZZSharePermission)permission groupIDs:(NSArray*)groupIDs
{
    MLOG(@"ZZShareList add_members: request for: %llu", _albumID);
    NSString *url = [NSString stringWithFormat:ZZAPI_ALBUM_SHARING_ADD_MEMBERS,_albumID];  
    
    // create the request body 
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue:[ZZShareList sharePermissionToString:permission] forKey: @"permission"];
    [body setValue:@"" forKey: @"message"];         // force invite messages to go out for contribs (vs. nil or not set)
    [body setValue:groupIDs forKey: @"group_ids"];
    
    //create and send the request synchronously
    ASIHTTPRequest *request = [self createPOSTRequest:[self createURL:url  ssl:NO] body:body];    
    [request startSynchronous];
    
    int result = [self decodeRequestStatus:request message:@"add members in ZZShareList#add_members"];
    if (result == ZZAPI_SUCCESS ){
        //NSDictionary *add_result = [self decodeRequestResponseAsDictionary:request message:@"add members in ZZShareList#add_members"];
        return;
    }

    return;
}


-(void)setFromMembers:(NSArray*)members
{
    // sets _users and _groups from members list
    
    NSMutableArray *users = [[NSMutableArray alloc]init];
    NSMutableArray *adminUsers = [[NSMutableArray alloc]init];
    NSMutableArray *groups = [[NSMutableArray alloc]init];
    
    for (NSDictionary *member in members) {
        @try {
            
            NSDictionary *userHash = [member objectForKey:@"user"];
            NSString *permission = [member objectForKey:@"permission"];
            ZZSharePermission sharePermission = [ZZShareList sharePermissionFromString:permission];
            
            if (userHash) {
                ZZUser *user = [[ZZUser alloc]initWithDictionary:userHash];
                if (user) {
                    user.sharePermission = sharePermission;
                    
                    if (sharePermission == kShareAsAdmin) 
                        [adminUsers addObject:user];
                    else
                        [users addObject:user];
                }
            } else {
                ZZGroup *group = [[ZZGroup alloc]initWithNSDictionary:member];
                if (group) {
                    group.sharePermission = sharePermission;
                    [groups addObject:group];
                }
            }
        }
        @catch (NSException *exception) {
        }
    }
    
    _users = [[NSArray alloc]initWithArray:users];
    _adminUsers = [[NSArray alloc]initWithArray:adminUsers];
    _groups = [[NSArray alloc]initWithArray:groups];
}


+(void)sendShare:(ZZAlbumID)albumID photoID:(ZZPhotoID)photoID shareType:(NSString*)shareType message:(NSString*)message group_ids:(NSArray*)group_ids sendToFacebook:(BOOL)sendToFacebook sendToTwitter:(BOOL)sendToTwitter
{
    // create the request body 
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    
    // if photoID set, send as photo share message, otherwise send as album share message
    if (photoID != 0)
        [body setValue:[NSNumber numberWithUnsignedLongLong:photoID] forKey:@"photo_id"];
    else
        [body setValue:[NSNumber numberWithUnsignedLongLong:albumID] forKey:@"album_id"];
    
    [body setValue:shareType forKey:@"share_type"];
    [body setValue:group_ids forKey:@"group_ids"];
    [body setValue:[NSNumber numberWithBool:sendToFacebook] forKey:@"facebook"];
    [body setValue:[NSNumber numberWithBool:sendToTwitter] forKey:@"twitter"];
    
    if (message && message.length > 0)
        [body setValue:message forKey:@"message"];
    
    // create and send the request synchronously
    ZZShareList *s = [[ZZShareList alloc]init];
    ASIHTTPRequest *request = [s createPOSTRequest:[s createURL:ZZAPI_SHARES_SEND ssl:NO] body:body];    
    [request startSynchronous];
    
    int result = [s decodeRequestStatus:request message:@"send share in ZZShareList#sendShare"];
    if (result == ZZAPI_SUCCESS ){
        return;
    }
    
    return;
}



@end
