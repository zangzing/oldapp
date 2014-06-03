//
//  ZZPhoto.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/20/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZJSONModel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"
#import "ZZUIImageView.h"

@interface ZZPhoto : ZZJSONModel

/*
:id => photo.id,
:agent_id => photo.agent_id,
:caption => photo.caption,
:state => photo.state,
:rotate_to => photo.rotate_to.nil? ? 0 : photo.rotate_to,
:source_guid => photo.source_guid,
:upload_batch_id => photo.upload_batch_id,
:user_id => photo.user_id,
:aspect_ratio => photo.aspect_ratio,
:stamp_url => photo.stamp_url,  # todo, the 4 urls should be nil if photo_base is non nil
:thumb_url => photo.thumb_url,
:screen_url => photo.screen_url,
:full_screen_url => photo.full_screen_url,
:photo_base => photo_base,
:photo_sizes => photo_sizes,
:width => photo.width,
:height => photo.height,
:rotated_width => photo.rotated_width,
:rotated_height => photo.rotated_height,
:capture_date => photo.capture_date,
:created_at => photo.created_at
*/

@property (nonatomic, strong) NSNumber *photo_id;
@property (nonatomic, strong) NSString *agent_id;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSNumber *rotate_to;
@property (nonatomic, strong) NSString *source_guid;
@property (nonatomic, strong) NSNumber *upload_batch_id;
@property (nonatomic)         ZZUserID user_id;
@property (nonatomic, strong) NSNumber *aspect_ratio;
@property (nonatomic, strong) NSString *stamp_url;
@property (nonatomic, strong) NSString *thumb_url;
@property (nonatomic, strong) NSString *screen_url;
@property (nonatomic, strong) NSString *full_screen_url;
@property (nonatomic, strong) NSString *photo_base;
@property (nonatomic, strong) NSDictionary *photo_sizes;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSNumber *rotated_width;
@property (nonatomic, strong) NSNumber *rotated_height;
@property (nonatomic, strong) NSDate   *capture_date;
@property (nonatomic, strong) NSDate   *created_at;
@property (nonatomic, readonly) BOOL   is_ready;

- (ZZUIImageView*)toZZUIImageView;
- (ZZUIImageView*)toGridZUIImageView;
@end
