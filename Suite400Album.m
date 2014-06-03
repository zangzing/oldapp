//
//  Suite400AlbumInfo.m
//  Moment
//
//  Created by Mauricio Alvarez on 5/15/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "MBaseTest.h"

@interface Suite400AlbumInfo : MBaseTest
{
    ZZAlbumInfo *retrievedAlbumInfo;
}
@end


@implementation Suite400AlbumInfo

-(void)test100Login
{
    [self login];
}

-(void)test200AlbumInfo
{
    if( ![ZZSession currentSession]){
        GHFail(@"You must execute test100Login before executing this test");
    }
    [self prepare];
    [[ZZAPIClient sharedClient] getAlbumInfoForUser:[ZZSession currentUser] 
                                            success:^(ZZAlbumInfo *albumInfo) {
                                                GHAssertEquals( albumInfo.user_id, [ZZSession currentUser].user_id, @"Album info user_id is not the requested user_id");
                                                retrievedAlbumInfo = albumInfo;
                                                [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test200AlbumInfo)]; 
                                            }
                                            failure:^(NSError *error) {
                                                [self notify:kGHUnitWaitStatusFailure forSelector:@selector(test200AlbumInfo)]; 
                                            }];
 [self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
    
}

-(void) test300AlbumSet
{
    if( !retrievedAlbumInfo ){
        GHFail(@"You must execute test200AlbumInfo before executing this test");
    } 
    
    
    [self prepare];
    [[ZZAPIClient sharedClient] getAlbumSetForAlbumInfo:retrievedAlbumInfo 
                                            success:^(ZZAlbumSet *albumSet) {
                                                [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test300AlbumSet)]; 
                                            }
                                            failure:^(NSError *error) {
                                                [self notify:kGHUnitWaitStatusFailure forSelector:@selector(test300AlbumSet)]; 
                                            }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
}
@end
