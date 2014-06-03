
#import "photouploader.h"
#import "PhotoBrowser.h"
#import "ZoomingScrollView.h"
#import "MainViewController.h"
#import "ZZUINavigationBar.h"
#import "SavePhotoViewController.h"
#import "ZZAppDelegate.h"

#define PADDING 10      // between frames
#define kCaptionContainer_Height     48

// Handle depreciations and supress hide warnings
@interface UIApplication (DepreciationWarningSuppresion)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end


@implementation PhotoBrowser

- (id)initWithPhotos:(NSArray *)photosArray 
{
	if ((self = [super init])) {
		
		// Store photos
		photos = [[NSMutableArray alloc]initWithArray:photosArray copyItems:NO];
		
        // Defaults
		//self.wantsFullScreenLayout = YES;
        //self.hidesBottomBarWhenPushed = YES;
		currentPageIndex = 0;
		performingLayout = NO;
		rotating = NO;
        
        useMode = AsPhotoBrowser;
        isSetup = NO;
	}
	return self;
}

-(void)setPhotos:(NSArray*)photosArray
{
    photos = [[NSMutableArray alloc]initWithArray:photosArray copyItems:NO];
    
    [self setupView];
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
	
	MLOG(@"PhotoBrowser: didReceiveMemoryWarning");
	
	// Release images
	[photos makeObjectsPerformSelector:@selector(releasePhoto)];
	[recycledPages removeAllObjects];
	
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


-(void)setupScrollView:(NSInteger)viewIndex
{
    // Setup paging scrolling view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	pagingScrollView.pagingEnabled = YES;
	pagingScrollView.delegate = self;
	pagingScrollView.showsHorizontalScrollIndicator = NO;
	pagingScrollView.showsVerticalScrollIndicator = NO;
	pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:currentPageIndex];
    
    if (viewIndex == -1)
        [self.view addSubview:pagingScrollView];
    else    
        [self.view insertSubview:pagingScrollView atIndex:viewIndex];
	
	// Setup pages
	visiblePages = [[NSMutableSet alloc] init];
	recycledPages = [[NSMutableSet alloc] init];
	[self tilePages];
}


