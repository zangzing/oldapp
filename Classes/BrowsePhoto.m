
#import "BrowsePhoto.h"
#import "UIImage+Decompress.h"
#import "zzglobal.h"

// Private
@interface BrowsePhoto ()

// Properties
@property (strong) UIImage *photoImage;
@property () BOOL workingInBackground;

// Private Methods
- (void)doBackgroundWork:(id <BrowsePhotoDelegate>)delegate;

@end


// BrowsePhoto
@implementation BrowsePhoto

// Properties
@synthesize photoImage, workingInBackground;

#pragma mark Class Methods

+ (BrowsePhoto *)photoWithImage:(UIImage *)image 
{
	return [[BrowsePhoto alloc] initWithImage:image];
}

+ (BrowsePhoto *)photoWithFilePath:(NSString *)path 
{
	return [[BrowsePhoto alloc] initWithFilePath:path];
}

+ (BrowsePhoto *)photoWithURL:(NSURL *)url 
{
	return [[BrowsePhoto alloc] initWithURL:url];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image 
{
	if ((self = [super init])) {
		self.photoImage = image;
	}
	return self;
}

- (id)initWithFilePath:(NSString *)path 
{
	if ((self = [super init])) {
		photoPath = [path copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url 
{
	if ((self = [super init])) {
		photoURL = [url copy];
	}
	return self;
}


#pragma mark Photo

// Return whether the image available
// It is available if the UIImage has been loaded and
// loading from file or URL is not required
- (BOOL)isImageAvailable 
{
	return (self.photoImage != nil);
}

// Return image
- (UIImage *)image 
{
	return self.photoImage;
}

// Get and return the image from existing image, file path or url
- (UIImage *)obtainImage 
{
	if (!self.photoImage) {
		
		// Load
		UIImage *img = nil;
        
		if (photoPath) { 
			
			// Read image from file
            
            //MLOG(@"obtainImage start %@: %f", photoPath, [[NSDate date] timeIntervalSince1970]);

            //NSTimeInterval start_c = [[NSDate date] timeIntervalSince1970];
            
			NSError *error = nil;
			NSData *data = [NSData dataWithContentsOfFile:photoPath options:NSDataReadingUncached error:&error];
			if (!error) {
				img = [[UIImage alloc] initWithData:data];
			} else {
				MLOG(@"Photo from file error: %@", error);
			}
            
            //NSTimeInterval end_c = [[NSDate date] timeIntervalSince1970];
            //NSLog(@"obtainImage from disk: %.2fs", end_c-start_c);
            
            //MLOG(@"obtainImage end %@: %f", photoPath, [[NSDate date] timeIntervalSince1970]);

		} else if (photoURL) { 
			
            // attempt to load from disk cache
            img = [gZZ getImage:[photoURL absoluteString]];
            if (img) {
                MLOG(@"Photo from disk cache: %@", [photoURL absoluteString]);
            } else {
                // read image from URL and return
                
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:photoURL];
                NSError *error = nil;
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (data) {
                    MLOG(@"Photo from network: %@", [photoURL absoluteString]);
                    // cache image to disk
                    [gZZ cacheImage:[photoURL absoluteString] imageData:data];
                    img = [[UIImage alloc] initWithData:data];
                } else {
                    MLOG(@"Photo from URL error: %@", error);
                }
            }
		}
        
		// Force the loading and caching of raw image data for speed
		//[img decompress];		
		
		// Store
		self.photoImage = img;
	}
	return self.photoImage;
}

// Release if we can get it again from path or url
- (void)releasePhoto 
{
	if (self.photoImage && (photoPath || photoURL)) {
        NSLog(@"release photo image: %@ %@", photoPath, photoURL);
        
		self.photoImage = nil;
	}
}

// Obtain image in background and notify the browser when it has loaded
- (void)obtainImageInBackgroundAndNotify:(id <BrowsePhotoDelegate>)delegate 
{
    //MLOG(@"obtain image in background %@: %f", photoPath, [[NSDate date] timeIntervalSince1970]);
    
	if (self.workingInBackground == YES) return; // Already fetching
	self.workingInBackground = YES;
	[self performSelectorInBackground:@selector(doBackgroundWork:) withObject:delegate];
}

// Run on background thread
// Download image and notify delegate
- (void)doBackgroundWork:(id <BrowsePhotoDelegate>)delegate 
{
    //MLOG(@"doBackgroundWork %@: %f", photoPath, [[NSDate date] timeIntervalSince1970]);
    
	@autoreleasepool {
        
        // Load image
		UIImage *img = [self obtainImage];
		
		// Notify delegate of success or fail
		if (img) {
			[(NSObject *)delegate performSelectorOnMainThread:@selector(photoDidFinishLoading:) withObject:self waitUntilDone:NO];
		} else {
			[(NSObject *)delegate performSelectorOnMainThread:@selector(photoDidFailToLoad:) withObject:self waitUntilDone:NO];		
		}
        
		// Finish
		self.workingInBackground = NO;
	}
}


@end
