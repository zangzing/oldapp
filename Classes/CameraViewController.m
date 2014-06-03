//
//  CameraViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 8/29/11.
//  Copyright 2011 ZangZing. All rights reserved.
//


#import <ImageIO/CGImageProperties.h>
#import "MainViewController.h"
#import "zzglobal.h"
#import "photouploader.h"
#import "ZZUINavigationBar.h"
#import "CustomBadge.h"
#import "UIImage+Resize.h"
#import "UIImage+Extensions.h"
#import "SavePhotoViewController.h"
#import "ZZAppDelegate.h"
#import "SDImageCache.h"
#import "util.h"
#import "CameraViewController.h"

const NSTimeInterval kCaptureIntervalMinimum =.0125;           // minimum time before next capture allowed

const CGFloat kScrollObjHeight  = 64;
const CGFloat kScrollObjWidth   = 64;
const int kFilters = 10;
const CGFloat kPhotoPilePreviewSize = 50;

const CGFloat kFlashControlWidth   = 215;

@implementation CameraViewController

@synthesize imagePreview;
@synthesize stillImageOutput;
@synthesize session;
@synthesize photo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"CameraViewController: didReceiveMemoryWarning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    imagePreview = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 20, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:imagePreview];
    imagePreview.hidden = YES;
    
    photo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    

    int width;
    CGFloat capWidth = 5.0;
    
    UIImage *flashimage = [UIImage imageNamed:@"flash-icon.png"];
    UIImage *torchoffimage = [UIImage imageNamed:@"torch-off-icon.png"];
    UIImage *torchonimage = [UIImage imageNamed:@"torch-on-icon.png"];
    UIImage *separator = [UIImage imageNamed:@"camera-button-1-separator.png"];
    
    width = 70;
    UIImage* bimage = [[UIImage imageNamed:@"camera-button-1.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    UIImage* bimage2 = [[UIImage imageNamed:@"camera-button-1-selected.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    
    _usecamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [_usecamera setBackgroundImage:bimage forState:UIControlStateNormal];
    [_usecamera setBackgroundImage:bimage2 forState:UIControlStateHighlighted];
    
    UIImage *cameraswapimage = [UIImage imageNamed:@"camera-swap.png"];
    UIImageView *cameraswapimageview = [[UIImageView alloc]initWithImage:cameraswapimage];
    cameraswapimageview.frame = CGRectMake(12, 5, cameraswapimage.size.width, cameraswapimage.size.height);
    [_usecamera addSubview:cameraswapimageview];
    
    _usecamera.frame = CGRectMake(320-width-10, 15, width, bimage.size.height);
    [_usecamera addTarget:self action:@selector(goUseCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_usecamera];
    
        
    
    width = kFlashControlWidth;
    _flashcontrol = [[ZZUIImageView alloc] initWithImage:bimage];
    _flashcontrol.frame = CGRectMake(10, 15, width, bimage.size.height);
    _flashcontrol.clipsToBounds = YES;
    [_flashcontrol setBackgroundColor:[UIColor clearColor]];
    [_flashcontrol setDelegate:self];
    _flashcontrol.userInteractionEnabled = YES;
    
    // place flash icon, auto, |, on, |, off | torch icon
    
    int fx, fy, fwidth;
    
    // flash icon
    fx = 8;
    fy = 5;
    UIImageView *fc1 = [[UIImageView alloc]initWithImage:flashimage];
    fc1.frame = CGRectMake(fx, fy, flashimage.size.width, flashimage.size.height);
    [_flashcontrol addSubview:fc1];
    
    // auto
    fx = fx + flashimage.size.width + 5;
    fy = 9;
    fwidth = 40;
    UILabel *fc2 = [[UILabel alloc]initWithFrame:CGRectMake(fx, fy, fwidth, 15)];
    fc2.font = [UIFont boldSystemFontOfSize:16];
    fc2.text = @"Auto";
    [fc2 setTextColor:[UIColor colorWithRed: 33.0/255.0 green: 33.0/255.0 blue: 33.0/255.0 alpha: 1.0]];
    fc2.backgroundColor = [UIColor clearColor];
    [_flashcontrol addSubview:fc2];
    
    // sep
    fx = fx + fwidth + 5;
    fy = 0;
    UIImageView *fc3 = [[UIImageView alloc]initWithImage:separator];
    fc3.frame = CGRectMake(fx, fy, separator.size.width, separator.size.height);
    [_flashcontrol addSubview:fc3];
    
    // on
    fx = fx + 15;
    fy = 9;
    fwidth = 33;
    UILabel *fc4 = [[UILabel alloc]initWithFrame:CGRectMake(fx, fy, fwidth, 15)];
    fc4.font = [UIFont boldSystemFontOfSize:16];
    fc4.text = @"On";
    [fc4 setTextColor:[UIColor colorWithRed: 33.0/255.0 green: 33.0/255.0 blue: 33.0/255.0 alpha: 1.0]];
    fc4.backgroundColor = [UIColor clearColor];
    [_flashcontrol addSubview:fc4];
    
    // sep
    fx = fx + fwidth + 5;
    fy = 0;
    UIImageView *fc5 = [[UIImageView alloc]initWithImage:separator];
    fc5.frame = CGRectMake(fx, fy, separator.size.width, separator.size.height);
    [_flashcontrol addSubview:fc5];
    
    // off
    fx = fx + 10;
    fy = 9;
    fwidth = 33;
    UILabel *fc6 = [[UILabel alloc]initWithFrame:CGRectMake(fx, fy, fwidth, 15)];
    fc6.font = [UIFont boldSystemFontOfSize:16];
    fc6.text = @"Off";
    [fc6 setTextColor:[UIColor colorWithRed: 33.0/255.0 green: 33.0/255.0 blue: 33.0/255.0 alpha: 1.0]];
    fc6.backgroundColor = [UIColor clearColor];
    [_flashcontrol addSubview:fc6];
    
    // sep
    fx = fx + fwidth + 5;
    fy = 0;
    UIImageView *fc7 = [[UIImageView alloc]initWithImage:separator];
    fc7.frame = CGRectMake(fx, fy, separator.size.width, separator.size.height);
    [_flashcontrol addSubview:fc7];

    // torch off
    fx = fx + 10;
    fy = 9;
    UIImageView *fc8 = [[UIImageView alloc]initWithImage:torchoffimage];
    fc8.frame = CGRectMake(fx, fy, torchoffimage.size.width, torchoffimage.size.height);
    [_flashcontrol addSubview:fc8];
    
    
    
    
    width = 70;
    _flashauto = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashauto setBackgroundImage:bimage forState:UIControlStateNormal];
    //[_flashauto setBackgroundImage:bimage2 forState:UIControlStateHighlighted];
    
    UIImageView *flashimageview1 = [[UIImageView alloc]initWithImage:flashimage];
    flashimageview1.frame = CGRectMake(8, 5, flashimage.size.width, flashimage.size.height);
    [_flashauto addSubview:flashimageview1];
    
    UILabel *flashautolabel = [[UILabel alloc]initWithFrame:CGRectMake(26, 7+2, 60, 15)];
    flashautolabel.font = [UIFont boldSystemFontOfSize:16];
    flashautolabel.text = @"Auto";
    [flashautolabel setTextColor:[UIColor colorWithRed: 33.0/255.0 green: 33.0/255.0 blue: 33.0/255.0 alpha: 1.0]];
    flashautolabel.backgroundColor = [UIColor clearColor];
    [_flashauto addSubview:flashautolabel];                          
    
    _flashauto.frame = CGRectMake(10, 15, width, bimage.size.height);
    [_flashauto addTarget:self action:@selector(goFlashSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashauto];
    
    
    
    width = 70;
    _flashon = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashon setBackgroundImage:bimage forState:UIControlStateNormal];
    //[_flashon setBackgroundImage:bimage2 forState:UIControlStateHighlighted];
    
    UIImageView *flashimageview2 = [[UIImageView alloc]initWithImage:flashimage];
    flashimageview2.frame = CGRectMake(8, 5, flashimage.size.width, flashimage.size.height);
    [_flashon addSubview:flashimageview2];
    
    UILabel *flashonlabel = [[UILabel alloc]initWithFrame:CGRectMake(26, 7+2, 60, 15)];
    flashonlabel.font = [UIFont boldSystemFontOfSize:16];
    flashonlabel.text = @"On";
    [flashonlabel setTextColor:[UIColor colorWithRed: 33.0/255.0 green: 33.0/255.0 blue: 33.0/255.0 alpha: 1.0]];
    flashonlabel.backgroundColor = [UIColor clearColor];
    [_flashon addSubview:flashonlabel];                          
    
    _flashon.frame = CGRectMake(10, 15, width, bimage.size.height);
    [_flashon addTarget:self action:@selector(goFlashSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashon];
    
    
    
    width = 70;
    _flashoff = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashoff setBackgroundImage:bimage forState:UIControlStateNormal];
    //[_flashoff setBackgroundImage:bimage2 forState:UIControlStateHighlighted];
    
    UIImageView *flashimageview3 = [[UIImageView alloc]initWithImage:flashimage];
    flashimageview3.frame = CGRectMake(8, 5, flashimage.size.width, flashimage.size.height);
    [_flashoff addSubview:flashimageview3];
    
    UILabel *flashofflabel = [[UILabel alloc]initWithFrame:CGRectMake(26, 7+2, 60, 15)];
    flashofflabel.font = [UIFont boldSystemFontOfSize:16];
    flashofflabel.text = @"Off";
    [flashofflabel setTextColor:[UIColor colorWithRed: 33.0/255.0 green: 33.0/255.0 blue: 33.0/255.0 alpha: 1.0]];
    flashofflabel.backgroundColor = [UIColor clearColor];
    [_flashoff addSubview:flashofflabel];                          
    
    _flashoff.frame = CGRectMake(10, 15, width, bimage.size.height);
    [_flashoff addTarget:self action:@selector(goFlashSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashoff];

    
    
    width = 40;
    _flashtorchoff = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashtorchoff setBackgroundImage:bimage forState:UIControlStateNormal];
    //[_flashtorchoff setBackgroundImage:bimage2 forState:UIControlStateHighlighted];
    
    UIImageView *flashimageview4 = [[UIImageView alloc]initWithImage:torchoffimage];
    flashimageview4.frame = CGRectMake(13, 9, torchoffimage.size.width, torchoffimage.size.height);
    [_flashtorchoff addSubview:flashimageview4];
                            
    _flashtorchoff.frame = CGRectMake(10, 15, width, bimage.size.height);
    [_flashtorchoff addTarget:self action:@selector(goFlashSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashtorchoff];
    
    
    
    width = 50;
    _flashtorchon = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashtorchon setBackgroundImage:bimage forState:UIControlStateNormal];
    //[_flashtorchon setBackgroundImage:bimage2 forState:UIControlStateHighlighted];
    
    UIImageView *flashimageview5 = [[UIImageView alloc]initWithImage:torchonimage];
    flashimageview5.frame = CGRectMake(13, 8, torchoffimage.size.width, torchoffimage.size.height);
    [_flashtorchon addSubview:flashimageview5];
    
    _flashtorchon.frame = CGRectMake(10, 15, width, bimage.size.height);
    [_flashtorchon addTarget:self action:@selector(goFlashSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashtorchon];
    
    
    
    
    int px = 320 - 50 - 17;
    int py = 350;
    int pborder = 3;
        
    UIImage *fimage5 = [UIImage imageNamed:@"placeholder.png"];
    _photopile = [[ZZUIImageView alloc] initWithImage:fimage5];    
    _photopile.frame = CGRectMake(px, py+pborder, kPhotoPilePreviewSize, kPhotoPilePreviewSize);
    [_photopile setBackgroundColor:[UIColor clearColor]];
    [_photopile setDelegate:self];
    _photopile.userInteractionEnabled = YES;
    
    
    UIImage *pileframeimage = [UIImage imageNamed:@"pile-border.png"];
    _pileframe = [[UIImageView alloc] initWithImage:pileframeimage];    
    _pileframe.frame = CGRectMake(-1, -1, pileframeimage.size.width, pileframeimage.size.height);
    [_photopile addSubview:_pileframe];
    
    
    UIImage *fstrip = [UIImage imageNamed:@"film-strip.png"];
    UIImageView *topstrip = [[UIImageView alloc]initWithImage:fstrip];
    topstrip.frame = CGRectMake(0, 1, fstrip.size.width, fstrip.size.height);
    [_photopile addSubview:topstrip];
    
    UIImageView *bottomstrip = [[UIImageView alloc]initWithImage:fstrip];
    bottomstrip.frame = CGRectMake(0, kPhotoPilePreviewSize - fstrip.size.height - 1, fstrip.size.width, fstrip.size.height);
    [_photopile addSubview:bottomstrip];
    
    UIImage *fscrim = [UIImage imageNamed:@"photo-scrim.png"];
    UIImageView *scrim = [[UIImageView alloc]initWithImage:fscrim];
    scrim.frame = CGRectMake(0, 0, fscrim.size.width, fscrim.size.height);
    [_photopile addSubview:scrim];
    
    
    _photopilebadge = [CustomBadge customBadgeWithString:@"1" 
                                        withStringColor:[UIColor whiteColor] 
                                        withInsetColor:[UIColor redColor] 
                                        withBadgeFrame:YES 
                                        withBadgeFrameColor:[UIColor whiteColor] 
                                        withScale:1.0
                                        withShining:YES];
    [_photopilebadge setFrame:CGRectMake(px + _photopile.frame.size.width - 16, py - 8, _photopilebadge.frame.size.width, _photopilebadge.frame.size.height)];
    
    [self.view addSubview:_flashcontrol];
    [self.view addSubview:_flashauto];
    [self.view addSubview:_flashon];
    [self.view addSubview:_flashoff];
    //[self.view addSubview:_photopileback];
    [self.view addSubview:_photopile];
    [self.view addSubview:_photopilebadge];
    
    _flashcontrol.hidden = YES;
    
    _flashauto.hidden = YES;
    _flashon.hidden = YES;
    _flashoff.hidden = YES;
    _flashtorchon.hidden = YES;
    _flashtorchoff.hidden = YES;
    
    _photopile.hidden = YES;
    //_photopileback.hidden = YES;
    _photopilebadge.hidden = YES;
    
    _flashmode = AVCaptureFlashModeAuto;
    
    /*  *** filter will move to photobrowser (edit)
    _useFilters = NO;
    if ([CIImage instancesRespondToSelector:@selector (initWithImage:)]) {
        _useFilters = YES;
        [self setupFilters];
    }    
    */
    
    _lastCapture = [[NSDate date] timeIntervalSince1970];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    [self switchToView];    
}

- (void)viewDidAppear:(BOOL)animated
{
    _currentlyVisible = YES;
}
- (void)viewDidDisappear:(BOOL)animated
{
    _currentlyVisible = NO;
}


-(void)willResignActiveNotification
{
    MLOG(@"willResignActiveNotification");
    
    if( _currentlyVisible ){
        @try {
            // if location authorization status is kCLAuthorizationStatusNotDetermined, return
            // this is because the location services dialog causes a call to willResignActiveNotification
            
            BOOL authorizationStatusClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)];     // iOS 4.2+
            if (authorizationStatusClassPropertyAvailable) {
                CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
                if (authorizationStatus == kCLAuthorizationStatusNotDetermined)
                    return;
            } 
            else {
                // on iOS 4.1
                // *** must code method to determine if location authorization status dialog will appear
                // *** to be on the safe side, return for now
                return;     
            }
            
            [self stopCamera];
            [gV switchToView:kTABBAR_MainBar selectedTab:0 viewController:NULL];
            
        }
        @catch (NSException *exception) {
            [ZZGlobal trackException:@"camera.resign" exception:exception];
        }
    }
}


