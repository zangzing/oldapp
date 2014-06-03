
#import <UIKit/UIKit.h>
#import "zztypes.h"
#import "MainViewController.h"
#import "BrowsePhoto.h"

@class ZoomingScrollView;
@class PhotoBrowser;
@class SavePhotoViewController;

typedef enum 
{
    AsPhotoBrowser,
    AsPhotoEditor
} 
PhotoBrowserUseMode;

@protocol PhotoBrowserDelegate

@optional
- (void) photoBrowserDone:(PhotoBrowser*)photoBrowser;
@end


@interface PhotoBrowser : ZZUIViewController <UIScrollViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, BrowsePhotoDelegate> {
	
    NSObject <PhotoBrowserDelegate> *delegate;
    PhotoBrowserUseMode useMode;
    BOOL isSetup;
    
	// photos
	NSMutableArray *photos;
    NSMutableArray *photoKeys;
	
	// views
	UIScrollView *pagingScrollView;
	
	// paging
	NSMutableSet *visiblePages, *recycledPages;
	NSUInteger currentPageIndex;
	NSUInteger pageIndexBeforeRotation;
	
	// navigation & controls
	NSTimer *controlVisibilityTimer;

    // misc
	BOOL performingLayout;
	BOOL rotating;
	
    // for AsPhotoEditor
    BOOL captionEditing;    
    UIView *captionContainer;
    UITextField *caption;
    UILabel *overlayPlaceholderLabel;
    UIButton *trashcanButton;
    SavePhotoViewController *_savephoto;
    ZZUserID _saveuserid;
    ZZAlbumID _savealbumid;
    
    UIInterfaceOrientation currentLayout;
}

// Init
- (id)initWithPhotos:(NSArray *)photosArray;
- (void)setPhotos:(NSArray*)photosArray;
- (void)setupView;

// Photos
- (UIImage *)imageAtIndex:(NSUInteger)index;

// Layout
- (void)performLayout:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)setNavbar:(UIInterfaceOrientation)toInterfaceOrientation;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (ZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden;
- (void)toggleControls;

// Properties
- (void)setInitialPageIndex:(NSUInteger)index;

// misc
- (void)setDelegate:(id)newDelegate;
- (void)setUseMode:(PhotoBrowserUseMode)useMode;
- (void)refreshEditing;
- (void)setPhotoKeys:(NSArray*)keys;
- (void)deletePhoto;
- (void)goBack:(id)sender;
- (void)captionEditBegin;
- (void)captionEditEnd;

@end

