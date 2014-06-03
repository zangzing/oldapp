//
//  ZZBaseViewController.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/27/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZLabel.h"

#ifndef ZZBASE_VIEW_DEFS
#define ZZBASE_VIEW_DEFS

#define VIEW_BACKGROUND_IMAGE_SCRIM @"upload-photos-scrim.png"
#define LEFT_SIDE  0
#define RIGHT_SIDE 1

#endif

@interface ZZBaseViewController : UIViewController{
    UILabel *_titlelabel;
}


- (void)useCustomBackButton;
- (void)useCustomBackButton:(NSString *)text;
- (void)useCustomBackButton:(NSString *)text target:(id)target action:(SEL)action;

- (void)useGrayCancelRightButton:(id)target action:(SEL)action;
- (void)useGrayEditRightButton:(id)target action:(SEL)action;
- (void)useGrayDoneRightButton:(id)target action:(SEL)action;

- (void)useGraySquareButton:(int)side text:(NSString *)text target:(id)target action:(SEL)action;
- (void)useGreenRightButton:(NSString *)text target:(id)target action:(SEL)action;
- (void)setBackgroundImage:(UIImage *)image;

-(void)clearRightButton;

-(void)useDefaultNavigationBarStyle;

-(IBAction)defaultBackAction:(id)sender;

-(void) showUnderConstructionAlert;

@end