-(void)willAppearIn:(UINavigationController *)navigationController
{
    ZZUINavigationBar* navbar = (ZZUINavigationBar*)navigationController.navigationBar;
    navbar.translucent = NO; 
    navbar.tintColor = nil;
    [navbar setBackgroundWith:[UIImage imageNamed:@"nav-background.png"]];
}


- (void)layoutFilters
{
    UIImageView *view = nil;
    NSArray *subviews = [_filterDock subviews];
    
    // reposition all image subviews in a horizontal serial fashion
    CGFloat curXLoc = 0;
    for (view in subviews)
    {
        if ([view isKindOfClass:[UIView class]] && view.tag > 0)
        {
            CGRect frame = view.frame;
            frame.origin = CGPointMake(curXLoc, 0);
            view.frame = frame;
            
            curXLoc += (kScrollObjWidth);
        }
    }
    
    // set the content size so it can be scrollable
    [_filterDock setContentSize:CGSizeMake((kFilters * kScrollObjWidth), [_filterDock bounds].size.height)];
}


-(void)updateFilterPreviews
{
    UIImage *previewImage = [photo.image thumbnailImage:(kScrollObjWidth - 10) transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationMedium];
    
    int filter = 1;
    for (UIImageView *imageView in _filterPreviews) {
        
        imageView.image = [self applyFilter:filter image:previewImage fullsize:NO];
        [imageView setNeedsDisplay];
        filter++;
    }
}


