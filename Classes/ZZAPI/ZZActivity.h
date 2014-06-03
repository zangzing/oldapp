//
//  ZZActivity.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/5/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zztypes.h"
#import "ZZJSONModel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"
#import "ZZUIImageView.h"
#import "ZZPhoto.h"

@interface ZZActivity : ZZJSONModel
@property (atomic, strong) NSDate     *created_at;
@property (atomic, strong) NSString   *kind;
@property (atomic) ZZUserID   by_user_id;
@property (atomic) ZZPhotoID  photo_id;
@property (atomic, strong) NSNumber   *like_count;
@property (atomic, strong) ZZPhoto *photo;

//init methods 
-(id) initWithDictionary:(NSDictionary*) serverJson;
@end
