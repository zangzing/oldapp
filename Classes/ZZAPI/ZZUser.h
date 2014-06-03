//
//  ZZUser.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/31/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zztypes.h"
#import "ZZJSONModel.h"
#import "ZZIdentities.h"
#import "ZZAlbumSet.h"
/*
 # Gets info about a single user.
 #
 # This is called as (GET):
 #
 # /zz_api/users/:user_id/info
 #
 # Does not require a current logged in user, used to request info about any user.
 #
 # Input:
 #
 # Returns the user info.
 #
 # {
 #        :id => users id,
 #        :my_group_id => the group that wraps just this user,
 #        :username => user name,
 #        :profile_photo_url => the url to the profile photo, nil if none,
 #        :profile_album_id => the profile album id, nil if none
 #        :first_name => first_name,
 #        :last_name => last_name,
 #        :email => email for this user (this will only be present for automatic users and in cases where you looked up the user via email, or the user is you)
 #        :automatic => true if an automatic user (one that has not created an account)
 #        :auto_by_contact => true if automatic user and was created simply by referencing (i.e. we added automatic as result of group or permission operation)
 #                            if automatic is set and this is false it means we have a user that has actually sent a photo in on that address
 #        :completed_step => the step until which the used completed the join process
 #        :created_by_user_id => keep track of which user invited this user
 # }
 */


@interface ZZUser :ZZJSONModel
{
  
    ZZIdentities *identities;
    ZZSharePermission sharePermission;
}
@property (nonatomic)           ZZUserID user_id;
@property (nonatomic, strong)   NSNumber *my_group_id;
@property (nonatomic, strong)   NSString *username;
@property (nonatomic, strong)   NSString *profile_photo_url;
@property (nonatomic, strong)   NSString *first_name;
@property (nonatomic, strong)   NSString *last_name;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, strong)   NSString *email;
@property (nonatomic, readonly) BOOL   automatic;
@property (nonatomic, readonly) BOOL   auto_by_contact;

@property (atomic) ZZSharePermission sharePermission;
@property (nonatomic, readonly) ZZIdentities *identities;



// Factory methods
+(NSArray*)findUsers:(NSArray*)userIDs userNames:(NSArray*)userNames emails:(NSArray*)emails error:(NSError**)anError;
+(NSArray*)findOrCreateUsers:(NSArray*)userIDs userNames:(NSArray*)userNames emails:(NSArray*)emails error:(NSError**)anError;

+(void)findOrCreateUsers:(NSArray*)userIDs userNames:(NSArray*)userNames emails:(NSArray*)emails findOnly:(BOOL)findOnly users:(NSArray**)users emailsNotFound:(NSArray**)emailsNotFound error:(NSError**) anError;

// init methods
-(id)initWithUser:(ZZUser*)user;

-(NSString*) displayFirstName;

-(NSString*) displayPossesiveFirstName;

-(NSString*) displayName;
-(NSString*) displayNameOrMe;

-(NSArray *) getGroups;


-(BOOL)getAlbumSetWithSuccessBlock:(void (^)(ZZAlbumSet *albumSet))success     
                                  failure:(void(^)(NSError *error))failure;

@end