-(void)showFilters:(BOOL)show
{
    if (!_useFilters)
        return;
    
    _filterDock.hidden = !show;
}


-(void)setupFilters
{
    _currentFilter = 1;
    
    _filterPreviews = [[NSMutableArray alloc]initWithCapacity:kFilters];
    _filterPreviewsFrames = [[NSMutableArray alloc]initWithCapacity:kFilters];

    _filterDock = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 480-(90+49), 320, 90)];
    [self.view addSubview:_filterDock];
        
    [_filterDock setBackgroundColor:[UIColor clearColor]];
    [_filterDock setCanCancelContentTouches:NO];
    _filterDock.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _filterDock.clipsToBounds = YES;        // default is NO, we want to restrict drawing within our scrollview
    _filterDock.scrollEnabled = YES;
    
    // snap to next
    _filterDock.pagingEnabled = YES;
    
    // load all the images from our bundle and add them to the scroll view
    NSUInteger i;
    for (i = 1; i <= kFilters; i++)
    {
        UIView *fv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScrollObjWidth, kScrollObjHeight)];
        fv.tag = i;
        [fv setBackgroundColor:[UIColor clearColor]];
        
        UIView *fi = [[UIView alloc]initWithFrame:CGRectMake(3, 3, kScrollObjWidth-6, kScrollObjHeight-6)];
        [fi setBackgroundColor:[UIColor whiteColor]];
        if (i == 1)
            [fi setBackgroundColor:[UIColor yellowColor]];
        [_filterPreviewsFrames addObject:fi];
        [fv addSubview:fi];
        
        NSString *imageName = @"placeholder.png";
        UIImage *image = [UIImage imageNamed:imageName];
        ZZUIImageView *imageView = [[ZZUIImageView alloc] initWithImage:image];
        [imageView setDelegate:self];
        imageView.userInteractionEnabled = YES;
        [_filterPreviews addObject:imageView];
        
        imageView.frame = CGRectMake(5, 5, kScrollObjWidth - 10, kScrollObjHeight - 10);
        imageView.tag = i;  
        [fv addSubview:imageView];
        
        [_filterDock addSubview:fv];
    }
    
    [self layoutFilters];  // now place the photos in serial layout within the scrollview
    
    _filterDock.hidden = YES;
}


