//
//  ZZSystem.m
//  ZangZing
//
//  Created by Phil Beisel on 2/9/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zzglobal.h"
#import "ZZSystem.h"

@implementation ZZSystem

-(NSDictionary*)systemStats
{    
    ASIHTTPRequest *request = [self createGETRequest:[self createURL:ZZAPI_SYSTEM_STATUS_URL  ssl:NO]];    
    [request startSynchronous];
    
    int result = [self decodeRequestStatus:request message:@"systemStats" ];
    if (result == ZZAPI_SUCCESS ){
        NSDictionary *response = [self decodeRequestResponseAsDictionary:request message:@"systemStats"];
        if (response)
            return response;
    }
    MLOG(@"ZZUsers:systemStats error");
    return NULL;
}

@end
