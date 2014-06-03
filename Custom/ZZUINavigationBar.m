//
//  ZZUINavigationBar.m
//  ZangZing
//
//  Created by Phil Beisel on 10/21/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import "zzglobal.h"
#import "ZZUINavigationBar.h"
#import "ZZLabel.h"

#define MAX_BACK_BUTTON_WIDTH 160.0
#define BACK_BUTTON_INSET 6.0
#define MIN_SQUARE_BUTTON_SIZE 60.0


@implementation ZZUINavigationBar
@synthesize navigationBarBackgroundImage, navigationController;

// If we have a custom background image, then draw it, othwerwise call super and draw the standard nav bar
- (void)drawRect:(CGRect)rect
{
    if (navigationBarBackgroundImage)
        [navigationBarBackgroundImage.image drawInRect:rect];
    else
        [super drawRect:rect];
}

// Save the background image and call setNeedsDisplay to force a redraw
-(void) setBackgroundWith:(UIImage*)backgroundImage
{
    self.navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
    navigationBarBackgroundImage.image = backgroundImage;
    [self setNeedsDisplay];
}

// clear the background image and call setNeedsDisplay to force a redraw
-(void) clearBackground
{
    self.navigationBarBackgroundImage = nil;
    [self setNeedsDisplay];
}

// With a custom back button, we have to provide the action. We simply pop the view controller
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Given the prpoer images and cap width, create a variable width back button
-(UIButton*) backButtonWith:(UIImage*)backButtonImage highlight:(UIImage*)backButtonHighlightImage leftCapWidth:(CGFloat)capWidth
{
    // store the cap width for use later when we set the text
    backButtonCapWidth = capWidth;
    
    // Create stretchable images for the normal and highlighted states
    UIImage* buttonImage = [backButtonImage stretchableImageWithLeftCapWidth:backButtonCapWidth topCapHeight:0.0];
    UIImage* buttonHighlightImage = [backButtonHighlightImage stretchableImageWithLeftCapWidth:backButtonCapWidth topCapHeight:0.0];
    
    // Create a custom button
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Set the title to use the same font and shadow as the standard back button
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    button.titleLabel.textColor = [UIColor blackColor];
    button.titleLabel.highlightedTextColor =[UIColor whiteColor]; 
    
    //button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    //button.titleLabel.shadowColor = [UIColor darkGrayColor];
      
    // Set the break mode to truncate at the end like the standard back button
    button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Inset the title on the left and right
    button.titleLabel.textAlignment = UITextAlignmentCenter;    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, BACK_BUTTON_INSET, 0,  0);
    
    // Make the button as high as the passed in image
    button.frame = CGRectMake(0, 0, 0, buttonImage.size.height);
    
    // Just like the standard back button, use the title of the previous item as the default back text
    [self setText:self.topItem.title onBackButton:button];
    
    // Set the stretchable images as the background for the button
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonHighlightImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonHighlightImage forState:UIControlStateSelected];
    
    // Add an action for going back
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

// Given the prpoer images and cap width, create a variable width right button
//-(UIButton*) rightButtonWith:(UIImage*)bImage highlight:(UIImage*)bHighlightImage text:(NSString *)text
-(UIButton*) greenSquareButtonWith:(NSString *)text;
{
        CGFloat capWidth = 6.0;
        CGFloat inset = 5.0;
        UIImage* buttonImage = [[UIImage imageNamed:@"green-btn.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];        
        button.titleLabel.textColor = [UIColor whiteColor];
        button.titleLabel.highlightedTextColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:12];    
        button.titleLabel.shadowColor = RGBA(0,0,0,0.3);
        button.titleLabel.shadowOffset = CGSizeMake(0, -1);
        button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;          
        button.titleEdgeInsets = UIEdgeInsetsMake(0, inset, 0, inset);        
        button.frame = CGRectMake(0, 0, 0, buttonImage.size.height);
    
        CGSize textSize = [text sizeWithFont:button.titleLabel.font];
      
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (textSize.width + (inset *2) + (capWidth * 1.5)) , button.frame.size.height);
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setTitle:text forState:UIControlStateNormal];
        return button;

}

-(UIButton*) graySquareButtonWith:(NSString *)text;
{
    CGFloat capWidth = 7.0;
    CGFloat inset = 5.0;
    UIImage* buttonImage   = [[UIImage imageNamed:@"segment.png"]          stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    UIImage* buttonImageHl = [[UIImage imageNamed:@"segment-selected.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];        
    [button setTitleColor:       [UIColor blackColor] forState: UIControlStateNormal];
    [button setTitleShadowColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [button setTitleColor:       [UIColor whiteColor] forState: UIControlStateHighlighted];
    [button setTitleShadowColor: RGBA(0,0,0,0.3)      forState: UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];    
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);
    button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;          
    button.titleEdgeInsets = UIEdgeInsetsMake(0, inset, 0, inset);        
    button.frame = CGRectMake(0, 0, 0, buttonImage.size.height);
    
    CGSize textSize = [text sizeWithFont:button.titleLabel.font];
    float buttonWidth = MAX( MIN_SQUARE_BUTTON_SIZE, (textSize.width + (inset *2) + (capWidth * 1.5)));
    
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, buttonWidth , button.frame.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImageHl forState:UIControlStateHighlighted];

    [button setTitle:text forState:UIControlStateNormal];
    return button;
    
}



// Set the text on the custom back button
-(void) setText:(NSString*)text onBackButton:(UIButton*)backButton
{
    // Measure the width of the text
    CGSize textSize = [text sizeWithFont:backButton.titleLabel.font];
    // Change the button's frame. The width is either the width of the new text or the max width
    backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, (textSize.width + (backButtonCapWidth ) + (BACK_BUTTON_INSET)) > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : (textSize.width + (backButtonCapWidth ) + (BACK_BUTTON_INSET)), backButton.frame.size.height);
    
    // Set the text on the button
    [backButton setTitle:text forState:UIControlStateNormal];
}

@end