- (void)viewDidUnload
{
    NSLog(@"CameraViewController: viewDidUnload");
    
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    
    self.imagePreview = nil;
    self.photo = nil;
    
    [self stopCamera];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#import "UIImageView+WebCache.h"

- (void)switchToView
{
    MLOG(@"CameraViewController: switchToView");
    
    [ZZUtil setOrientation:UIDeviceOrientationPortrait];
    
    // flush in-memory image cache
    [[SDImageCache sharedImageCache] clearMemory];
    
    [gV switchTabbar:kTABBAR_CameraBar selectedTab:-1];
    [self startCamera];
    
    NSUInteger photoCount = [gPhotoUploader photoCount];
    if (photoCount > 0) {
        [self showPile:[gPhotoUploader lastPhoto] photoCount:photoCount];
    }
}


-(void)switchFromView
{
    MLOG(@"CameraViewController: switchFromView");
    
}


-(void)startCamera
{
    MLOG(@"startCamera");
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    @try {
        
        session = [[AVCaptureSession alloc] init];
        
        NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
        [ns addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionRuntimeErrorNotification object:session];
        [ns addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionDidStartRunningNotification object:session];
        [ns addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionInterruptionEndedNotification object:session];
        [ns addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionDidStopRunningNotification object:session];
        [ns addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionWasInterruptedNotification object:session];
        
        session.sessionPreset = AVCaptureSessionPresetPhoto;
        
        //CALayer *viewLayer = self.imagePreview.layer;
        //MLOG(@"viewLayer = %@", viewLayer);
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        
        captureVideoPreviewLayer.frame = self.imagePreview.bounds;
        [self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
        imagePreview.hidden = NO;
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (_input == NULL) {
            // Handle the error appropriately.
            MLOG(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:_input];
        _isback = YES;
        
        stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [stillImageOutput setOutputSettings:outputSettings];
        
        [session addOutput:stillImageOutput];
        
        BOOL isFlashAvailable = [self flashAvailable];
        MLOG(@"Flash available? %d", isFlashAvailable);
            
        MLOG(@"session: startRunning");
        _startError = NO;
        [session startRunning];
        MLOG(@"session: running");
        
        if (_startError)
            return;
        
        if (isFlashAvailable) {
            // *** last used?
            _flashmode = AVCaptureFlashModeAuto;
            
            switch (_flashmode) {
                case AVCaptureFlashModeAuto:
                    [self setFlashMode:AVCaptureFlashModeAuto];
                    _flashauto.hidden = NO;
                    break;
                    
                case AVCaptureFlashModeOn:
                    [self setFlashMode:AVCaptureFlashModeOn];
                    _flashon.hidden = NO;
                    break;
                    
                case AVCaptureFlashModeOff:
                    [self setFlashMode:AVCaptureFlashModeOff];
                    _flashoff.hidden = NO;
                    break;
                    
                default:
                    break;
            }
        }
        
        _usecamera.hidden = ![self isFrontCameraAvailable];
        
        [gZZ startLocationServices];
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"camera.start" exception:exception];
    }

#endif
}


- (void)cameraNotification:(NSNotification*)notification 
{
    MLOG(@"camera notification %@", notification.name);
    MLOG(@"notification data: %@", notification.userInfo);
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    NSString *name = notification.name;
    if ([name isEqualToString:AVCaptureSessionRuntimeErrorNotification]) {
        _startError = YES;
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Camera Error" message:@"Cannot start the camera.  Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        [self stopCamera];
        [gV switchToView:kTABBAR_MainBar selectedTab:0 viewController:NULL];
    }
#endif
    
}


-(void)hideCameraControls
{
    _usecamera.hidden = YES;
    _flashauto.hidden = YES;
    _flashon.hidden = YES;
    _flashoff.hidden = YES;
    _flashtorchon.hidden = YES;
    _flashtorchoff.hidden = YES;
}


-(BOOL)flashAvailable
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    @try {
        if ([gZZ getSystemVersion] >= __IPHONE_5_0) 
        {
            return _device.isFlashAvailable;  
        } 
        else 
        {
            return _device.hasFlash;
        }
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"camera.flashavailable" exception:exception];
    }
    
    return NO;
    
#else
    return NO;
#endif
}


