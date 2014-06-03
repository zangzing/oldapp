//
//  Stack.m
//  ZangZing
//
//  Created by Phil Beisel on 9/6/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "Stack.h"

@implementation Stack

// superclass overrides

- (id)init {
    if (self = [super init]) {
        contents = [[NSMutableArray alloc] init];
    }
    return self;
}


// Stack methods

- (void)push:(id)object {
    [contents addObject:object];
}

- (id)pop {
    NSUInteger count = [contents count];
    if (count > 0) {
        id returnObject = [contents objectAtIndex:count - 1];
        [contents removeLastObject];
        return returnObject;
    }
    else {
        return nil;
    }
}

@end