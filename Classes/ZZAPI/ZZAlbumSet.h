//
//  ZZAlbumSet.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zztypes.h"
#import "ZZJSONModel.h"

@interface ZZAlbumSet : ZZJSONModel

@property (nonatomic) ZZUserID user_id;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSMutableArray *album_array;
@property (nonatomic, strong) NSDate *last_updated;

-(id) initWithUserID:(ZZUserID)puser_id version:(NSString *)pversion album_array:(NSMutableArray *)palbum_array; 
@end