-(void)setFlashControls
{
    _flashauto.hidden = YES;
    _flashon.hidden = YES;
    _flashoff.hidden = YES;
    _flashtorchon.hidden = YES;
    _flashtorchoff.hidden = YES;
    
    if (![self flashAvailable])
        return;
    
    switch (_flashmode) {
        case AVCaptureFlashModeAuto:
            _flashauto.hidden = NO;
            break;
            
        case AVCaptureFlashModeOn:
            _flashon.hidden = NO;
            break;
            
        case AVCaptureFlashModeOff:
            _flashoff.hidden = NO;
            break;
            
        default:
            break;
    }
}

-(void)setFlashMode:(AVCaptureFlashMode)flashMode
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    @try {

        if (_device.hasFlash && _device.flashMode != flashMode) {
            [session beginConfiguration];
            [_device lockForConfiguration:nil];
            
            if ([_device isFlashModeSupported:flashMode]) {
                _device.flashMode = flashMode;
            }
            
            [_device unlockForConfiguration];
            [session commitConfiguration];
        }
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"camera.setflashmode" exception:exception];
    }
#endif
}


-(AVCaptureDevice*)cameraDevice:(BOOL)back
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    @try {

        AVCaptureDevicePosition wantcamera;
        if (back)
            wantcamera = AVCaptureDevicePositionBack;
        else
            wantcamera = AVCaptureDevicePositionFront;
        
        //  enumerate video devices, looking for desired camera
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *captureDevice = nil;
        for (AVCaptureDevice *device in videoDevices)
        {
            if (device.position == wantcamera)
            {
                captureDevice = device;
                break;
            }
        }
    
        return captureDevice;
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"camera.device" exception:exception];
        return NULL;
    }
#else
    return NULL;
#endif
}


-(BOOL)isFrontCameraAvailable
{
    AVCaptureDevice* front = [self cameraDevice:NO];
    return (front != NULL);
}


-(void)setCamera:(BOOL)back
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    @try {

        if (_isback && back)
            return;
        if (!_isback && !back)
            return;
        
        NSError *error = nil;

        AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:[self cameraDevice:back] error:&error];

        [session beginConfiguration];
        [session removeInput:_input];
        _input = newInput;
        [session addInput:_input];
        [session commitConfiguration];
        
        _isback = back;
        
        // *** flips current image hmmm
        [UIView transitionWithView:imagePreview duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{         
                            //self.image = image;
                        }
                        completion:NULL];
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"camera.set" exception:exception];
    }
#endif
}


-(void)stopCamera
{
    MLOG(@"stopCamera");
    
    @try {
        imagePreview.hidden = YES;
        
#if !(TARGET_IPHONE_SIMULATOR)        
        if (session)
            [session stopRunning];
        session = nil;
        _device = nil;
        stillImageOutput = nil;
#endif
        
        [gZZ stopLocationServices];
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"camera.stop" exception:exception];
    }
}


-(void)hidePile
{
    _photopile.hidden = YES;
    //_photopileback.hidden = YES;
    _photopilebadge.hidden = YES;
}


-(void)updatePileCount:(NSUInteger)photoCount
{
    [_photopilebadge autoBadgeSizeWithString:[NSString stringWithFormat:@"%d", photoCount]];
}


-(void)showPile:(UIImage*)pphoto photoCount:(NSUInteger)photoCount
{
    [self updatePileCount:photoCount];
    
    if (pphoto) {
        UIImage *photoThumb = [pphoto thumbnailImage:kPhotoPilePreviewSize transparentBorder:0 cornerRadius:3 interpolationQuality:kCGInterpolationMedium];
        _photopile.image = photoThumb;
    }
    _photopile.hidden = NO;
    _photopilebadge.hidden = NO;
}


- (void)finishCaptureAnimationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    
    @synchronized(self) {
        if (snapview) {
            [snapview removeFromSuperview];
            snapview = nil;
        }
    }
}


-(void)finishCapture:(time_t)taken photoData:(NSData*)photoData image:(UIImage*)image
{    
    @synchronized(self) {
        if (snapview) {
            [snapview removeFromSuperview];
            snapview = nil;
        }
    }
    
    // blink to black
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0100];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishCaptureAnimationDone:finished:context:)];

    snapview = [[UIView alloc]initWithFrame:imagePreview.frame];
    [snapview setBackgroundColor:[UIColor blackColor]];
    [imagePreview addSubview:snapview];
    [UIView commitAnimations];
    
    @try {
        NSUInteger photoCount = [gPhotoUploader photoCount]; 
        
        MLOG(@"device orientation: %d", [[UIDevice currentDevice]orientation]);
        
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice]orientation];
        UIImageOrientation imageOrientation = -1;
        
        switch (deviceOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationUp;
                break;
                
            case UIDeviceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationDown;
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationLeft;
                
            default:
                break;
        }
        
        if (imageOrientation != -1) {
            image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:imageOrientation];
            
            // addPhoto must extract photoData from newly rotated image
            photoData = (NSData*)[NSNull null];        
        }
        
        
        NSMutableDictionary *xdata = nil;
        if ([gZZ locationIsValid]) {
            xdata = [[NSMutableDictionary alloc]initWithCapacity:4];
            [xdata setObject:[NSNumber numberWithDouble:[gZZ getLocationLongitude]] forKey:@"location_long"];
            [xdata setObject:[NSNumber numberWithDouble:[gZZ getLocationLatitude]] forKey:@"location_lat"];
            [xdata setObject:[NSNumber numberWithDouble:[gZZ getLocationAltitude]] forKey:@"location_alt"];
            [xdata setObject:[NSNumber numberWithDouble:[[gZZ getLocationTimestamp] timeIntervalSince1970]] forKey:@"location_timestamp"];
        }
        
        [gPhotoUploader addPhoto:image photoData:photoData taken:taken xdata:xdata];
        
        [self showPile:image photoCount:photoCount+1];
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"camera.capture.finish" exception:exception];
    }    
}


