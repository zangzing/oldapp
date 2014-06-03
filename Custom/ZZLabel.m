

#import "ZZLabel.h"


@implementation ZZUILabel

@synthesize useBlur;
@synthesize useOffsetX;
@synthesize useOffsetY;
@synthesize useSettings;
@synthesize useShadowColor;

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame])
    {
        self.clipsToBounds = NO;  
    }
    return self;
}

-(id)initWithShadowSpec:(CGRect)frame shadowColor:(UIColor*)shadowColor offsetX:(int)offsetX offsetY:(int)offsetY blur:(float)blur
{
    self.useSettings = YES;
    self.useBlur = blur;
    self.useOffsetX = offsetX;
    self.useOffsetY = offsetY;
    self.useShadowColor = [[UIColor alloc]initWithCGColor:shadowColor.CGColor];
    
    return [self initWithFrame:frame];
}


- (void)drawTextInRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    float colorValues[] = {0, 0, 0, .4};
    CGColorRef shadowColor = CGColorCreate(colorSpace, colorValues);
    
    if (self.useSettings)
        shadowColor = self.useShadowColor.CGColor;
    
    int x = 1;
    if (self.useSettings)
        x = self.useOffsetX;
    int y = -3;
    if (self.useSettings) 
        y = self.useOffsetY;
    
    float b = 4;
    if (self.useSettings)
        b = self.useBlur;
    
    CGSize shadowOffset = CGSizeMake(x, y);
    CGContextSetShadowWithColor (context, shadowOffset, b, shadowColor);
    [super drawTextInRect:rect];
    
    CGColorRelease(shadowColor);
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(context);
}

@end