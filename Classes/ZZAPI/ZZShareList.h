//
//  ZZShareList.h
//  ZangZing
//
//  Created by Phil Beisel on 2/17/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zztypes.h"
#import "ZZBaseObject.h"

@interface ZZShareList : ZZBaseObject {
    
    ZZAlbumID _albumID;
    
    BOOL _hasFacebookToken;
    BOOL _hasTwitterToken;
    
    NSArray *_users;            // user members (array of ZZUser)
    NSArray *_groups;           // group members (array of ZZGroup)
    NSArray *_adminUsers;       // user admin members (array of ZZUser)
}

@property (nonatomic, readonly) NSArray *users;
@property (nonatomic, readonly) NSArray *groups;
@property (nonatomic, readonly) NSArray *adminUsers;

// init methods
-(id)initWithAlbumID:(ZZAlbumID)albumID;

-(void)setMembers:(NSArray*)users groups:(NSArray*)groups;
+(void)sendShare:(ZZAlbumID)albumID photoID:(ZZPhotoID)photoID shareType:(NSString*)shareType message:(NSString*)message group_ids:(NSArray*)group_ids sendToFacebook:(BOOL)sendToFacebook sendToTwitter:(BOOL)sendToTwitter;

-(void)add_members:(ZZSharePermission)permission groupIDs:(NSArray*)groupIDs;
-(int)delete_member:(NSNumber*)groupID;

// internal
-(void)setFromMembers:(NSArray*)members;

@end