-(void)capture
{
    MLOG(@"capture");
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    @synchronized(self) {
        @try {
            
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            
            BOOL waited = NO;
            NSTimeInterval start_wait = [[NSDate date] timeIntervalSince1970];
            while (now - _lastCapture < kCaptureIntervalMinimum) {
                [NSThread sleepForTimeInterval:.0100];
                now = [[NSDate date] timeIntervalSince1970];
                waited = YES;
            }
            NSTimeInterval end_wait = [[NSDate date] timeIntervalSince1970];
            _lastCapture = [[NSDate date] timeIntervalSince1970];
            
            if (waited)
                NSLog(@"capture: waited on camera: %.2fs", end_wait-start_wait);

            
            // find video connection
            AVCaptureConnection *connection = nil;
            for (AVCaptureConnection *c in stillImageOutput.connections)
            {
                for (AVCaptureInputPort *port in [c inputPorts])
                {
                    if ([[port mediaType] isEqual:AVMediaTypeVideo] )
                    {
                        connection = c;
                        break;
                    }
                }
                if (connection) 
                    break;
            }
            
            _captureFailed = NO;
            
            MLOG(@"request a capture from: %@", stillImageOutput);
            
            [stillImageOutput captureStillImageAsynchronouslyFromConnection:connection 
                                                          completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
             {
                 @try {
                     time_t taken = (time_t) [[NSDate date] timeIntervalSince1970];
                     
                     /*
                     CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                     if (exifAttachments)
                         MLOG(@"EXIF: attachments: %@", exifAttachments);
                     else
                         MLOG(@"EXIF: no attachments");
                     */
                     
                     NSData *photoData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                     UIImage *image = [[UIImage alloc] initWithData:photoData];
                     
                     //[self performSelector:@selector(finishCapture) withObject:nil afterDelay:.01];
                     [self finishCapture:taken photoData:photoData image:image];
                }
                @catch (NSException *exception) {
                    [ZZGlobal trackException:@"camera.capture.1" exception:exception];
                    
                    _captureFailed = YES;
                }
             }
             ];
            
            [ZZGlobal trackEvent:@"camera.capture" xdata:nil];
        }
        @catch (NSException *exception) {
            [ZZGlobal trackException:@"camera.capture" exception:exception];
        }
    }
    
    
    if (_captureFailed) {
        // attempt reset on camera
        [self stopCamera];
        [self startCamera];
    }
    
#else
    
    // simulate capture for TARGET_IPHONE_SIMULATOR
    
    NSLog(@"TARGET_IPHONE_SIMULATOR: capture");
    
    //UIImage *captureimage = [UIImage imageNamed:@"camera_test_image.jpeg"];
    //NSData *capturedata = UIImagePNGRepresentation(captureimage);
    
    time_t taken = (time_t) [[NSDate date] timeIntervalSince1970];
    
    //[self finishCapture:taken photoData:capturedata image:captureimage];
    
    
    UIImage *captureimage = [UIImage imageNamed:@"camera_test_image.jpeg"];
    UIImageView *captureimageview = [[UIImageView alloc] initWithImage:captureimage];
                                     
    UIView* captureview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, captureimageview.frame.size.width, captureimageview.frame.size.height)];
    [captureview addSubview:captureimageview];
    
    UILabel *capturelabel = [[UILabel alloc]initWithFrame:CGRectMake(20,20,2000,200)];
    capturelabel.backgroundColor = [UIColor clearColor];
    capturelabel.font = [UIFont boldSystemFontOfSize:96];
    capturelabel.textColor = [UIColor blackColor];
    capturelabel.text = @"Test Photo";
    [captureview addSubview:capturelabel];
    
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm:ss.SSSS"];
    NSDate *now = [[NSDate alloc] init];
    NSString *dateString = [format stringFromDate:now];
    
    UILabel *datelabel = [[UILabel alloc]initWithFrame:CGRectMake(20,110,2000,200)];
    datelabel.backgroundColor = [UIColor clearColor];
    datelabel.font = [UIFont boldSystemFontOfSize:60];
    datelabel.textColor = [UIColor blackColor];
    datelabel.text = dateString;
    [captureview addSubview:datelabel];
    
    int pnum = [gZZ integerForSetting:0 setting:@"test_photo_num"];
    if (pnum <= 0)
        pnum = 1;
    NSString *pstr = [NSString stringWithFormat:@"%d", pnum];
    pnum++;
    [gZZ setIntegerForSetting:0 setting:@"test_photo_num" value:pnum];
    [gZZ saveSettings];

    
    UILabel *pnumlabel = [[UILabel alloc]initWithFrame:CGRectMake(0,300,1000,600)];
    pnumlabel.backgroundColor = [UIColor clearColor];
    pnumlabel.font = [UIFont boldSystemFontOfSize:380];
    pnumlabel.textColor = [UIColor blackColor];
    pnumlabel.text = pstr;
    pnumlabel.alpha = 0.6;
    [pnumlabel setTextAlignment:UITextAlignmentCenter];
    [captureview addSubview:pnumlabel];
    
    UILabel *vlabel = [[UILabel alloc]initWithFrame:CGRectMake(20,1050,2000,200)];
    vlabel.backgroundColor = [UIColor clearColor];
    vlabel.font = [UIFont boldSystemFontOfSize:35];
    vlabel.textColor = [UIColor blackColor];
    vlabel.text = [NSString stringWithFormat:@"ZangZing iPhone app - version %@", [gZZ version]];
    [captureview addSubview:vlabel];
    
    UIGraphicsBeginImageContext(captureview.bounds.size);
    [captureview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *capturedata = UIImagePNGRepresentation(cimage);
    [self finishCapture:taken photoData:capturedata image:cimage];
    
#endif
    
}


