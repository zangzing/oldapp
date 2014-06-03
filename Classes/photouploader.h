//
//  photouploader.h
//  ZangZing
//
//  Created by Phil Beisel on 11/8/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "zzglobal.h"
#import "zztypes.h"

// TODO:
// 1.10.12  pb
// clear out older cached upload photos + thumbs
// 12.22.11 pb
// what should the photo uploader do with a iOS memory warning?  could stop uploads in progress

@interface PhotoUploader : NSObject <ASIProgressDelegate> {
    
    // current photo set
    UIImage* _lastphoto;
    UIImage* _lastphotoScreenSize;
    NSString* _lastphotokey;
    NSUInteger _photoSetCount;
    NSMutableArray* _photoSet;              // current photo set (list of keys)
    BOOL _photoSetDirty;
    NSMutableDictionary* _photoSetData;     // key -> info
    BOOL _photoSetDataDirty;
    
    // upload photo queue
    NSMutableArray* _photoQueue;            // photo upload queue (list of keys)
    BOOL _photoQueueDirty;
    NSMutableDictionary * _photoQueueData;  // key -> info
    BOOL _photoQueueDataDirty;
    NSMutableArray *_createPhotos;          // pending create_photos
    BOOL _createPhotosDirty;
    
    NSString* _uploadingPhoto;
    unsigned long _uploadingPhotoSize;
    
    unsigned long long _bytesToUploadRequest;       // # of bytes to upload, current request   
    unsigned long long _bytesToUploadRequestLeft;   // # of bytes to upload left, current request 
    BOOL _recalcedActualBytes;
    
    int _totalreadyupload;
    unsigned long long _totalreadyuploadbytes;
    unsigned long long _totalbytessent;
    unsigned long long _lastSent;
    
    BOOL _creatingphotos;                   // currently in create_photos
    int _uploading;                         // currently uploading if > 0 (indicates # uploading concurrently)
    BOOL _abortBackgroundTasks;
    BOOL _processing;
    
    ASIFormDataRequest  *_request;
    UIBackgroundTaskIdentifier _backgroundTask;
    NSTimer *_timer;
    
    NSMutableArray *_log;                   // in-memory log of uploader activity
}


-(void)process;

// photo set
-(void)addPhoto:(UIImage*)photo photoData:(NSData*)photoData taken:(time_t)taken xdata:(NSDictionary*)xdata; 
-(void)removePhoto:(NSString*)photo;
-(NSUInteger)photoCount;
-(void)clearPhotos;                                                 // clears added photos
-(NSArray*)getPhotos;
-(NSArray*)getPhotosKeys;

-(void)setCaption:(NSString*)photo caption:(NSString*)caption;
-(NSString*)getCaption:(NSString*)photo;

-(int)writeExifInfo:(NSString*)photo taken:(time_t)taken xdata:(NSDictionary*)xdata;

// upload queue
-(void)queuePhotos:(ZZUserID)userid albumid:(ZZAlbumID)albumid shareData:(NSDictionary*)shareData;    // queue's added photos for upload
-(NSUInteger)queueCount;
-(NSUInteger)readyToUploadCount;
-(unsigned long long)readyToUploadBytes;
-(BOOL)uploading;
-(UIImage*)lastPhoto;
-(UIImage *)lastPhotoScreenSize;
-(UIImage*)getPhoto:(NSString*)key;
-(NSUInteger)createPhotosCount;
-(NSUInteger)totalReadyUpload;
-(unsigned long long)bytesToUpload;
-(unsigned long long)bytesUploaded;

// internal
-(void)pending_uploads;
-(void)create_photos;
-(int)create_photos:(ZZAlbumID)albumid photos:(NSArray*)photos photos_created:(NSArray**)photos_created;
-(int)upload:(NSString*)photokey;
-(void)uploader;
-(void)cancelUploader;

// persist
-(void)load;
-(void)save;

// logging
-(void)logEvent:(NSString *)event evt:(NSMutableDictionary*)evt;
-(void)logEvent_create_photos:(int)result error:(NSString*)error count:(int)count;
-(void)logEvent_upload_begin:(NSString*)key retry:(int)retry;
-(void)logEvent_upload_end:(int)result error:(NSString*)error key:(NSString*)key start:(NSTimeInterval)start end:(NSTimeInterval)end bytes:(NSNumber*)bytes network:(NetworkStatus)network retry:(int)retry;
-(int)logCount;
-(NSDictionary*)logItem:(int)item;

// misc
-(void)beginBackgroundTask;
-(void)endBackgroundTask;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)startTimer;
-(void)stopTimer;
-(BOOL)suspended;

@end

extern PhotoUploader *gPhotoUploader;
