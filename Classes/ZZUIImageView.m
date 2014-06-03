//
//  ZZUIImageView.m
//  zziphone
//
//  Created by Phil Beisel on 8/14/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "Moment.h"
#import "ZZUIImageView.h"
#import "SDWebImageManager.h"
#import "albums.h"

//@class AlbumViewController;

@implementation ZZUIImageView

@synthesize albumid;
@synthesize photoid;
@synthesize photoIndex;                     
@synthesize type;
@synthesize target;
@synthesize tapLocation;

- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    MLOG(@"ZZUIImageView: touches Began");
    
    [super touchesBegan:touches withEvent:event];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ 
    MLOG(@"ZZUIImageView: touches Moved");
    
    [super touchesMoved:touches withEvent:event];
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    MLOG(@"ZZUIImageView: touches Ended");
    
    [super touchesEnded:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        if (touch.tapCount == 1) {
            // single tap, action
            MLOG(@"UIImageView: single tap");
            
            tapLocation = [touch locationInView:self];

            if (delegate && [delegate respondsToSelector:@selector(imageTap:)])
                [delegate performSelector:@selector(imageTap:) withObject:self];
            
            return;
        }
    }
    
}


- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    MLOG(@"ZZUIImageView: touches Cancelled");
    
    [super touchesCancelled:touches withEvent:event];
}


- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    // animate if:
    // 1. ZZUIImageView is in view hierarchy (has a superview) (those loaded for look ahead caching will not be animated)
    // 2. delegate wants animation
    
    //MLOG(@"webImageManager didFinishWithImage: %d (%llu)", self.photoIndex, self.photoid);
    
    BOOL animate = NO;
    
    if (self.superview) {
        if (delegate && [delegate respondsToSelector:@selector(shouldAnimateLoaded:)]) {
            NSNumber * shouldAnimate  = [delegate performSelector:@selector(shouldAnimateLoaded:) withObject:self];
            if ([shouldAnimate boolValue])
                animate = YES;
        } else {
            animate = NO;
        }
    }
    
    if (animate) {

        [UIView transitionWithView:self duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowUserInteraction
                        animations:^{         
                            self.image = image;
                        }
                        completion:NULL];
    } else {
        self.image = image;
    }
}


- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImageDownloaded:(UIImage *)image
{   
    // animate if:
    // 1. ZZUIImageView is in view hierarchy (has a superview) (those loaded for look ahead caching will not be animated)
    // 2. delegate wants animation
    
    //MLOG(@"webImageManager didFinishWithImageDownloaded: %d (%llu)", self.photoIndex, self.photoid);
    
    BOOL animate = NO;
    
    if (self.superview) {
        if (delegate && [delegate respondsToSelector:@selector(shouldAnimateDownloaded:)]) {
            NSNumber * shouldAnimate  = [delegate performSelector:@selector(shouldAnimateDownloaded:) withObject:self];
            if ([shouldAnimate boolValue])
                animate = YES;
        } else {
            animate = NO;
        }
    }
    
    if (animate) {

        [UIView transitionWithView:self duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowUserInteraction
                        animations:^{         
                            self.image = image;
                        }
                        completion:NULL];
    } else {

        self.image = image;
    }
    
    if (delegate && [delegate respondsToSelector:@selector(imageLoaded:)])
    {
        [delegate performSelector:@selector(imageLoaded:) withObject:self];
    }
}

@end
