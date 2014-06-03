//
//  Stack.h
//  ZangZing
//
//  Created by Phil Beisel on 9/6/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject {
    NSMutableArray *contents;
}

- (void)push:(id)object;
- (id)pop;

@end
