//
//  photouploader.m
//  ZangZing
//
//  Created by Phil Beisel on 11/8/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "UIImage+Resize.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "BrowsePhoto.h"
#import "zzglobal.h"
#import "albums.h"
#import "ZZAPI.h"
#import "photouploader.h"

PhotoUploader *gPhotoUploader = nil;

@implementation PhotoUploader

- (id)init
{
    self = [super init];
    if (self) {
        
        _lastphoto = nil; 
        [self load];
        
        _uploading = 0;
        _creatingphotos = NO;
        
        _totalreadyupload = [self readyToUploadCount];
        _totalreadyuploadbytes = [self readyToUploadBytes];
        _totalbytessent = 0;
        
        _abortBackgroundTasks = NO;
        
        _log = [[NSMutableArray alloc]init];
        
        [self startTimer];
    }
    
    return self;
}


-(void)startTimer
{
    if (_timer == nil) {
        MLOG(@"photouploader: startTimer");
        _timer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(uploadTimer:) userInfo: nil repeats: YES];
    }
}


-(void)stopTimer
{
    if (_timer) {
        MLOG(@"photouploader: stopTimer");
        [_timer invalidate];
        _timer = nil;
    }
}


-(void)addPhoto:(UIImage*)photo photoData:(NSData*)photoData taken:(time_t)taken xdata:(NSDictionary*)xdata; 
{    
    NSNumber *tn = [NSNumber numberWithLong:taken];
    
    NSMutableDictionary* photoSpec = [[NSMutableDictionary alloc]initWithCapacity:3];
    [photoSpec setObject:photo forKey:@"photo"];
    [photoSpec setObject:photoData forKey:@"photoData"];
    [photoSpec setObject:tn forKey:@"taken"];
    
    if (xdata) 
        [photoSpec setObject:xdata forKey:@"xdata"];
    
    NSString *photokey = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    photokey = [photokey stringByReplacingOccurrencesOfString:@"." withString:@""];
    [photoSpec setObject:photokey forKey:@"key"];
    
    MLOG(@"addPhoto: %@", photokey);
    
    @synchronized(_photoSet) {
        _photoSetCount++;
        
        [_photoSet addObject:photokey];
        _photoSetDirty = YES;
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
        [data setObject:tn forKey:@"taken"];
        [_photoSetData setObject:data forKey:photokey];

        _photoSetDataDirty = YES;
    }
    
    [self performSelectorInBackground:@selector(addPhotoDeferred:) withObject:photoSpec];
}


-(void)addPhotoDeferred:(NSDictionary*)photoSpec
{
    @autoreleasepool {
        
        @try {       
            
            @synchronized(self) {           // one at a time
                
                NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
                
                NSString *photokey = [photoSpec objectForKey:@"key"];
                UIImage *photo = [photoSpec objectForKey:@"photo"];
                NSObject *photoData = [photoSpec objectForKey:@"photoData"];
                NSDictionary *xdata = [photoSpec objectForKey:@"xdata"];
                
                MLOG(@"addPhotoDeferred: start %@", photokey);

                NSTimeInterval start_c = [[NSDate date] timeIntervalSince1970];
                if (photoData == [NSNull null]) {
                    MLOG(@"build photo data from image");
                    photoData = UIImageJPEGRepresentation(photo, 1.0);
                }
                NSTimeInterval end_c = [[NSDate date] timeIntervalSince1970];
                                
                NSTimeInterval start_w = [[NSDate date] timeIntervalSince1970];
                int fileSize = [gZZ cacheUploadQueueImage:photokey imageData:(NSData*)photoData];
                NSTimeInterval end_w = [[NSDate date] timeIntervalSince1970];
                
                // make/store thumbnail
                int thumbsize = kThumbSize;
                if ([gZZ isHiResScreen])
                    thumbsize = kThumbSize_Retina;
                
                NSTimeInterval start_t = [[NSDate date] timeIntervalSince1970];
                UIImage *thumbimage = [photo thumbnailImage:thumbsize transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationMedium];
                NSData *thumbdata = UIImageJPEGRepresentation(thumbimage, 1.0);  
                NSString *thumbkey = [NSString stringWithFormat:@"%@_t", photokey];
                [gZZ cacheUploadQueueImage:thumbkey imageData:(NSData*)thumbdata];
                NSTimeInterval end_t = [[NSDate date] timeIntervalSince1970];

                @synchronized(_photoSet) {
                    _lastphoto = photo;
                    
                    // might fail to find data if removePhoto or clearPhotos (more likely) slips in
                    NSMutableDictionary *data = [_photoSetData objectForKey:photokey];
                    if (data) {
                        [data setObject:[NSNumber numberWithUnsignedLong:fileSize] forKey:@"size"];
                        if (xdata)
                            [data setObject:xdata forKey:@"xdata"];
                        
                        NSLog(@"photo data size: %d; file size: %d", [(NSData*)photoData length], fileSize);
                        
                        _photoSetDataDirty = YES;
                    }
                }
                
                NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
                MLOG(@"addPhotoDeferred: end: %.2fs; convert: %.2fs; write: %.2fs; thumb: %.2fs", end-start, end_c-start_c, end_w-start_w, end_t-start_t);
                
                [self save];
            }
            
            [ZZGlobal trackEvent:@"photouploader.add" xdata:NULL];
        }
        @catch (NSException *exception) {
            [ZZGlobal trackException:@"addPhotoDeferred" exception:exception];
        }
    }
}


-(void)removePhoto:(NSString *)photo
{
    @try {
        @synchronized(_photoSet) {
            
            [gZZ deleteUploadQueueImage:photo];
            NSString *thumbkey = [NSString stringWithFormat:@"%@_t", photo];
            [gZZ deleteUploadQueueImage:thumbkey];
            
            [_photoSet removeObject:photo];
            _photoSetDirty = YES;
            
            [_photoSetData removeObjectForKey:photo];
            _photoSetDataDirty = YES;
            
            _photoSetCount--;
        }
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"removePhoto" exception:exception];
    }
    
    [self save];
    
    [ZZGlobal trackEvent:@"photouploader.remove" xdata:NULL];
}


