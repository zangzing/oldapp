//
//  CameraViewController.h
//  ZangZing
//
//  Created by Phil Beisel on 8/29/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureOutput.h>
#import <UIKit/UIKit.h>
#import "PhotoBrowser.h"
#import "SavePhotoViewController.h"
#import "MainViewController.h"
#import "ZZTabBar.h"
#import "ZZUIImageView.h"


@class CustomBadge;

@interface CameraViewController : ZZUIViewController <UINavigationControllerDelegate, ZZTabBarViewController, ZZUIImageViewDelegate, SavePhotoViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, PhotoBrowserDelegate> {
 
    UIView *imagePreview;
    UIView *snapview;
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    UIImageView *photo;

    BOOL _isback;                   // using back camera
    NSInteger _flashmode;           // current flash mode
    
#if !(TARGET_IPHONE_SIMULATOR)
    AVCaptureDeviceInput *_input;   // current input, front or back
    AVCaptureDevice *_device;
#endif
    
    UIButton *_usecamera;
    
    
    ZZUIImageView *_flashcontrol;
    
    UIButton *_flashauto;
    UIButton *_flashon;
    UIButton *_flashoff;
    UIButton *_flashtorchon;
    UIButton *_flashtorchoff;
    
    ZZUIImageView *_photopile;
    UIImageView *_pileframe;
    CustomBadge *_photopilebadge;
    ZZUIImageView *_filmstrip_top;
    ZZUIImageView *_filmstrip_bottom;
    
    int _currentFilter;
    BOOL _useFilters;
    UIScrollView *_filterDock;
    NSMutableArray *_filterPreviews;
    NSMutableArray *_filterPreviewsFrames;
    
    SavePhotoViewController *_savephoto;
    
    ZZUserID _saveuserid;
    ZZAlbumID _savealbumid;
    
    NSTimeInterval _lastCapture;
    BOOL _captureFailed;
    BOOL _startError;
    
    BOOL _currentlyVisible;
}

@property(nonatomic, strong) UIView *imagePreview;
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic, strong) UIImageView *photo;

-(void)startCamera;
-(void)stopCamera;
-(void)capture;
-(void)finishCapture:(time_t)taken photoData:(NSData*)photoData image:(UIImage*)image;

-(BOOL)flashAvailable;
-(void)setFlashMode:(AVCaptureFlashMode)flashMode;
-(BOOL)isFrontCameraAvailable;
-(void)setCamera:(BOOL)back;

-(void)setupFilters;
-(void)showFilters:(BOOL)show;
-(void)showPile:(UIImage*)photo photoCount:(NSUInteger)photoCount;
-(void)hidePile;
-(void)updatePileCount:(NSUInteger)photoCount;

-(UIImage*)applyFilter:(int)filter image:(UIImage*)image  fullsize:(BOOL)fullsize;


@end
