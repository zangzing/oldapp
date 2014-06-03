
#import <Foundation/Foundation.h>

@protocol UIImageViewTapDelegate;

@interface UIImageViewTap : UIImageView {
	id <UIImageViewTapDelegate> __unsafe_unretained tapDelegate;
}
@property (nonatomic, unsafe_unretained) id <UIImageViewTapDelegate> tapDelegate;
- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
@end

@protocol UIImageViewTapDelegate <NSObject>
@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;
@end