-(NSUInteger)photoCount
{
    @synchronized(_photoSet) {
        return _photoSetCount;
    }
}


-(void)clearPhotos
{
    @try {
        _lastphoto = nil;
        
        @synchronized(_photoSet) {
            for (NSString* photoKey in _photoSet) {
                [gZZ deleteUploadQueueImage:photoKey];
                NSString *thumbkey = [NSString stringWithFormat:@"%@_t", photoKey];
                [gZZ deleteUploadQueueImage:thumbkey];
            }
            
            [_photoSet removeAllObjects];
            _photoSetDirty = YES;
            
            [_photoSetData removeAllObjects];
            _photoSetDataDirty = YES;
            
            _photoSetCount = 0;
        }
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"clearPhotos" exception:exception];
    }
    
    [self save];
    
    [ZZGlobal trackEvent:@"photouploader.clear" xdata:NULL];
}


-(NSArray*)getPhotos
{   
    NSMutableArray* photos = [[NSMutableArray alloc]initWithCapacity:[self photoCount]];
    
    @synchronized(_photoSet) {
        for (NSString* photo in _photoSet) {
            NSString* fpath = [gZZ uploadQueuePathForKey:photo];
            //MLOG(@"photo: %@", fpath);
            
            [photos addObject:[BrowsePhoto photoWithFilePath:fpath]];
        }
    }
    
    return photos;
}


-(NSArray*)getPhotosKeys
{
    @synchronized(_photoSet) {
        NSArray *photoKeys = [[NSArray alloc]initWithArray:_photoSet];
        return photoKeys;
    }
}


-(void)setCaption:(NSString*)photo caption:(NSString*)caption
{
    @synchronized(_photoSet) {
        NSMutableDictionary *data = [_photoSetData objectForKey:photo];
        if (!data) {
            data = [[NSMutableDictionary alloc]init];
            [_photoSetData setObject:data forKey:photo];
            _photoSetDataDirty = YES;
        }
        [data setObject:caption forKey:@"caption"];
    }
    
    [self save];
}


-(NSString*)getCaption:(NSString*)photo
{
    NSMutableDictionary *data = [_photoSetData objectForKey:photo];
    if (data) {
        NSString* caption = [data objectForKey:@"caption"];
        return caption;
    }
    
    return NULL;
}


-(NSUInteger) queueCount
{
    @synchronized(_photoQueue) {
        return [_photoQueue count];
    }
}


-(NSUInteger)readyToUploadCount
{
    int readyCount = 0;
    
    @synchronized(_photoQueue) {
        for (NSString* photokey in _photoQueue) {
            NSMutableDictionary *data = [_photoQueueData objectForKey:photokey];
            if (data && [(NSString*)[data objectForKey:@"state"] isEqualToString:@"ready"])
                ++readyCount;
        }
    }
    
    return readyCount;
}


-(unsigned long long)readyToUploadBytes
{
    unsigned long long readyBytes = 0;
    
    @synchronized(_photoQueue) {
        for (NSString* photokey in _photoQueue) {
            NSMutableDictionary *data = [_photoQueueData objectForKey:photokey];
            if (data) {
                if ([(NSString*)[data objectForKey:@"state"] isEqualToString:@"ready"]) {
                    NSNumber *size = [data objectForKey:@"size"];
                    readyBytes += [size unsignedLongValue];
                }
            }
        }
    }
    
    return readyBytes;
}


-(BOOL)uploading
{
    @synchronized(self) {
        return (_uploading > 0);
    }
}


-(NSUInteger)createPhotosCount
{
    @synchronized(_createPhotos) {
        return [_createPhotos count];
    }
}


-(NSUInteger)totalReadyUpload
{
    return _totalreadyupload;
}


-(unsigned long long)bytesToUpload
{
    @synchronized(self) {
        unsigned long long bytes = _totalreadyuploadbytes;
        
        if (_bytesToUploadRequest > 0 && !_recalcedActualBytes) {
            
            _recalcedActualBytes = YES;
            
            // remove estimated size
            bytes -= _uploadingPhotoSize;
            
            // add real size
            bytes += _bytesToUploadRequest;  
            
            //NSLog(@"%lu vs %llu", _uploadingPhotoSize, _bytesToUploadRequest);
        }
        
        return bytes;
    }
}


-(unsigned long long)bytesUploaded
{
    @synchronized(self) {
        return _totalbytessent;
    }
}


