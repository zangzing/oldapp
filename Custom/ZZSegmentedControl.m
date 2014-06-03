//
//  ZZSegmentedControl.m
//  ZZSegmentedControl
//

#import <QuartzCore/QuartzCore.h> 
#import "ZZSegmentedControl.h"

@implementation ZZSegmentedControl
@synthesize buttons;

- (id) initWithSegmentCount:(NSUInteger)segmentCount selectedSegment:(NSUInteger)selectedSegment segmentdef:(NSDictionary*)segmentdef tag:(NSInteger)objectTag delegate:(NSObject <ZZSegmentedControlDelegate>*)ZZSegmentedControlDelegate
{
    if (self = [super init])
    {
        _segmentdef = segmentdef;
        
        _buttonFontColor = [segmentdef objectForKey:@"button-color"];
        _buttonSelectedFontColor = [segmentdef objectForKey:@"button-highlight-color"];
        
        CGSize segmentsize = [[_segmentdef objectForKey:@"size"] CGSizeValue];
        UIImage* dividerImage = [UIImage imageNamed:[_segmentdef objectForKey:@"divider-image"]];
        
        // The tag allows callers withe multiple controls to distinguish between them
        self.tag = objectTag;
        
        // Set the delegate
        delegate = ZZSegmentedControlDelegate;
        
        // Adjust our width based on the number of segments & the width of each segment and the separator
        self.frame = CGRectMake(0, 0, (segmentsize.width * segmentCount) + (dividerImage.size.width * (segmentCount - 1)), segmentsize.height);
        
        // Initalize the array we use to store our buttons
        self.buttons = [[NSMutableArray alloc] initWithCapacity:segmentCount];
        
        // horizontalOffset tracks the proper x value as we add buttons as subviews
        CGFloat horizontalOffset = 0;
        
        _selectedSegment = selectedSegment;
        
        // Iterate through each segment
        for (NSUInteger i = 0 ; i < segmentCount ; i++)
        {
            // Ask the delegate to create a button
            UIButton* button = [self buttonFor:i];
            
            // Register for touch events
            [button addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchUpOutside];
            [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragOutside];
            [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragInside];
            
            // Add the button to our buttons array
            [buttons addObject:button];
            
            // Set the button's x offset
            button.frame = CGRectMake(horizontalOffset, 0.0, button.frame.size.width, button.frame.size.height);
            
            // Add the button as our subview
            [self addSubview:button];
            
            // Add the divider unless we are at the last segment
            if (i != segmentCount - 1)
            {
                UIImageView* divider = [[UIImageView alloc] initWithImage:dividerImage];
                divider.frame = CGRectMake(horizontalOffset + segmentsize.width, 0.0, dividerImage.size.width, dividerImage.size.height);
                [self addSubview:divider];
            }
            
            // Advance the horizontal offset
            horizontalOffset = horizontalOffset + segmentsize.width + dividerImage.size.width;
        }
    }
    
    return self;
}


-(UIImage*)image:(UIImage*)image withCap:(CapLocation)location capWidth:(NSUInteger)capWidth buttonWidth:(NSUInteger)buttonWidth
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(buttonWidth, image.size.height), NO, 0.0);
    
    if (location == CapLeft)
        // To draw the left cap and not the right, we start at 0, and increase the width of the image by the cap width to push the right cap out of view
        [image drawInRect:CGRectMake(0, 0, buttonWidth + capWidth, image.size.height)];
    else if (location == CapRight)
        // To draw the right cap and not the left, we start at negative the cap width and increase the width of the image by the cap width to push the left cap out of view
        [image drawInRect:CGRectMake(0.0-capWidth, 0, buttonWidth + capWidth, image.size.height)];
    else if (location == CapMiddle)
        // To draw neither cap, we start at negative the cap width and increase the width of the image by both cap widths to push out both caps out of view
        [image drawInRect:CGRectMake(0.0-capWidth, 0, buttonWidth + (capWidth * 2), image.size.height)];
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}


-(UIButton*)buttonFor:(NSUInteger)segmentIndex;
{
    NSArray* titles = [_segmentdef objectForKey:@"titles"];
    NSArray* images = [_segmentdef objectForKey:@"images"];
    
    CapLocation location;
    if (segmentIndex == 0)
        location = CapLeft;
    else if (segmentIndex == titles.count - 1)
        location = CapRight;
    else
        location = CapMiddle;
    
    UIImage* buttonImage = nil;
    UIImage* buttonPressedImage = nil;
    
    CGFloat capWidth = [[_segmentdef objectForKey:@"cap-width"] floatValue];
    CGSize buttonSize = [[_segmentdef objectForKey:@"size"] CGSizeValue];
    
    if (location == CapLeftAndRight)
    {
        buttonImage = [[UIImage imageNamed:[_segmentdef objectForKey:@"button-image"]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
        buttonPressedImage = [[UIImage imageNamed:[_segmentdef objectForKey:@"button-highlight-image"]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    }
    else
    {
        buttonImage = [self image:[[UIImage imageNamed:[_segmentdef objectForKey:@"button-image"]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0] withCap:location capWidth:capWidth buttonWidth:buttonSize.width];
        buttonPressedImage = [self image:[[UIImage imageNamed:[_segmentdef objectForKey:@"button-highlight-image"]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0] withCap:location capWidth:capWidth buttonWidth:buttonSize.width];
    }
    
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonSize.width, buttonSize.height);
    
    [button setTitleColor:_buttonFontColor forState: UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12.5];
    
    [button setTitle:[titles objectAtIndex:segmentIndex] forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;
    button.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (segmentIndex == _selectedSegment) {
        [button setTitleColor:_buttonSelectedFontColor forState: UIControlStateNormal];
        button.selected = YES;
    }
    
    if( images ){
        NSString *imageName = [images objectAtIndex:segmentIndex];
        if( imageName && imageName.length > 0){
            UIImage *iconImage = [UIImage imageNamed:imageName];
            //button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0,  0);
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0,  9);
            [button setImage:iconImage forState:UIControlStateNormal];
            
        }
    }
    
    return button;
}


-(void)dimAllButtonsExcept:(UIButton*)selectedButton
{
    int i;
    for (UIButton* button in buttons)
    {
        if (button == selectedButton)
        {
            button.selected = YES;
            button.highlighted = button.selected ? NO : YES;
            [button setTitleColor:_buttonSelectedFontColor forState: UIControlStateNormal];
        }
        else
        {
            button.selected = NO;
            button.highlighted = NO;
            [button setTitleColor:_buttonFontColor forState: UIControlStateNormal];
        }
        
        i++;
    }
}

-(void)selectSegment:(NSUInteger)segment
{
    if( segment < buttons.count ){
        UIButton *selectedButton = [buttons objectAtIndex:segment];
        [self dimAllButtonsExcept: selectedButton];
    }
}


-(void)touchDownAction:(UIButton*)button
{
    [self dimAllButtonsExcept:button];
    
    if ([delegate respondsToSelector:@selector(touchDownAtSegmentIndex:)])
        [delegate touchDownAtSegmentIndex:[buttons indexOfObject:button]];
}


-(void)touchUpInsideAction:(UIButton*)button
{
    [self dimAllButtonsExcept:button];
    
    if ([delegate respondsToSelector:@selector(touchUpInsideSegmentIndex:)])
        [delegate touchUpInsideSegmentIndex:[buttons indexOfObject:button]];
}


-(void)otherTouchesAction:(UIButton*)button
{
    [self dimAllButtonsExcept:button];
}



@end
