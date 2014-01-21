//
//  SFLFDownloadManager.m
//  DemoApp
//
//  Created by 古林 俊祐 on 2014/01/21.
//  Copyright (c) 2014年 ShunsukeFurubayashi. All rights reserved.
//

#import "SFLFDownloadManager.h"
#import "SFLFDownloader.h"

#define KEY_DOWNLOAD_QUEUE @"key_download_queue"

NSString * const kLFDownloadStartNotification   = @"kLFDownloadStartNotification";
NSString * const kLFDownloadReceiveNotification = @"kLFDownloadReceiveNotification";
NSString * const kLFDownloadFinishNotification  = @"kLFDownloadFinishNotification";
NSString * const kLFDownloadFailNotification    = @"kLFDownloadFailNotification";
NSString * const kLFDownloadStopNotification    = @"kLFDownloadStopNotification";

@interface SFLFDownloadManager () <SFLFDownloaderDelegate>
@end

@implementation SFLFDownloadManager
{
    //ダウンロードキュー
    NSMutableArray *downloadQueueArray;
    //ダウンローダー
    SFLFDownloader *downloader;
}

#pragma mark - Init
+ (SFLFDownloadManager *)sharedManager
{
    static SFLFDownloadManager *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[SFLFDownloadManager alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self)
    {
        //Queue
        if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_DOWNLOAD_QUEUE] != nil) downloadQueueArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:KEY_DOWNLOAD_QUEUE]];
        else downloadQueueArray = [NSMutableArray arrayWithCapacity:0];
        //Downloder
        downloader = [SFLFDownloader new];
        [downloader setDelegate:self];
        //init
        self.downloadFileSize = 0;
        self.downloadedBytes  = 0;
    }
    return self;
}

#pragma mark - Self Methods
- (BOOL)isDownloadedFile:(NSString *)filePath
{
    if ([self isDownloadingFile:filePath]) return NO;
    //ファイル存在確認
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) return YES;
    else                                return NO;
}

- (BOOL)isDownloadingFile:(NSString *)filePath
{
    for (NSDictionary *dict in downloadQueueArray) {
        if ([[dict objectForKey:@"path"] isEqualToString:filePath]) return YES;
    }
    return NO;
}

- (void)downloadFileWithURL:(NSURL *)url withSavePath:(NSString *)filePath
{
    if ([self isDownloadingFile:filePath])
    {
        [self restartDownload];
        return;
    }else
    {
        if ([self isDownloadedFile:filePath]) return;
    }
    
    NSDictionary *downloadDict = @{@"url": [url absoluteString], @"path": filePath};
    [downloadQueueArray addObject:downloadDict];
    //Saved
    [[NSUserDefaults standardUserDefaults] setObject:downloadQueueArray forKey:KEY_DOWNLOAD_QUEUE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!self.isLoading) [self startDownload];
}

- (void)restartDownload
{
    if (!self.isLoading) [self startDownload];
}

- (void)stopDownloading
{
    [downloader stopDownload];
    self.isLoading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLFDownloadStopNotification object:self];
}

- (void)startDownload
{
    if ([downloadQueueArray count] == 0) return;
    if (self.isLoading) return;
    
    self.isLoading = YES;
    NSDictionary *downloadDict = [downloadQueueArray objectAtIndex:0];
    [downloader startDownloadWithURL:[NSURL URLWithString:[downloadDict objectForKey:@"url"]] withSavePath:[downloadDict objectForKey:@"path"]];
}

#pragma mark - SFLFDownloader Delegate
- (void)downloaderStartDownloading:(SFLFDownloader *)downloader fileSize:(float)fileSize
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.isLoading = YES;
    self.downloadFileSize = fileSize;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLFDownloadStartNotification object:self];
}

- (void)downloaderReceivedData:(SFLFDownloader *)downloader downloadedFileSize:(float)fileSize
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.isLoading = YES;
    self.downloadedBytes = fileSize;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLFDownloadReceiveNotification object:self];
}

- (void)downloaderFinishDownload:(SFLFDownloader *)downloader
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.isLoading = NO;
    
    if ([downloadQueueArray count] != 0)
    {
        [downloadQueueArray removeObjectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:downloadQueueArray forKey:KEY_DOWNLOAD_QUEUE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kLFDownloadFinishNotification object:self];
    if ([downloadQueueArray count] != 0)
    {
        if (!self.isLoading) [self startDownload];
    }
}

- (void)downloaderFailedDownload:(SFLFDownloader *)downloader error:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.isLoading = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLFDownloadFailNotification object:self];
}

@end
