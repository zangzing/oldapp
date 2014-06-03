
#import <Foundation/Foundation.h>

// Class
@class BrowsePhoto;

// Delegate
@protocol BrowsePhotoDelegate <NSObject>
- (void)photoDidFinishLoading:(BrowsePhoto *)photo;
- (void)photoDidFailToLoad:(BrowsePhoto *)photo;
@end

// BrowsePhoto
@interface BrowsePhoto : NSObject {
	
	// Image
	NSString *photoPath;
	NSURL *photoURL;
	UIImage *photoImage;
	
	// Flags
	BOOL workingInBackground;
	
}

// Class
+ (BrowsePhoto*)photoWithImage:(UIImage *)image;
+ (BrowsePhoto*)photoWithFilePath:(NSString *)path;
+ (BrowsePhoto*)photoWithURL:(NSURL *)url;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

// Public methods
- (BOOL)isImageAvailable;
- (UIImage*)image;
- (UIImage*)obtainImage;
- (void)obtainImageInBackgroundAndNotify:(id <BrowsePhotoDelegate>)notifyDelegate;
- (void)releasePhoto;

@end