-(void)setupView
{
    // View
	self.view.backgroundColor = [UIColor blackColor];
    
    if (isSetup) {
        [pagingScrollView removeFromSuperview];
        pagingScrollView = nil;
    }
	
	[self setupScrollView:-1];
    
    //if (!isSetup) {
    //    [self setNavbar:self.interfaceOrientation];
    // }
    
    if (useMode == AsPhotoBrowser) {
        [gV switchTabbar:kTABBAR_PictureBar selectedTab:-1];
    } else {
        [gV switchTabbar:kTABBAR_CameraReview selectedTab:-1 actionViewController:self];
        NSString *s = [NSString stringWithFormat:@"1 of %u", [photos count]];
        [gV setTabbarText:s];
        
        if (!isSetup) {

            // setup caption editor
            UIImage *captionbackimage = [UIImage imageNamed:@"caption-background.png"];
            UIImage *captiontextboxbackimage = [UIImage imageNamed:@"caption-textbox-background.png"];
            
            int captioncontainerheight = captionbackimage.size.height;
            
            captionContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 480 - (49 + captioncontainerheight + 20), 320, captioncontainerheight)];
            [captionContainer setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:captionContainer];
            
            UIImageView *captionback = [[UIImageView alloc]initWithImage:captionbackimage];
            captionback.frame = CGRectMake(0, 0, captionbackimage.size.width, captionbackimage.size.height);
            [captionContainer addSubview:captionback];
            
            UIImageView *captiontextboxback = [[UIImageView alloc]initWithImage:captiontextboxbackimage];
            captiontextboxback.frame = CGRectMake((320-captiontextboxbackimage.size.width)/2, (captioncontainerheight-captiontextboxbackimage.size.height)/2, captiontextboxbackimage.size.width, captiontextboxbackimage.size.height);
            [captionContainer addSubview:captiontextboxback];
            
            caption  = [[UITextField alloc]initWithFrame:CGRectMake(((320-captiontextboxbackimage.size.width)/2)+5, ((captioncontainerheight-captiontextboxbackimage.size.height)/2)+3, captiontextboxbackimage.size.width-10, captiontextboxbackimage.size.height-8)];
            
            caption.borderStyle = UITextBorderStyleNone;
            caption.textColor = [UIColor blackColor]; 
            caption.font = [UIFont systemFontOfSize:15];  
            caption.placeholder = @"Add a caption...";  
            caption.backgroundColor = [UIColor clearColor]; 
            caption.autocorrectionType = UITextAutocorrectionTypeNo;	
            caption.keyboardType = UIKeyboardTypeDefault;  
            caption.returnKeyType = UIReturnKeyDone; 
            caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            caption.delegate = self;	
            [captionContainer addSubview:caption];
            
            // Need to place the overlay placeholder exactly above the original placeholder
            overlayPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(caption.frame.origin.x, caption.frame.origin.y + 2, caption.frame.size.width - 16, caption.frame.size.height - 4)];
            overlayPlaceholderLabel.backgroundColor = [UIColor clearColor];
            overlayPlaceholderLabel.opaque = YES;
            overlayPlaceholderLabel.text = caption.placeholder;
            overlayPlaceholderLabel.textColor = [UIColor darkGrayColor];
            overlayPlaceholderLabel.font = caption.font;
            // Need to add it to the superview, as otherwise we cannot overlay the buildin text label.
            [caption.superview addSubview:overlayPlaceholderLabel];
            caption.placeholder = nil;
            

            int width = 84;
            CGFloat capWidth = 5.0;
            UIImage* bimage = [[UIImage imageNamed:@"camera-button-1.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
            UIImage* bimage2 = [[UIImage imageNamed:@"camera-button-1-selected.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
            
            trashcanButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [trashcanButton setBackgroundImage:bimage forState:UIControlStateNormal];
            [trashcanButton setBackgroundImage:bimage2 forState:UIControlStateHighlighted];
            
            UIImage *trashcanimage = [UIImage imageNamed:@"camera-trashcan.png"];
            UIImageView *trashcan = [[UIImageView alloc]initWithImage:trashcanimage];
            trashcan.frame = CGRectMake(8, 7, trashcanimage.size.width, trashcanimage.size.height);
            [trashcanButton addSubview:trashcan];
            
            UILabel *trashcanlabel = [[UILabel alloc]initWithFrame:CGRectMake(26, 7+2, 60, 15)];
            trashcanlabel.font = [UIFont boldSystemFontOfSize:16];
            trashcanlabel.text = @"Delete";
            [trashcanlabel setTextColor:[UIColor colorWithRed: 33.0/255.0 green: 33.0/255.0 blue: 33.0/255.0 alpha: 1.0]];
            trashcanlabel.backgroundColor = [UIColor clearColor];
            [trashcanButton addSubview:trashcanlabel];                          
            
            trashcanButton.frame = CGRectMake(320-width-10, 30, width, bimage.size.height);
            [trashcanButton addTarget:self action:@selector(trashPhoto:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:trashcanButton];
            
            captionEditing = NO;
        }
 
        [self refreshEditing];
    }
    
    isSetup = YES;
}


-(void)viewDone
{
    MLOG(@"PhotoBrowser: viewDone");
    
    [photos makeObjectsPerformSelector:@selector(releasePhoto)];
    photos = nil;
    
	currentPageIndex = 0;
    pagingScrollView = nil;
    visiblePages = nil;
    recycledPages = nil;    
}


// Release any retained subviews of the main view.
- (void)viewDidUnload 
{
    MLOG(@"PhotoBrowser: viewDidUnload");
    
	[self viewDone];
}


#pragma mark -
#pragma mark View


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	[self setupView];
}


- (void)setNavbar:(UIInterfaceOrientation)toInterfaceOrientation
{
    ZZUINavigationBar* navbar = (ZZUINavigationBar*)self.navigationController.navigationBar;
    [navbar clearBackground];
    self.navigationController.navigationBar.translucent = YES; 
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    UIImage *bimage;
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
        bimage = [UIImage imageNamed:@"back-black-portrait.png"];
    else
        bimage = [UIImage imageNamed:@"back-black-landscape.png"];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:bimage forState:UIControlStateNormal];
    [backButton setTitle:@"   Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    backButton.frame = CGRectMake(0, 0, bimage.size.width, bimage.size.height);
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftButton;
}


- (void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
	
	// Layout
	[self performLayout:UIInterfaceOrientationPortrait];        // *** current orientation?
    
    // Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
	// Navigation
	[self updateNavigation];
	[self hideControlsAfterDelay];
	[self didStartViewingPageAtIndex:currentPageIndex]; // initial
}


-(void)willAppearIn:(UINavigationController *)navigationController
{
    if (useMode != AsPhotoEditor)
        return;
    
    ZZUINavigationBar* navbar = (ZZUINavigationBar*)navigationController.navigationBar;
    navbar.translucent = NO; 
    navbar.tintColor = nil;
    [navbar setBackgroundWith:[UIImage imageNamed:@"nav-background.png"]];
}


- (void)viewWillDisappear:(BOOL)animated {
	
	// Super
	[super viewWillDisappear:animated];
    
	// Cancel any hiding timers
	[self cancelControlHiding];
}




-(void)switchFromView
{
    MLOG(@"PhotoBrowser: switchFromView");
    
    [self cancelControlHiding];
}



#pragma mark -
#pragma mark Layout

// Layout subviews
- (void)performLayout:(UIInterfaceOrientation)toInterfaceOrientation {
	
    currentLayout = toInterfaceOrientation;
    
	// Flag
	performingLayout = YES;	
	
	// Remember index
	NSUInteger indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
	pagingScrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (ZoomingScrollView *page in visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		[page setMaxMinZoomScalesForCurrentBounds];
	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
	performingLayout = NO;
    
    [self setNavbar:toInterfaceOrientation];
    
}

#pragma mark -
#pragma mark Photos

// Get image if it has been loaded, otherwise nil
- (UIImage *)imageAtIndex:(NSUInteger)index {
	if (photos && index < photos.count) {
        
		// Get image or obtain in background
		BrowsePhoto *photo = [photos objectAtIndex:index];
		if ([photo isImageAvailable]) {
			return [photo image];
		} else {
			[photo obtainImageInBackgroundAndNotify:self];
		}
		
	}
	return nil;
}

#pragma mark -
#pragma mark BrowsePhotoDelegate

- (void)photoDidFinishLoading:(BrowsePhoto *)photo {
    
    //MLOG(@"photoDidFinishLoading: %f", [[NSDate date] timeIntervalSince1970]);

	NSUInteger index = [photos indexOfObject:photo];
	if (index != NSNotFound) {
		if ([self isDisplayingPageForIndex:index]) {
			
			// Tell page to display image again
			ZoomingScrollView *page = [self pageDisplayedAtIndex:index];
			if (page) [page displayImage];
			
		}
	}
}

- (void)photoDidFailToLoad:(BrowsePhoto *)photo {
	NSUInteger index = [photos indexOfObject:photo];
	if (index != NSNotFound) {
		if ([self isDisplayingPageForIndex:index]) {
			
			// Tell page it failed
			ZoomingScrollView *page = [self pageDisplayedAtIndex:index];
			if (page) [page displayImageFailure];
			
		}
	}
}

#pragma mark -
#pragma mark Paging

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = pagingScrollView.bounds;
	int iFirstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > photos.count - 1) iFirstIndex = photos.count - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > photos.count - 1) iLastIndex = photos.count - 1;
	
	// Recycle no longer needed pages
	for (ZoomingScrollView *page in visiblePages) {
		if (page.index < (NSUInteger)iFirstIndex || page.index > (NSUInteger)iLastIndex) {
			[recycledPages addObject:page];
			/*MLOG(@"Removed page at index %i", page.index);*/
			page.index = NSNotFound; // empty
			[page removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
			ZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[ZoomingScrollView alloc] init];
				page.photoBrowser = self;
			}
			[self configurePage:page forIndex:index];
			[visiblePages addObject:page];
			[pagingScrollView addSubview:page];
			/*MLOG(@"Added page at index %i", page.index);*/
		}
	}
	
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (ZoomingScrollView *page in visiblePages)
		if (page.index == index) return YES;
	return NO;
}

- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    
    MLOG(@"pageDisplayedAtIndex: %d", index);
	
    ZoomingScrollView *thePage = nil;
	for (ZoomingScrollView *page in visiblePages) {
		if (page.index == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
	page.index = index;
}

- (ZoomingScrollView *)dequeueRecycledPage {
	ZoomingScrollView *page = [recycledPages anyObject];
	if (page) {
		[recycledPages removeObject:page];
	}
	return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    
    MLOG(@"didStartViewingPageAtIndex: %d", index);

    if (useMode == AsPhotoEditor) {
        NSString *s = [NSString stringWithFormat:@"%u of %u", index+1, [photos count]];
        [gV setTabbarText:s];
    }
    
    NSUInteger i;
    if (index > 0) {
        
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) { [(BrowsePhoto *)[photos objectAtIndex:i] releasePhoto]; /*MLOG(@"Release image at index %i", i);*/ }
        
        // Preload index - 1
        i = index - 1; 
        if (i < photos.count) { [(BrowsePhoto *)[photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self]; /*MLOG(@"Pre-loading image at index %i", i);*/ }
        
    }
    if (index < photos.count - 1) {
        
        // Release anything > index + 1
        for (i = index + 2; i < photos.count; i++) { [(BrowsePhoto *)[photos objectAtIndex:i] releasePhoto]; /*MLOG(@"Release image at index %i", i);*/ }
        
        // Preload index + 1
        i = index + 1; 
        if (i < photos.count) { [(BrowsePhoto *)[photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self]; /*MLOG(@"Pre-loading image at index %i", i);*/ }
        
    }
    
    if (captionEditing) {
        [self captionEditBegin];
    }
}

#pragma mark -
#pragma mark Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * photos.count, bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}


- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation {
    
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
    
    MLOG(@"navframe: orient/isportrait: %d %d, frame: %d %d %f %f", orientation, UIInterfaceOrientationIsPortrait(orientation), 0, 20, self.view.bounds.size.width, height);
    MLOG(@"photobrowser view.frame: x:%f y:%f width:%f height:%f", self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height);
    
	return CGRectMake(0, 20, self.view.bounds.size.width, height);
}


#pragma mark -
#pragma mark UIScrollView Delegate

-(void)refreshEditing
{
    if (useMode != AsPhotoEditor)
        return;
    
    // update caption if available
    NSString *captionText = [gPhotoUploader getCaption:[photoKeys objectAtIndex:currentPageIndex]];
    if (captionText) {
        caption.text = captionText;
    } else {
        caption.text = @"";
    }
    
    overlayPlaceholderLabel.hidden = YES;
    if (caption.text.length == 0) {
        overlayPlaceholderLabel.hidden = NO;
    }
    
    [caption setNeedsDisplay];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (performingLayout || rotating) return;
	
    if (captionEditing) {
        [self captionEditEnd];
    }
    
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = pagingScrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > photos.count - 1) index = photos.count - 1;
	NSUInteger previousCurrentPage = currentPageIndex;
	currentPageIndex = index;
	if (currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
        [self refreshEditing];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
	[self setControlsHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Update nav when page changes
	[self updateNavigation];
}

#pragma mark -
#pragma mark Navigation

- (void)updateNavigation {
    
	// ***
    /*
     if (photos.count > 1) {
     self.title = [NSString stringWithFormat:@"%i of %i", currentPageIndex+1, photos.count];		
     } else {
     self.title = nil;
     }
     
     // Buttons
     previousButton.enabled = (currentPageIndex > 0);
     nextButton.enabled = (currentPageIndex < photos.count-1);
     */
}


- (void)jumpToPageAtIndex:(NSUInteger)index {
	
	// Change page
	if (index < photos.count) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
		pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
        
        NSLog(@"%f content offset as on index: %d", pagingScrollView.contentOffset.x, index);
        
		[self updateNavigation];
        
        [self refreshEditing];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)gotoPreviousPage 
{ 
    [self jumpToPageAtIndex:currentPageIndex-1]; 
}


- (void)gotoNextPage 
{ 
    [self jumpToPageAtIndex:currentPageIndex+1]; 
}


-(void)deletePhoto
{
    if (useMode == AsPhotoBrowser)
        return;
    
    MLOG(@"deleting photo @ %d (count %d)", currentPageIndex, photoKeys.count);
    
    [gPhotoUploader removePhoto:[photoKeys objectAtIndex:currentPageIndex]];
    
    // remove from photos/photoKeys
    [photoKeys removeObjectAtIndex:currentPageIndex];
    [photos removeObjectAtIndex:currentPageIndex];
    
    if (photos.count > 0) {
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView: self.view cache: YES];
        [UIView commitAnimations];
    }
    
    if (photos.count == 0) {
        [self goBack:NULL];
    }
    else
    {
        if (currentPageIndex > 0) {
            // nth photo deleted, show previous
            currentPageIndex -= 1;
            
            pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
            pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:currentPageIndex];
                        
        } else {
            // first photo delete, currentPageIndex stays at 0
            NSInteger viewIndex = [self.view.subviews indexOfObject:pagingScrollView];
            [pagingScrollView removeFromSuperview];
            [self setupScrollView:viewIndex];
        }

        [self didStartViewingPageAtIndex:currentPageIndex];
        [self refreshEditing];
    }
    
    MLOG(@"now at %d photos", photoKeys.count);
}


#pragma mark -
#pragma mark Control Hiding / Showing

- (void)setControlsHidden:(BOOL)hidden {
	
    if (useMode == AsPhotoEditor)
        return;
    
	// Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Status Bar
	if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:YES];
	}
	
	// Get status bar height if visible
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
    
    //MLOG(@"statusBarHeight: %f, hiding: %d", statusBarHeight, hidden);
    //MLOG(@"photobrowser view.frame: x:%f y:%f width:%f height:%f", self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height);
    
	// Bars
    self.navigationController.navigationBarHidden = hidden;
    [gV hideTabbar:hidden];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if they are visible
	[self hideControlsAfterDelay];
    
	//MLOG(@"@hidden: navbar.frame: x:%f y:%f width:%f height:%f", navbar.frame.origin.x,navbar.frame.origin.y,navbar.frame.size.width, navbar.frame.size.height);
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (controlVisibilityTimer) {
		[controlVisibilityTimer invalidate];
		controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	[self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
            controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (void)hideControls { [self setControlsHidden:YES]; }
- (void)toggleControls { [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; }

#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    MLOG(@"willRotateToInterfaceOrientation: %d", toInterfaceOrientation);
    
	// Remember page index before rotation
	pageIndexBeforeRotation = currentPageIndex;
	rotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
    MLOG(@"willAnimateRotationToInterfaceOrientation: %d", toInterfaceOrientation);
    
	// Perform layout
	currentPageIndex = pageIndexBeforeRotation;
	[self performLayout:toInterfaceOrientation];
	
	// Delay control holding
	[self hideControlsAfterDelay];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    MLOG(@"didRotateFromInterfaceOrientation: %d", fromInterfaceOrientation);
    
	rotating = NO;
}


#pragma mark -
#pragma mark Properties

- (void)setInitialPageIndex:(NSUInteger)index {
    
    NSLog(@"setInitialPageIndex: %d", index);
    
	//if (![self isViewLoaded]) {
		if (index >= photos.count) {
			currentPageIndex = 0;
		} else {
			currentPageIndex = index;
		}
	//}
}


- (void)goBack:(id)sender
{
    MLOG(@"PhotoBrowser: goBack");
    
    [self cancelControlHiding];
        
    [self viewDone];
    
    if (delegate && [delegate respondsToSelector:@selector(photoBrowserDone:)]) 
        [delegate photoBrowserDone:self];        
}


- (void)trashPhoto:(id)sender
{
    NSString *message = @"Are you sure you want to delete this photo?";
    
    UIActionSheet *pActionSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:nil, nil];
    pActionSheet.tag = 1;
    pActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [pActionSheet showInView:self.view];
}


-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            // delete
            [self deletePhoto];
        }
    }
}


