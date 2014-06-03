//
//  ZZAlbumInfo.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zztypes.h"
#import "ZZJSONModel.h"

/*
# Return the album meta data for a given user. The albums returned are split
# across the various types such as liked albums, invited albums, my albums.
#
# This is called as (GET):
#
# /zz_api/users/:user_id/albums
#
# The data returned depends on who is logged in and what users is being requested.
# If you are logged in and requesting data for yourself you will get all of your
# private data returned.  If you are asking about a different user, you will see
# that users public info.
#
# Returns the album meta data in the following form:
#
# {
#    :user_id                        => user id this data belongs to,
#    :logged_in_user_id              => the id of the user that requested this data or nil if not logged in
#    :public                         => true if viewing public data
#    :my_albums                      => the version string for my albums,
#    :my_albums_path                 => the path to my albums
#    :liked_albums                   => the version string to the liked albums
#    :liked_albums_path              => path to the liked albums
#    :liked_users_albums             => version string to like users albums
#    :liked_users_albums_path        => path the public albums of the liked users combined
#    :session_user_liked_albums      => version string,
#    :session_user_liked_albums_path => the liked albums path for the logged in user,
#    :invited_albums                 => version string,
#    :invited_albums_path            => path to invited albums,
#    :session_user_invited_albums      => version string,
#    :session_user_invited_albums_path => path to the logged in users invited albums
# }
#
*/

@interface ZZAlbumInfo : ZZJSONModel

@property (nonatomic)           ZZUserID user_id;
@property (nonatomic)           ZZUserID logged_in_user_id;
@property (nonatomic, strong)   NSString *my_albums;
@property (nonatomic, strong)   NSString *my_albums_path;
@property (nonatomic, strong)   NSString *liked_albums;
@property (nonatomic, strong)   NSString *liked_albums_path;
@property (nonatomic, strong)   NSString *liked_users_albums;
@property (nonatomic, strong)   NSString *liked_users_albums_path;
@property (nonatomic, strong)   NSString *session_user_liked_albums;
@property (nonatomic, strong)   NSString *session_user_liked_albums_path;
@property (nonatomic, strong)   NSString *invited_albums;
@property (nonatomic, strong)   NSString *invited_albums_path;
@property (nonatomic, strong)   NSString *session_user_invited_albums;
@property (nonatomic, strong)   NSString *session_user_invited_albums_path;

@end
