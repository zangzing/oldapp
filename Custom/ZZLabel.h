

#import <Foundation/Foundation.h>


@interface ZZUILabel : UILabel {

    BOOL useSettings;
    float useBlur;
    int useOffsetX;
    int useOffsetY;
    UIColor *useShadowColor;
}

@property (nonatomic) BOOL useSettings;
@property (nonatomic) float useBlur;
@property (nonatomic) int useOffsetX;
@property (nonatomic) int useOffsetY;
@property (nonatomic, strong) UIColor *useShadowColor;

-(id)initWithShadowSpec:(CGRect)frame shadowColor:(UIColor*)shadowColor offsetX:(int)offsetX offsetY:(int)offsetY blur:(float)blur;

@end