- (void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}


- (void)setUseMode:(PhotoBrowserUseMode)newUseMode
{
    useMode = newUseMode;
}


- (void)actionView:(NSString*)action
{
    MLOG(@"PhotoBrowser: actionView: %@", action);
    
    if ([action isEqualToString:@"back"]) {
        
        [self cancelControlHiding];
        
        [self viewDone];
        
        if (delegate && [delegate respondsToSelector:@selector(photoBrowserDone:)]) 
            [delegate photoBrowserDone:self];
                
    } else if ([action isEqualToString:@"add"]) {
        
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
        
        [gV hideTabbar:YES];
        
        self.wantsFullScreenLayout = NO;
        self.navigationController.navigationBarHidden = NO;

        gZZ.uploadSource = @"PhotoBrowser";
        _savephoto = [[SavePhotoViewController alloc] initWithNibName:@"SavePhoto" bundle:nil];
        [_savephoto setDelegate:self];
        [self.navigationController pushViewController:_savephoto animated:YES];
    }
}


- (void) animateTextField:(UIView*)textField up:(BOOL)up
{
    const int movementDistance = 167; 
    const float movementDuration = 0.3f; 
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    textField.frame = CGRectOffset(textField.frame, 0, movement);
    [UIView commitAnimations];
}


-(void)captionEditBegin
{
    overlayPlaceholderLabel.hidden = YES;
    
    NSString *captionText = [gPhotoUploader getCaption:[photoKeys objectAtIndex:currentPageIndex]];
    if (captionText)
        caption.text = captionText;
    else
        caption.text = @"";
}