- (void)actionView:(NSString*)action
{
    MLOG(@"CameraViewController: actionView: %@", action);
    
    if ([action isEqualToString:@"takepict"]) {
        
        [self capture];
        MLOG(@"action: TAKEPICT");
        
        [gZZ report_memory];
    }
    else if ([action isEqualToString:@"add"]) {
        
        MLOG(@"action: ADD");
        
        if (![ZZSession currentSession]) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Not Signed In" message:@"You must be signed in to upload photos." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        if ([gPhotoUploader photoCount] == 0) {

            // no photos to upload
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Photos" message:@"There are no photos to upload.  Go ahead and take some photos." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        
        //photo.image = [gPhotoUploader lastPhoto];
        //photo.contentMode = 0;                 
        //[self.view insertSubview:photo atIndex:1];
        
        gZZ.uploadSource = @"CameraViewController";
        self.navigationController.navigationBarHidden = NO;

        _savephoto = [[SavePhotoViewController alloc] initWithNibName:@"SavePhoto" bundle:nil];
        [_savephoto setDelegate:self];
        [self.navigationController pushViewController:_savephoto animated:YES];        
        [gV hideTabbar:YES];
        [self showFilters:NO];
        [self hidePile];
        [self stopCamera];
        [self hideCameraControls];

        
    }
    else if ([action isEqualToString:@"cancel"]) {
        
        MLOG(@"action: CANCEL");
        
        [photo removeFromSuperview];
        [self showFilters:NO];
        [gV switchTabbar:kTABBAR_CameraBar selectedTab:-1];
        [self startCamera];
    }
    else if ([action isEqualToString:@"back"]) {
        
        MLOG(@"action: BACK");
        
        int pcount = [gPhotoUploader photoCount];
        if (pcount > 0) {
            
            NSString *message;
            NSString *keepButtonTitle;
            NSString *deleteButtonTitle;
            
            if (pcount == 1) {
                message = @"You have taken 1 photo.  You can keep this photo for later or just delete it.  What would you like to do?";
                keepButtonTitle = @"Keep Photo";
                deleteButtonTitle = @"Delete Photo";
            } else {
                message = [NSString stringWithFormat:@"You have taken %d photos.  You can keep these photos for later or just delete them.  What would you like to do?",pcount];
                keepButtonTitle = @"Keep Photos";
                deleteButtonTitle = @"Delete Photos";
            }
            
            UIActionSheet *pActionSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:keepButtonTitle destructiveButtonTitle:deleteButtonTitle otherButtonTitles:nil, nil];
            pActionSheet.tag = 1;
            pActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [pActionSheet showInView:self.view];
        } else {
            // dismiss immediately
            [self stopCamera];
            [gV switchToView:kTABBAR_MainBar selectedTab:0 viewController:NULL];
        }
    }
}


-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
             // delete
            [gPhotoUploader clearPhotos];
        }
        
        [self stopCamera];
        [gV switchToView:kTABBAR_MainBar selectedTab:0 viewController:NULL];
    }
}


- (void)goUseCamera:(id)sender
{
    // toggle camera
    
    if (_isback) {
        // use front camera
        
        MLOG(@"activate FRONT camera");
        if (![self isFrontCameraAvailable])
            return;
        
        [self setCamera:NO];
        
        _flashon.hidden = YES;
        _flashoff.hidden = YES;
        _flashauto.hidden = YES;
        
        [ZZGlobal trackEvent:@"camera.front.set" xdata:nil];
    } else {
        // use back camera
        
        MLOG(@"activate BACK camera");

        [self setCamera:YES];   
        
        [self setFlashControls];

        [ZZGlobal trackEvent:@"camera.back.set" xdata:nil];
    }
}

-(void)goFlashSelect:(id)sender
{
    MLOG(@"tap flash control");
    
    _flashcontrol.hidden = NO;
    
    _flashauto.hidden = YES;
    _flashon.hidden = YES;
    _flashoff.hidden = YES;
    _flashtorchoff.hidden = YES;
    _flashtorchon.hidden = YES;
    
    _flashcontrol.frame = CGRectMake(10, 15, 50, _flashcontrol.image.size.height);
    //_flashcontrol.bounds = CGRectMake(0, 0, 0, _flashcontrol.image.size.height);
    _flashcontrol.hidden = NO;
    _flashcontrol.contentMode = UIViewContentModeScaleAspectFill | UIViewContentModeLeft;
    _flashcontrol.clipsToBounds = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDone:finished:context:)];
    
    _flashcontrol.contentMode = UIViewContentModeScaleToFill;
    _flashcontrol.frame = CGRectMake(10, 15, kFlashControlWidth, _flashcontrol.image.size.height);
    //_flashcontrol.bounds = CGRectMake(0, 0, kFlashControlWidth, _flashcontrol.image.size.height);
    
    [UIView commitAnimations];
}

- (void)imageTap:(ZZUIImageView *)image
{
    MLOG(@"CameraViewController: imageTap");
    
    if (image == _flashcontrol) {
        
        _flashcontrol.hidden = YES;
        _flashauto.hidden = YES;
        _flashon.hidden = YES;
        _flashoff.hidden = YES;
        
        // determine tap location to set new flash mode
        MLOG(@"tap location: %f %f", image.tapLocation.x, image.tapLocation.y);
        
        if (image.tapLocation.x > 135) {
            // click on off
            MLOG(@"tap flash OFF");
            _flashoff.hidden = NO;
            _flashmode = AVCaptureFlashModeOff;
            [self setFlashMode:AVCaptureFlashModeOff];
            
            [ZZGlobal trackEvent:@"camera.flash.off.set" xdata:nil];

        } else if (image.tapLocation.x > 54) {
            // click on on
            MLOG(@"tap flash ON");
            _flashon.hidden = NO;
            _flashmode = AVCaptureFlashModeOn;
            [self setFlashMode:AVCaptureFlashModeOn];
            
            [ZZGlobal trackEvent:@"camera.flash.on.set" xdata:nil];
            
        } else {
            // click on auto
            MLOG(@"tap flash AUTO");
            _flashauto.hidden = NO;
            _flashmode = AVCaptureFlashModeAuto;
            [self setFlashMode:AVCaptureFlashModeAuto];
            
            [ZZGlobal trackEvent:@"camera.flash.auto.set" xdata:nil];
        }
        
    } else if (image == _photopile) {
                    
        MLOG(@"tap photo pile");
        
        PhotoBrowser *pvController = [[PhotoBrowser alloc] initWithPhotos:[gPhotoUploader getPhotos]];
        [pvController setPhotoKeys:[gPhotoUploader getPhotosKeys]];
        [pvController setDelegate:self];
        [pvController setUseMode:AsPhotoEditor];
        [pvController setInitialPageIndex:image.photoIndex-1]; 
        
        [self.navigationController pushViewController:pvController animated:YES];
    
    } else {
        
        /*
        MLOG(@"filter tap: %d", image.tag);
        
        UIView *v;
        
        v = [_filterPreviewsFrames objectAtIndex:_currentFilter-1];
        [v setBackgroundColor:[UIColor whiteColor]];
        
        _currentFilter = image.tag;
        
        UIImage *fimage = [self applyFilter:_currentFilter image:captured fullsize:YES];
        photo.image = fimage;
        [photo setNeedsDisplay];
        
        v = [_filterPreviewsFrames objectAtIndex:_currentFilter-1];
        [v setBackgroundColor:[UIColor yellowColor]];
        
        MLOG(@"filter in place");
        */
        
    }
    
}


