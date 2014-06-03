
#import <Foundation/Foundation.h>

@protocol UIViewTapDelegate;

@interface UIViewTap : UIView {
	id <UIViewTapDelegate> __unsafe_unretained tapDelegate;
}
@property (nonatomic, unsafe_unretained) id <UIViewTapDelegate> tapDelegate;
- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
@end

@protocol UIViewTapDelegate <NSObject>
@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;
@end