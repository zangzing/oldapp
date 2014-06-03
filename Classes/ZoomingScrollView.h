
#import <Foundation/Foundation.h>
#import "UIImageViewTap.h"
#import "UIViewTap.h"

@class PhotoBrowser;

@interface ZoomingScrollView : UIScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate> {
	
	// Browser
	PhotoBrowser *__unsafe_unretained photoBrowser;
	
	// State
	NSUInteger index;
	
	// Views
	UIViewTap *tapView; // for background taps
	UIImageViewTap *photoImageView;
	UIActivityIndicatorView *spinner;
	
}

// Properties
@property (nonatomic) NSUInteger index;
@property (nonatomic, unsafe_unretained) PhotoBrowser *photoBrowser;

// Methods
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;

@end