-(void)queuePhotos:(ZZUserID)userid albumid:(ZZAlbumID)albumid shareData:(NSDictionary*)shareData;
{
    // queue current photo set for upload
    
    int count = 0;
    
    @try {
            
        @synchronized(_photoQueue) {
            
            // reset _totalreadyupload if _photoQueue at zero
            if ([self readyToUploadCount] == 0) {
                _totalreadyupload = 0;
                _totalreadyuploadbytes = 0;
                _totalbytessent = 0;
            }
            
            @synchronized(_photoSet) {
                // queue on _photoQueue; setup create_photos
                for (NSString* photokey in _photoSet) {
                    
                    @try {
                
                        NSDictionary* data = [_photoSetData objectForKey:photokey];

                        NSNumber *size = [data objectForKey:@"size"]; 
                        NSNumber *taken = [data objectForKey:@"taken"];
                        NSDictionary* photoxdata = [data objectForKey:@"xdata"];
                        NSString *caption = [data objectForKey:@"caption"];
                        if (!caption)
                            caption = @"";
                        
                        
                        [_photoQueue addObject:photokey];
                        
                        NSMutableDictionary *pdata = [[NSMutableDictionary alloc]init];
                        [_photoQueueData setObject:pdata forKey:photokey];
                        
                        [pdata setObject:[NSNumber numberWithUnsignedLongLong:albumid] forKey:@"album_id"];
                        [pdata setObject:[NSNumber numberWithUnsignedLongLong:userid] forKey:@"user_id"];
                        [pdata setObject:taken forKey:@"taken"];
                        [pdata setObject:size forKey:@"size"];
                        [pdata setObject:@"initialized" forKey:@"state"];
                        if (photoxdata) {
                            [pdata setObject:photoxdata forKey:@"xdata"];
                        }
                        
                        NSMutableDictionary *create_photo = [[NSMutableDictionary alloc]initWithCapacity:9];
                        
                        // for internal use
                        [create_photo setObject:[NSNumber numberWithUnsignedLongLong:albumid] forKey:@"album_id"];
                        [create_photo setObject:[NSNumber numberWithUnsignedLongLong:userid] forKey:@"user_id"];

                        // for create_photos call
                        [create_photo setObject:photokey forKey:@"source_guid"];
                        [create_photo setObject:caption forKey:@"caption"];
                        [create_photo setObject:size forKey:@"size"];
                        [create_photo setObject:taken forKey:@"capture_date"];
                        [create_photo setObject:@"iphone" forKey:@"source"];
                        [create_photo setObject:[NSNull null] forKey:@"rotate_to"];
                        [create_photo setObject:[NSNull null] forKey:@"crop_to"];
                        
                        if (shareData)
                            [create_photo setObject:shareData forKey:@"share_data"];
                        
                        @synchronized(_createPhotos) {
                            [_createPhotos addObject:create_photo];
                            _createPhotosDirty = YES;
                        }
                        
                        count++;
                    }
                    @catch (NSException *exception) {
                        [ZZGlobal trackException:@"queuePhotos.1" exception:exception];
                    }
                }
            }
        }
        
        NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
        [xdata setObject:[NSNumber numberWithInt:count] forKey:@"count"];
        [ZZGlobal trackEvent:@"photouploader.queue" xdata:xdata];

        MLOG(@"queuePhotos: queuing %d photos for upload on album: %llu", count, albumid);
              
        // reset photo set
        @synchronized(_photoSet) {
            [_photoSet removeAllObjects];
            _photoSetDirty = YES;
            
            [_photoSetData removeAllObjects];
            _photoSetDataDirty = YES;
            
            _photoSetCount = 0;
        }
        
        _photoQueueDirty = YES;
        _photoQueueDataDirty = YES;
            
        [self save];
        
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"queuePhotos" exception:exception];
    }
}


-(void)finish_upload:(NSString*)photokey result:(int)result
{
    MLOG(@"end upload: %@, result: %d; remaining queue size: %d", photokey, result, [_photoQueue count]);
    
    // result = 6, file not found on disk
    
    if (result == 0 || result == 6 || (result >= 400 && result <= 499)) {
        // dequeue
        
        @synchronized(_photoQueue) {
            [_photoQueueData removeObjectForKey:photokey];
            _photoQueueDataDirty = YES;
            
            [_photoQueue removeObject:photokey];
            _photoQueueDirty = YES;
        }
    }
}


-(void)beginBackgroundTask
{
    MLOG(@"beginBackgroundTask");
    
    if (_backgroundTask > 0) {
        // already requested background, just return
        return;
    }
    
    BOOL enableBackground = NO;
    if ([ZZGlobal isMultitaskingSupported]) {
        enableBackground = YES;
    }
    
    if (enableBackground) {
        _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            
            MLOG(@"background expired");
            _abortBackgroundTasks = YES;
            
        }];
    }
    
    MLOG(@"beginBackgroundTask: %d", _backgroundTask);

}


-(void)endBackgroundTask
{    
    if (_backgroundTask > 0) {

        MLOG(@"endBackgroundTask");

        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
        _backgroundTask = 0;
    }
}


-(void)cancelUploader
{
    if (_request) {
        [_request cancel];
    }
}

-(void)uploader
{
    // called when uploads are pending
    // this is a background task
    // processes n uploads sequentially
    
    @synchronized(self) {
        _uploading = 1;
    }
        
    @autoreleasepool {
    
        while (1) {
            
            if (_abortBackgroundTasks)
                break;
 
            if ([self suspended]) {
                break;
            }
            
            [self beginBackgroundTask];

            if (_backgroundTask != 0) {
                NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication]backgroundTimeRemaining];
                if (backgroundTimeRemaining < 1000000)      // backgroundTimeRemaining should range from 600 -> 0 when in the background (otherwise the number is huge)
                    MLOG(@"background time remaining: %f", [[UIApplication sharedApplication]backgroundTimeRemaining]);
            }
            
            NSMutableDictionary *data = nil;
            NSString* photokey = nil;
            
            @synchronized(_photoQueue) {
                
                if (_photoQueue.count > 0) {
                    MLOG(@"photos remaining on upload queue: %d", _photoQueue.count);
                    
                    for (NSString *pkey in _photoQueue) {
                        data = [_photoQueueData objectForKey:pkey];
                        if (data) {
                            NSString *state = [data objectForKey:@"state"];
                            if (state && [state isEqualToString:@"ready"]) {
                                // begin upload on this file
                                photokey = pkey;
                                MLOG(@"dequeue upload: %@", photokey);
                                
                                break;
                            } 
                        } else {
                            MLOG(@"no matching photo queue data object for photo: %@", photokey);
                        }
                    }
                }
            }
            
            if (photokey) {
                [self upload:photokey];
            } else {
                // no more work
                break;
            }
        }
        
    }
    
    @synchronized(self) {
        _uploading = 0;
    }
}


