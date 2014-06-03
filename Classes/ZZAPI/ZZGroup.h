//
//  ZZGroup.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZBaseObject.h"
#import "ZZUser.h"

#define kGroupNameLengthMax     (50)

@interface ZZGroup : ZZBaseObject{
    ZZGroupID _groupID;
    ZZUserID  _userID;
    NSString *_name;
    ZZUser *_user;
    ZZSharePermission _sharePermission;
}
@property (atomic, readonly) ZZGroupID id;
@property (atomic, readonly) ZZUserID  userID;
@property (nonatomic, readonly) NSString *name;
@property (atomic, readonly) ZZUser *user;
@property (nonatomic, readonly) NSArray *members;
@property (atomic) ZZSharePermission sharePermission;


//factory methods
+ (ZZGroup*)groupWithName:(NSString *)name error:(NSError **)anError;

//init methods
- (id)initWithID:(ZZGroupID)groupID;
- (id)initWithNSDictionary:(NSDictionary *)serverHash;
- (id)initWithGroup:(ZZGroup*)group;

- (BOOL) delete;
- (NSArray*)addMembers:(NSArray*)userIDs userNames:(NSArray *)userNames emails:(NSArray *)emails;
- (NSArray*)removeMembers:(NSArray*)userIDs;
- (ZZGroup*)updateName:(NSString*)newName;
+ (NSString*)validName:(NSString*)name;
@end