- (void)animationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context {

    _flashauto.hidden = YES;
    _flashon.hidden = YES;
    _flashoff.hidden = YES;
    _flashtorchoff.hidden = YES;
    _flashtorchon.hidden = YES;
}



- (void)addPhotoAction:(ZZUserID)userid albumid:(ZZAlbumID)albumid shareData:(NSDictionary*)shareData;
{
    _saveuserid = userid;
    _savealbumid = albumid;
    
    _savephoto.navigationController.navigationBarHidden = YES;
    [_savephoto.navigationController popViewControllerAnimated:YES];
    _savephoto = nil;
    
    [gV hideTabbar:NO];
    [gV switchToView:kTABBAR_MainBar selectedTab:0 viewController:NULL];
    
    [gPhotoUploader queuePhotos:_saveuserid albumid:_savealbumid shareData:shareData];
}


- (void)cancelPhotoAction
{
    _savephoto.navigationController.navigationBarHidden = YES;
    [_savephoto.navigationController popViewControllerAnimated:YES];
    _savephoto = nil;
    
    [gV hideTabbar:NO];
    [self showPile:nil photoCount:[gPhotoUploader photoCount]];
    [self startCamera];
}


// filters

-(UIImage*)applyHueFilter:(float)hue image:(UIImage*)image fullsize:(BOOL)fullsize
{
    // hue: This is an angular measurement that can vary from 0.0 to 2 pi. A value of 0 indicates the color red; the color green corresponds to 2/3 pi radians, and the color blue is 4/3 pi radian
    
    if (hue < 0)
        hue = 0;
    
    MLOG(@"applyHueFilter: hue: %f", hue);

    CIImage *ciimage = [[CIImage alloc]initWithImage:image];
    
    CIFilter *hueAdjust = [CIFilter filterWithName:@"CIHueAdjust"];
    [hueAdjust setDefaults];
    [hueAdjust setValue: ciimage forKey: @"inputImage"];
    [hueAdjust setValue: [NSNumber numberWithFloat: hue] forKey: @"inputAngle"];
    CIImage *result = [hueAdjust valueForKey: @"outputImage"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef ref = [context createCGImage:result fromRect:ciimage.extent];
    
    UIImageOrientation orientation = UIImageOrientationUp;
    if (fullsize)
        orientation = UIImageOrientationRight;
    UIImage *imageout = [UIImage imageWithCGImage:ref scale:1.0 orientation:orientation];
    CGImageRelease(ref);
    
    return imageout;
}


-(UIImage*)applyGloomFilter:(float)radius intensity:(float)intensity image:(UIImage*)image fullsize:(BOOL)fullsize
{
    // radius: 0 to 100
    // intensity: 0 to 1
    
    if (radius < 0)
        radius = 0;
    if (radius > 100)
        radius = 100;
    if (intensity < 0)
        intensity = 0;
    if (intensity > 1) 
        intensity = 1;
        
    MLOG(@"applyGloomFilter: radius: %f, intensity: %f", radius, intensity);

    CIImage *ciimage = [[CIImage alloc]initWithImage:image];

    CIFilter *gloom = [CIFilter filterWithName:@"CIGloom"];
    [gloom setDefaults];
    [gloom setValue: ciimage forKey: @"inputImage"];
    [gloom setValue: [NSNumber numberWithFloat: radius] forKey: @"inputRadius"];
    [gloom setValue: [NSNumber numberWithFloat: intensity] forKey: @"inputIntensity"];
    CIImage *result = [gloom valueForKey: @"outputImage"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef ref = [context createCGImage:result fromRect:ciimage.extent];
    
    UIImageOrientation orientation = UIImageOrientationUp;
    if (fullsize)
        orientation = UIImageOrientationRight;
    UIImage *imageout = [UIImage imageWithCGImage:ref scale:1.0 orientation:orientation];
    CGImageRelease(ref);
    
    return imageout;
}


-(UIImage*)applyFilter:(int)filter image:(UIImage*)image  fullsize:(BOOL)fullsize
{
    MLOG(@"applyFilter: %d", filter);

    switch (filter) {
        case 1:
            return image;
            break;
            
        case 2:
            return [self applyHueFilter:2 image:image fullsize:fullsize];
            break;
            
        case 3:
            return [self applyHueFilter:100 image:image fullsize:fullsize];
            break;            
            
        case 4:
            return [self applyHueFilter:500 image:image fullsize:fullsize];
            break;     
            
        case 5:
            return [self applyHueFilter:20 image:image fullsize:fullsize];
            //return [self applyGloomFilter:5 intensity:0.75 image:image fullsize:fullsize];
            break; 
            
        default:
            return image;
            break;
        
    }
}


- (void)photoBrowserDone:(PhotoBrowser*)photoBrowser
{
    MLOG(@"CameraViewController: photoBrowserDone");
    
    [gV switchTabbar:kTABBAR_CameraBar selectedTab:-1 actionViewController:self];
    self.navigationController.navigationBarHidden = YES;
    
    if ([gPhotoUploader photoCount]==0)
        [self hidePile];
    else {
        [self showPile:[gPhotoUploader lastPhoto] photoCount:[gPhotoUploader photoCount]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    [self startCamera];
}


@end