-(int)upload:(NSString*)photokey
{
    int result = -1;
    NSString* err = NULL;

    @try {
        
        MLOG(@"start upload: %@", photokey);
        
        _uploadingPhoto = photokey;
        
        NSTimeInterval start_time = [[NSDate date] timeIntervalSince1970];
        NSNumber *bytes = [gZZ uploadImageSize:photokey];
                    
        NSMutableDictionary *data = nil;
        ZZPhotoID photoid = 0;
        NSNumber *taken = nil;
        NSDictionary *photoxdata = nil;
        
        @synchronized(_photoQueue) {
             
            data = [_photoQueueData objectForKey:photokey];
            if (!data)
                return result;
            
            photoxdata = [[NSDictionary alloc]initWithDictionary:[data objectForKey:@"xdata"] copyItems:YES];
            taken = [data objectForKey:@"taken"];
            
            NSNumber *n = [data objectForKey:@"photo_id"];
            photoid = [n unsignedLongLongValue];
            
            NSNumber *s = [data objectForKey:@"size"];
            _uploadingPhotoSize = [s unsignedLongValue];
        }
        
        int newSize = [self writeExifInfo:photokey taken:[taken longValue] xdata:photoxdata];
        if (newSize > 0)
            _uploadingPhotoSize = newSize;

        int retry = 0;
        NSNumber *retryn = [data objectForKey:@"retry"];
        if (retryn) {
            retry = [retryn intValue];
        }
        
        [self logEvent_upload_begin:photokey retry:retry];

        NSString* url;
        if (retry == 0) 
            url = [[NSString alloc]initWithFormat:@"%@/zz_api/photos/%llu/upload", [gZZ serviceURL], photoid];
        else
            url = [[NSString alloc]initWithFormat:@"%@/zz_api/photos/%llu/upload?r=", [gZZ serviceURL], photoid, retry];
            
        _request = [ASIFormDataRequest requestWithURL:[[NSURL alloc] initWithString:url]];
        _request.timeOutSeconds = 10 * 60;
        _request.shouldContinueWhenAppEntersBackground = YES;
        _request.uploadProgressDelegate = self;
        [_request addRequestHeader:@"Accept" value:@"application/json"];
        [_request addRequestHeader:@"X-ZangZing-API" value:@"iphone"];
        
        NSString *pfile = [gZZ uploadQueuePathForKey:photokey];
        NSString *pkey = [NSString stringWithFormat:@"photo[%llu]", photoid];
        
        [_request setFile:pfile withFileName:@"photo.jpeg" andContentType:@"image/jpeg" forKey:pkey];
        
        _bytesToUploadRequest = 0;      // reset
        _recalcedActualBytes = NO;
        
        NSLog(@"upload: begin");
        [_request startSynchronous];
        NSLog(@"upload: end");
        
        NSError *error = [_request error];
        if (!error) {
            NSData *response = [_request responseData];
            NSObject *rdata = [ZZGlobal getObjfromJSON:response];
            
            result = [ZZGlobal responseError:_request data:rdata];
            if (result == 0) {
                //NSDictionary *resp = (NSDictionary*)data;
                // id and state
                
                err = [[NSString alloc] initWithBytes:[response bytes] length:[response length] encoding:NSUTF8StringEncoding];
                MLOG(@"upload error: %@", err);
            }
        } else {
            result = error.code;
        }
        
        [self finish_upload:photokey result:result];

        NSTimeInterval end_time = [[NSDate date] timeIntervalSince1970];
        [self logEvent_upload_end:result error:err key:photokey start:start_time end:end_time bytes:bytes network:[gZZ networkStatus] retry:retry];
        
        // retry uploads for failed but retryable results (consider all 400 errors as fatal)
        if (!(result == 0 || (result >= 400 && result <= 499))) {
            retry++;
            retryn = [NSNumber numberWithInt:retry];
            [data setObject:retryn forKey:@"retry"];
            _photoQueueDataDirty = YES;
        }
        
        _request = nil;
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"upload" exception:exception];
    }
    
    // save photoQueue changes
    [self save];
    
    if (result != 0) {
        MLOG(@"upload error: %d", result);
    }
    
    return result;
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    @synchronized(self) {
        
        if (_bytesToUploadRequest == 0) {
            _bytesToUploadRequest = _request.postLength;
            _lastSent = 0;
        }
        
        _bytesToUploadRequestLeft = _bytesToUploadRequest - _request.totalBytesSent;
        
        unsigned long long sent = _request.totalBytesSent - _lastSent;
        _totalbytessent += sent;           
        _lastSent = _request.totalBytesSent;

        //NSLog(@"sent: %llu, total: %llu", sent, _request.totalBytesSent);
        //NSLog(@"_bytesToUploadRequest: %llu, _bytesToUploadRequestLeft: %llu", _bytesToUploadRequest, _bytesToUploadRequestLeft);
    }
}


