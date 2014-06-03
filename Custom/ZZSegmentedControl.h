//
//  ZZSegmentedControl.h
//  ZZSegmentedControls
//
//  based on the original produced by Peter Boctor on 12/10/10.
//
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifndef ZZSEGMENTED_CONTROL_TYPES
#define ZZSEGMENTED_CONTROL_TYPES
#define ZZSEGMENTED_ALBUM_PRIVACY_CONTROL  1
#endif


typedef enum {
    CapLeft          = 0,
    CapMiddle        = 1,
    CapRight         = 2,
    CapLeftAndRight  = 3
} CapLocation;

@class ZZSegmentedControl;
@protocol ZZSegmentedControlDelegate

//- (UIButton*) buttonFor:(ZZSegmentedControl*)segmentedControl atIndex:(NSUInteger)segmentIndex;

@optional
- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex;
- (void) touchDownAtSegmentIndex:(NSUInteger)segmentIndex;
@end

@interface ZZSegmentedControl : UIView
{
    NSObject <ZZSegmentedControlDelegate> *delegate;
    NSMutableArray* buttons;
    NSDictionary *_segmentdef;
    NSUInteger _selectedSegment;
    UIColor *_buttonFontColor;
    UIColor *_buttonSelectedFontColor;
}

@property (nonatomic, strong) NSMutableArray* buttons;

- (id) initWithSegmentCount:(NSUInteger)segmentCount selectedSegment:(NSUInteger)selectedSegment segmentdef:(NSDictionary*)segmentdef tag:(NSInteger)objectTag delegate:(NSObject <ZZSegmentedControlDelegate>*)ZZSegmentedControlDelegate;
- (UIButton*) buttonFor:(NSUInteger)segmentIndex;
-(void)selectSegment:(NSUInteger)segment;

@end