-(void)captionEditEnd
{
    [gPhotoUploader setCaption:[photoKeys objectAtIndex:currentPageIndex] caption:caption.text];
}


- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    if (textField == caption) {
        
        captionEditing = YES;
        trashcanButton.hidden = YES;
        [self animateTextField:captionContainer up:YES];
        [self captionEditBegin];
    }
}


- (void)textFieldDidEndEditing:(UITextField*)textField
{
    if (textField == caption) {
        
        captionEditing = NO;
        trashcanButton.hidden = NO;
        [self animateTextField:captionContainer up:NO];
        [self captionEditEnd];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField*)textField 
{
    [textField resignFirstResponder];
    return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    overlayPlaceholderLabel.hidden = YES;
    return YES;
}


- (void) addPhotoAction:(ZZUserID)userid albumid:(ZZAlbumID)albumid shareData:(NSDictionary *)shareData
{
    _saveuserid = userid;
    _savealbumid = albumid;
    
    self.wantsFullScreenLayout = YES;
    _savephoto.navigationController.navigationBarHidden = YES;
    [_savephoto.navigationController popViewControllerAnimated:YES];
    _savephoto = nil;
    
    [gV hideTabbar:NO];
    [gV switchToView:kTABBAR_MainBar selectedTab:0 viewController:NULL];
    
    [gPhotoUploader queuePhotos:_saveuserid albumid:_savealbumid shareData:shareData];

}


- (void) cancelPhotoAction
{
    self.wantsFullScreenLayout = YES;
    _savephoto.navigationController.navigationBarHidden = YES;
    [_savephoto.navigationController popViewControllerAnimated:YES];
    _savephoto = nil;
    
    [gV hideTabbar:NO];
}


- (void)setPhotoKeys:(NSArray*)keys
{
    photoKeys = [[NSMutableArray alloc]initWithArray:keys copyItems:YES];
}





@end