-(void)create_photos
{
    _creatingphotos = YES;
        
    // pull together all create_photo specs by albumid
    // then execute create_photos on each
    
    @try {
        NSMutableDictionary *album_sets = [[NSMutableDictionary alloc]init];
        
        @synchronized(_createPhotos) {
            for (NSDictionary *create_photo in _createPhotos) {
                NSNumber *album_id = [create_photo objectForKey:@"album_id"];
                
                NSMutableArray *create_photo_set = [album_sets objectForKey:album_id];
                if (!create_photo_set) {
                    create_photo_set = [[NSMutableArray alloc]init];
                    [album_sets setObject:create_photo_set forKey:album_id];
                }
                
                [create_photo_set addObject:create_photo];
            }
        }
        
        for (NSNumber *set_album_id in album_sets) {
            
            ZZPhotoID photoID = 0;

            NSArray *create_photo_set = [album_sets objectForKey:set_album_id];
            
            // get album_id and user_id from first object in set
            NSDictionary *firstPhoto = [create_photo_set objectAtIndex:0];
            
            NSNumber *album_id = [firstPhoto objectForKey:@"album_id"];
            ZZAlbumID albumid = [album_id unsignedLongLongValue];
            NSNumber *user_id = [firstPhoto objectForKey:@"user_id"];
            ZZUserID userid = [user_id unsignedLongLongValue];
            
            NSArray *photos_created = nil;
            int result = [self create_photos:albumid photos:create_photo_set photos_created:&photos_created];
            
            if (result == 0) {
                
                // send share message if set
                @try {
                    NSDictionary *shareData = [firstPhoto objectForKey:@"share_data"];
                    if (shareData) {
                        // call ZZShareList:sendShare
                        
                        if (photos_created && photos_created.count == 1) {
                            NSNumber *p = [photos_created objectAtIndex:0];
                            photoID = [p unsignedLongLongValue];
                        }
                        
                        NSString *message = [shareData objectForKey:@"message"];
                        
                        NSNumber *facebook = [shareData objectForKey:@"facebook"];
                        BOOL sendToFacebook = NO;
                        if (facebook) {
                            sendToFacebook = [facebook boolValue];
                        }
                        
                        NSNumber *twitter = [shareData objectForKey:@"twitter"];
                        BOOL sendToTwitter = NO;
                        if (twitter) {
                            sendToTwitter = [twitter boolValue];
                        }
                        
                        NSArray *viewers = [shareData objectForKey:@"viewers"];
                        NSArray *contributors = [shareData objectForKey:@"contributors"];
                        
                        NSMutableArray *recipients = [[NSMutableArray alloc]init];
                        if (viewers && viewers.count > 0) {
                            [recipients addObjectsFromArray:viewers];
                        }
                        if (contributors && contributors.count > 0) {
                            [recipients addObjectsFromArray:contributors];
                        }
                        
                        // call sendShare if message or sendToFacebook or sendToTwitter set
                        if ((message && message.length > 0 && recipients.count > 0) || sendToFacebook || sendToTwitter) {
                            [ZZShareList sendShare:albumid photoID:photoID shareType:@"viewer" message:message group_ids:contributors sendToFacebook:sendToFacebook sendToTwitter:sendToTwitter];                            
                        }
                    }
                }
                @catch (NSException *exception) {
                    [ZZGlobal trackException:@"create_photos send share" exception:exception];
                }
            }
            
            // for success or fatal error, remove create_photo spec from queue
            if (result == 0 || (result >= 400 && result <= 499)) {
                _createPhotosDirty = YES;
                
                // success (or fatal error); remove this create_photo spec from _createPhotos 
                for (NSDictionary *create_photo in create_photo_set) {
                    @synchronized(_createPhotos) {
                        [_createPhotos removeObject:create_photo];
                    }
                                        
                    if (result >= 400 && result <= 499) {
                        // fatal error, remove from photo queue
                        
                        @synchronized(_photoQueue) {
                            
                            NSString *photokey = [create_photo objectForKey:@"source_guid"];
                            [_photoQueueData removeObjectForKey:photokey];
                            [_photoQueue removeObject:photokey];
                            _photoQueueDirty = YES;
                            _photoQueueDataDirty = YES;
                        }
                    }
                }
            }
            
            // refresh album
            [gAlbums refreshalbumsets:[ZZSession currentUser].user_id];
            [gAlbums getalbumrefresh: albumid userid:userid];
        }
            
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"create_photos" exception:exception];
    }
    
    [self save];
    
    _creatingphotos = NO;
}


-(int)create_photos:(ZZAlbumID)albumid photos:(NSArray*)photos photos_created:(NSArray**)photos_created;
{
    int result = -1;
    NSString *err = NULL;
    
    NSString* url = [[NSString alloc]initWithFormat:@"%@/zz_api/albums/%llu/photos/create_photos", [gZZ serviceURL], albumid];

    MLOG(@"create_photos: request %@", url);
        
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    request.timeOutSeconds = 60;
    request.shouldContinueWhenAppEntersBackground = YES;
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"X-ZangZing-API" value:@"iphone"];
    [request setRequestMethod:@"POST"];
    if ([ZZSession currentSession]) {
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:[gZZ authCookie]]];
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setObject:[gZZ UID] forKey:@"agent_id"];
    [body setObject:photos forKey:@"photos"];
    
    NSData *bodyJSON = [[CJSONSerializer serializer] serializeObject:body error:nil];
    [request appendPostData:bodyJSON];
    
    // ***
    //NSString *bodyJSONstr = [[NSString alloc] initWithBytes:[bodyJSON bytes] length:[bodyJSON length] encoding:NSUTF8StringEncoding];
    //MLOG(bodyJSONstr);
    
    NSLog(@"create_photos: begin");
    [request startSynchronous];
    NSLog(@"create_photos: end");
    
    NSError *error = [request error];
    if (!error) {
        NSData *response = [request responseData];
        NSObject *data = [ZZGlobal getObjfromJSON:response];
        
        result = [ZZGlobal responseError:request data:data];
        if (result == 0) {
                
            // create_photos response is an array; 1 element for each photo
            // each are a dictionary with id, user_id, album_id, and source_guid
            
            err = [[NSString alloc] initWithBytes:[response bytes] length:[response length] encoding:NSUTF8StringEncoding];

            NSArray *resp = (NSArray*)data;
            
            NSMutableArray *created = [[NSMutableArray alloc]init];
            
            @synchronized(_photoQueue) {
                
                for (NSDictionary* create_photo_resp in resp) {
                    NSString *photokey = [create_photo_resp objectForKey:@"source_guid"];       // source_guid is the photokey
                    NSMutableDictionary *pdata = [_photoQueueData objectForKey:photokey];
                    [pdata setObject:@"ready" forKey:@"state"];                                 // set ready for upload status
                    [pdata setObject:[create_photo_resp objectForKey:@"id"] forKey:@"photo_id"];
                    
                    [created addObject:[create_photo_resp objectForKey:@"id"]];
                    
                    _photoQueueDataDirty = YES;
                    
                    MLOG(@"photo %@ now 'ready' for upload", photokey);
                    
                    NSNumber *size = [pdata objectForKey:@"size"];
                    @synchronized(self) {
                        _totalreadyuploadbytes += [size unsignedLongValue];
                        _totalreadyupload++;
                    }
                }   
            }
            
            *photos_created = created;
        }
    } else {
        // not fatal (e.g., code = 2, timed out)
        result = error.code;
    }
    
    [self logEvent_create_photos:result error:err count:[photos count]];
    
    MLOG(@"create_photos: result %d", result);

    return result;
}



