//
//  ZZTabBar.h
//  ZZTabBar
//
//  based on the original produced by Peter Boctor on 12/10/10.
//
//


@protocol ZZTabBarViewController

@optional
- (void)switchToView;                           // view becomes active
- (void)actionView:(NSString*)action;           // view sent action command

@end


typedef enum _ZZTabBarItemImageType {
    imageNone = 0,          // no image
	imageSet = 1,           // 2 images: unselected and selected
    imageMask = 2,          // 1 image, serves as a mask, unselected and selected are manufactured
    imageCamera = 3,        // special case: camera button
    buttonSet = 4           // buttons
} ZZTabBarItemImageType;

@class ZZTabBar;
@protocol ZZTabBarDelegate

- (NSString*) style;
- (int) xposFor:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex;
- (int) yposFor:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex;
- (NSString*) textFor:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex;
- (UIImage*) imageFor:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex selected:(BOOL)selected;
- (ZZTabBarItemImageType) imageType:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex;
- (UIImage*) backgroundImage;
- (UIImage*) selectedItemBackgroundImage;
- (UIImage*) glowImage;
- (UIImage*) selectedItemImage;
- (UIImage*) tabBarArrowImage;

@optional
- (void) touchUpInsideItemAtIndex:(NSUInteger)itemIndex;
- (void) touchDownAtItemAtIndex:(NSUInteger)itemIndex;
@end


@interface ZZTabBar : UIView
{
    NSObject <ZZTabBarDelegate> *delegate;
    NSMutableArray* buttons;
    NSMutableArray* titles;
    UIColor *titleNormalColor;
    UIColor *titleSelectedColor;
    UILabel* textLabel;
    
}

@property (nonatomic, strong) NSMutableArray* buttons;
@property (nonatomic, strong) NSMutableArray* titles;

- (id) initWithItemCount:(NSUInteger)itemCount itemSize:(CGSize)itemSize tag:(NSInteger)objectTag delegate:(NSObject <ZZTabBarDelegate>*)ZZTabBarDelegate;

- (void) setHidden:(BOOL)hidden;
- (void) selectItemAtIndex:(NSInteger)index;
- (void) glowItemAtIndex:(NSInteger)index;
- (void) removeGlowAtIndex:(NSInteger)index;
- (void) setText:(NSString*)text;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end
