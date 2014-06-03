#import "MBaseViewController.h"
#import "JTRevealSidebarV2Delegate.h"

// Orientation changing is not an officially completed feature,
// The main thing to fix is the rotation animation and the
// necessarity of the container created in AppDelegate. Please let
// me know if you've got any elegant solution and send me a pull request!
// You can change EXPERIEMENTAL_ORIENTATION_SUPPORT to 1 for testing purpose
#ifdef DEBUG
#define EXPERIEMENTAL_ORIENTATION_SUPPORT 1
#endif

@class SidebarViewController;

@interface SlideOutController : MBaseViewController <JTRevealSidebarV2Delegate, UITableViewDelegate> {
#if EXPERIEMENTAL_ORIENTATION_SUPPORT
    CGPoint _containerOrigin;
#endif
}

@property (nonatomic, strong) SidebarViewController *leftSidebarViewController;
@property (nonatomic, strong) UITableView *rightSidebarView;
@property (nonatomic, strong) NSIndexPath *leftSelectedIndexPath;
@property (nonatomic, strong) UILabel     *label;

@end