-(void)pending_uploads
{
    NSString* url = [[NSString alloc]initWithFormat:@"%@/zz_api/photos/%@/pending_uploads", [gZZ serviceURL], [gZZ UID]];
    
    MLOG(@"pending_uploads: request %@", url);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"X-ZangZing-API" value:@"iphone"];
    if ([ZZSession currentUser].user_id) {
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:[gZZ authCookie]]];
    }
    
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSData *response = [request responseData];
        NSObject *data = [ZZGlobal getObjfromJSON:response];
        
        int result = [ZZGlobal responseError:request data:data];
        if (result == 0) {
            //NSArray *resp = (NSArray*)data;
        }
        
    }
}


-(UIImage*)lastPhoto
{
    @try {
        NSString *lastkey = [_photoSet objectAtIndex:[_photoSet count]-1];
        
        if (_lastphotokey == nil || ![_lastphotokey isEqualToString:lastkey])
            _lastphoto = nil;
            
        if (_lastphoto == nil) {
            _lastphotoScreenSize = nil; //clear lastPhotoImageView
            NSLog(@"load lastphoto: %@", _lastphotokey);
            
            _lastphotokey = lastkey;
            _lastphoto = [gZZ getUploadQueueImage:_lastphotokey];
        }
        return _lastphoto;
    }
    @catch (NSException *exception) {
    }
    
    return NULL;
}

-(UIImage *)lastPhotoScreenSize
{
    if( _lastphotoScreenSize == nil ){
        
            CGSize size = CGSizeMake(320,480);
            UIGraphicsBeginImageContext(size);
            [_lastphoto drawInRect:CGRectMake(0, 0, size.width, size.height)];
            _lastphotoScreenSize = UIGraphicsGetImageFromCurrentImageContext();    
            UIGraphicsEndImageContext();
    }
    return _lastphotoScreenSize;
}


-(UIImage*)getPhoto:(NSString*)key
{
    return [gZZ getUploadQueueImage:key];
}


-(void)applicationDidEnterBackground
{
    
}


-(void)applicationWillEnterForeground
{
    // reset when coming to foreground
    
    _abortBackgroundTasks = NO;
    _backgroundTask = 0;
    
    [self startTimer];
}


-(BOOL)suspended
{
    @synchronized(self) {
        
        BOOL suspend = NO;
        
        BOOL wifiOnly = NO;
        NSInteger w = [gZZ integerForSetting:[ZZSession currentUser].user_id setting:@"uploader_wifi_only"];
        if (w == 1)
            wifiOnly = YES;
        
        // if wifi only and on cellular data, return
        if (wifiOnly && [gZZ networkStatus] != kReachableViaWiFi)
            suspend = YES;
        
        return suspend;
    }
}


