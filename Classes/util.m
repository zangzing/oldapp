//
//  util.m
//  ZangZing
//
//  Created by Phil Beisel on 10/16/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import "util.h"

@implementation ZZUtil


+(void)setOrientation:(UIDeviceOrientation)orientation 
{
    // see http://stackoverflow.com/questions/3213885/ipad-orientation-change-issue/3239351#3239351 
    
    //[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)orientation];      // invoke dynamically (to avoid obvious static link to undocumented API)
}

@end
