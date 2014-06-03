
@protocol SidebarViewControllerDelegate;

@interface SidebarViewController : UITableViewController

@property (nonatomic, assign) id <SidebarViewControllerDelegate> sidebarDelegate;

@end

@protocol SidebarViewControllerDelegate <NSObject>

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController;

@end