-(void)process
{
    if (_abortBackgroundTasks) {
        MLOG(@"abort background tasks");
        
        // kill any in-progress uploads
        [self cancelUploader];
        
        _processing = NO;
        
        [self stopTimer];
        
        int photoQueueCount = 0;
        @synchronized(_photoQueue) {
            photoQueueCount = [_photoQueue count];
        }
        
        if (photoQueueCount) {
            NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
            [xdata setObject:[NSNumber numberWithInt:photoQueueCount] forKey:@"count"];
            [ZZGlobal trackEvent:@"photouploader.background.abort" xdata:xdata];
        }
        
        return;
    }
    
    
    if ([gZZ networkStatus] == NotReachable) {
        // no network, defer till later
        return;
    }
        
    
    if (_processing)
        return;
    
    if ([self suspended])
        return;
    
    _processing = YES;
    
    @try {
        if (!_creatingphotos) {
            
            // call any pending create_photos calls
            
            @synchronized(_createPhotos) {
                
                if ([_createPhotos count] > 0) {
                    
                    // tell OS we want background time
                    [self beginBackgroundTask];
                    
                    [self performSelectorInBackground:@selector(create_photos) withObject:nil];

                }
            }    
        }
        
        if (![self uploading]) {
            
            @synchronized(_photoQueue) {
                
                if (_photoQueue.count > 0) {
                    [self performSelectorInBackground:@selector(uploader) withObject:nil];
                } 
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    
    _processing = NO;
}


-(void)uploadTimer: (NSTimer*)timer 
{
    [self process];
}


-(void)load
{
    // photo set
    @synchronized(_photoSet) {
        @try {
            NSArray* photoSet = (NSArray*)[gZZ getObj2:@"photo-set" keytype:@"SETTINGS"];
            if (!photoSet)
                photoSet = [[NSArray alloc]init];
            
            _photoSet = [[NSMutableArray alloc]initWithArray:photoSet copyItems:YES];
        }
        @catch (NSException *exception) {
            _photoSet = [[NSMutableArray alloc]init];
        }
        
        _photoSetDirty = NO;
        
        @try {
            NSDictionary* photoSetData = (NSDictionary*)[gZZ getObj2:@"photo-set-info" keytype:@"SETTINGS"];
            if (!photoSetData)
                photoSetData = [[NSDictionary alloc]init];
            
            _photoSetData = (__bridge_transfer NSMutableDictionary*) CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge CFPropertyListRef)photoSetData, kCFPropertyListMutableContainersAndLeaves);
        }
        @catch (NSException *exception) {
            _photoSetData = [[NSMutableDictionary alloc]init];
        }
        
        _photoSetDataDirty = NO;
        
        _photoSetCount = [_photoSet count];
    }
    
    // queue
    @synchronized(_photoQueue) {
        @try {
            NSArray* photoQueue = (NSArray*)[gZZ getObj2:@"photo-queue" keytype:@"SETTINGS"];
            if (!photoQueue)
                photoQueue = [[NSArray alloc]init];
            
            _photoQueue = [[NSMutableArray alloc]initWithArray:photoQueue copyItems:YES];
        }
        @catch (NSException *exception) {
            _photoQueue = [[NSMutableArray alloc]init];
        }
        
        _photoQueueDirty = NO;
        
        @try {
            NSDictionary* photoQueueData = (NSDictionary*)[gZZ getObj2:@"photo-queue-info" keytype:@"SETTINGS"];
            if (!photoQueueData)
                photoQueueData = [[NSDictionary alloc]init];
            
            _photoQueueData = (__bridge_transfer NSMutableDictionary*) CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge CFPropertyListRef)photoQueueData, kCFPropertyListMutableContainersAndLeaves);
        }
        @catch (NSException *exception) {
            _photoQueueData = [[NSMutableDictionary alloc]init];
        }
        
        _photoQueueDataDirty = NO;
    }
    
    
    // create_photos
    @synchronized(_createPhotos) {
        @try {
            NSArray* createPhotos = (NSArray*)[gZZ getObj2:@"create-photos" keytype:@"SETTINGS"];
            if (!createPhotos)
                createPhotos = [[NSArray alloc]init];
            
            _createPhotos = [[NSMutableArray alloc]initWithArray:createPhotos copyItems:YES];
            
        }
        @catch (NSException *exception) {
            _createPhotos = [[NSMutableArray alloc]init];
        }
        
        _createPhotosDirty = NO;
    }
}


-(void)save 
{
    @synchronized(_photoSet) {
        if (_photoSetDirty) {
            [gZZ cacheObj2:@"photo-set" keytype:@"SETTINGS" obj:_photoSet];
            _photoSetDirty = NO;
        }
        if (_photoSetDataDirty) {
            [gZZ cacheObj2:@"photo-set-info" keytype:@"SETTINGS" obj:_photoSetData]; 
            _photoSetDataDirty = NO;
        }
    }
    
    @synchronized(_photoQueue) {
        if (_photoQueueDirty) {
            [gZZ cacheObj2:@"photo-queue" keytype:@"SETTINGS" obj:_photoQueue]; 
            _photoQueueDirty = NO;
        }
        if (_photoQueueDataDirty) {
            [gZZ cacheObj2:@"photo-queue-info" keytype:@"SETTINGS" obj:_photoQueueData]; 
            _photoQueueDataDirty = NO;
        }
    }
    
    @synchronized(_createPhotos) {
        if (_createPhotosDirty) {
            [gZZ cacheObj2:@"create-photos" keytype:@"SETTINGS" obj:_createPhotos]; 
            _createPhotosDirty = NO;
        }
    }
}


-(void)logEvent_upload_begin:(NSString*)key retry:(int)retry
{
    NSMutableDictionary *evt = [[NSMutableDictionary alloc]init];
    [evt setObject:key forKey:@"photo"];
    [evt setObject:[NSNumber numberWithUnsignedInt:retry] forKey:@"retry"];
    
    [self logEvent:@"upload_begin" evt:evt];
}


-(void)logEvent_upload_end:(int)result error:(NSString*)error key:(NSString*)key start:(NSTimeInterval)start end:(NSTimeInterval)end bytes:(NSNumber*)bytes network:(NetworkStatus)network retry:(int)retry;
{
    NSMutableDictionary *evt = [[NSMutableDictionary alloc]init];
    [evt setObject:[NSNumber numberWithInt:result] forKey:@"result"];
    [evt setObject:key forKey:@"photo"];
    
    NSTimeInterval time = end - start;
    time = round (time * 10.0) / 10.0;      // round to tenths
    
    [evt setObject:[NSNumber numberWithDouble:time] forKey:@"time"];
    if (bytes == nil)
        bytes = [NSNumber numberWithInt:0];
    [evt setObject:bytes forKey:@"bytes"];
    [evt setObject:[NSNumber numberWithUnsignedInt:network] forKey:@"network"];
    [evt setObject:[NSNumber numberWithUnsignedInt:retry] forKey:@"retry"];
    if (error)
        [evt setObject:error forKey:@"error"];
    
    [self logEvent:@"upload_end" evt:evt];
    
    
    NSString *n = @"";
    switch (network) {
        case NotReachable:
            n = @"None";
            break;
            
        case ReachableViaWiFi:
            n = @"WiFi";
            break;
            
        case ReachableViaWWAN:   
            n = @"3G";
            break;
    }
    
    NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
    [xdata setObject:key forKey:@"id"];
    [xdata setObject:bytes forKey:@"bytes"];
    [xdata setObject:[NSNumber numberWithInt:result] forKey:@"result"];
    [xdata setObject:[NSNumber numberWithDouble:time] forKey:@"time"];
    [xdata setObject:n forKey:@"network"];
    [xdata setObject:[NSNumber numberWithUnsignedInt:retry] forKey:@"retry"];
    [ZZGlobal trackEvent:@"photouploader.upload" xdata:xdata];
}


