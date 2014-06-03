//
//  ZZUIImageView.h
//  zziphone
//
//  Created by Phil Beisel on 8/14/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zztypes.h"

typedef enum 
{
    AlbumView,
    AlbumsView
} 
ImageTarget;


typedef enum 
{
    Thumb,
    Screen
} 
ImageType;


@class ZZUIImageView;

@protocol ZZUIImageViewDelegate <NSObject>

@optional
- (void)imageTap:(ZZUIImageView *)image;
- (void)imageLoaded:(ZZUIImageView *)image;
- (NSNumber*)shouldAnimateLoaded:(ZZUIImageView *)image;
- (NSNumber*)shouldAnimateDownloaded:(ZZUIImageView *)image;
@end




@interface ZZUIImageView : UIImageView {
@private
    ZZAlbumID albumid;
    ZZPhotoID photoid;
    int photoIndex;                     // index in albums or album set
    ImageType type;
    ImageTarget target;
    id <ZZUIImageViewDelegate> delegate;
    CGPoint tapLocation;
    
}

@property (nonatomic) ZZAlbumID albumid;
@property (nonatomic) ZZAlbumID photoid;
@property (nonatomic) int photoIndex;
@property (nonatomic) ImageType type;
@property (nonatomic) ImageTarget target;
@property (nonatomic) CGPoint tapLocation;

- (void)setDelegate:(id)newDelegate;
- (BOOL)canBecomeFirstResponder;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;

@end