-(void)logEvent_create_photos:(int)result error:(NSString*)error count:(int)count
{
    NSMutableDictionary *evt = [[NSMutableDictionary alloc]init];
    [evt setObject:[NSNumber numberWithInt:result] forKey:@"result"];
    [evt setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    if (error)
        [evt setObject:error forKey:@"error"];

    [self logEvent:@"create_photos" evt:evt];
}


-(void)logEvent:(NSString *)event evt:(NSMutableDictionary*)evt;
{
    MLOG(@"log event: %@ %@", event, evt);
    
    [evt setValue:event forKey:@"evt"];
    
    time_t time = (time_t) [[NSDate date] timeIntervalSince1970];
    [evt setValue:[NSNumber numberWithLong:time] forKey:@"at"];
    
    @synchronized(_log) {
        [_log addObject:evt];
    }
}


-(int)logCount
{
    @synchronized(_log) {
        return [_log count];
    }
}


-(NSDictionary*)logItem:(int)item 
{
    @synchronized(_log) {
        return [_log objectAtIndex:item];
    }
}


-(int)writeExifInfo:(NSString*)photo taken:(time_t)taken xdata:(NSDictionary*)xdata
{    
    NSTimeInterval start_x = [[NSDate date] timeIntervalSince1970];

    int fileSize = 0;
    
    @try {
        NSString *path = [gZZ uploadQueuePathForKey:photo];
        NSData *imageData = [[NSData alloc]initWithContentsOfFile:path];

        NSDate *takenDT = [NSDate dateWithTimeIntervalSince1970:taken];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"y:MM:dd HH:mm:SS"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString *dateTimeOrigin = [formatter stringFromDate:takenDT];
        
        NSNumber *altitude = [xdata objectForKey:@"location_alt"];
        NSNumber *longitude = [xdata objectForKey:@"location_long"];
        NSNumber *latitude = [xdata objectForKey:@"location_lat"];
        NSNumber *timestamp = [xdata objectForKey:@"location_timestamp"];
        
        BOOL haveGPSInfo = NO;
        if (longitude && longitude) 
            haveGPSInfo = YES;
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
        
        //get all the metadata in the image
        NSDictionary *metadata = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
        
        //make the metadata dictionary mutable so we can add properties to it
        NSMutableDictionary *metadataAsMutable = [metadata mutableCopy]; 
        
        NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
        NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
        if(!EXIFDictionary) {
            //if the image does not have an EXIF dictionary, then create one for us to use
            EXIFDictionary = [NSMutableDictionary dictionary];
        }
        if(!GPSDictionary) {
            GPSDictionary = [NSMutableDictionary dictionary];
        }
        
        if (haveGPSInfo) {
            // setup GPS dict
            
            // + for N Lat or E Long     
            // - for S Lat or W Long
            
            NSString *lat_ref = @"N";
            double llat = [latitude doubleValue];
            if (llat < 0) {
                llat = -llat;
                lat_ref = @"S";
            }
            
            [GPSDictionary setValue:[NSNumber numberWithDouble:llat] forKey:(NSString*)kCGImagePropertyGPSLatitude];
            [GPSDictionary setValue:lat_ref forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
            
            NSString *lon_ref = @"E";
            double llon = [longitude doubleValue];
            if (llon < 0) {
                llon = -llon;
                lon_ref = @"W";
            }
            
            [GPSDictionary setValue:[NSNumber numberWithDouble:llon] forKey:(NSString*)kCGImagePropertyGPSLongitude];
            [GPSDictionary setValue:lon_ref forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
            
            if (altitude) {
                short alt_ref = 0;
                double lalt = [altitude doubleValue];
                if (lalt < 0) {
                    lalt = -lalt;
                    alt_ref = 1;
                }
                
                [GPSDictionary setValue:[NSNumber numberWithDouble:lalt] forKey:(NSString*)kCGImagePropertyGPSAltitude];
                [GPSDictionary setValue:[NSNumber numberWithShort:alt_ref] forKey:(NSString*)kCGImagePropertyGPSAltitudeRef]; 
            }
            
            //[GPSDictionary setValue:[NSNumber numberWithFloat:0] forKey:(NSString*)kCGImagePropertyGPSImgDirection];
            //[GPSDictionary setValue:[NSString stringWithFormat:@"%c",_headingRef] forKey:(NSString*)kCGImagePropertyGPSImgDirectionRef];
            
            NSDate *loc_timestamp = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
            
            [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [GPSDictionary setObject:[formatter stringFromDate:loc_timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
            [formatter setDateFormat:@"yyyy:MM:dd"];
            [GPSDictionary setObject:[formatter stringFromDate:loc_timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
        } 
        
        // set DateTimeOriginal
        [EXIFDictionary setValue:dateTimeOrigin forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
        
        //add our modified EXIF data back into the image’s metadata
        [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
        [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
        
        CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
        
        //this will be the data CGImageDestinationRef will write into
        NSMutableData *dest_data = [NSMutableData data];
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
        
        if(!destination) {
            MLOG(@"writeExifInfo: could not create image destination");
            return 0;
        }
        
        // add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
        CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
        
        // tell the destination to write the image data and metadata into our data object.
        // it will return false if something goes wrong
        BOOL success = CGImageDestinationFinalize(destination);
        
        if(!success) {
            MLOG(@"writeExifInfo: could not create data from image destination");
            return 0;
        }
        
        // cleanup    
        CFRelease(destination);
        CFRelease(source);
        
        [dest_data writeToFile:path atomically:YES];
        
        fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    }
    @catch (NSException *exception) {
        
        [ZZGlobal trackException:@"writeExifInfo" exception:exception];
    }
    
    NSTimeInterval end_x = [[NSDate date] timeIntervalSince1970];
    MLOG(@"writeExifInfo: done: %.2fs; new size: %d", end_x-start_x, fileSize);    
    
    return fileSize;
}



@end
