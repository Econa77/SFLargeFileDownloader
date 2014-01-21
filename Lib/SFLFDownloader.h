//
//  SFLFDownloader.h
//  DemoApp
//
//  Created by 古林 俊祐 on 2014/01/21.
//  Copyright (c) 2014年 ShunsukeFurubayashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFLFDownloaderDelegate;

@interface SFLFDownloader : NSObject <NSURLConnectionDelegate>

//Delegate
@property (nonatomic, assign) id <SFLFDownloaderDelegate> delegate;
//ダウンロードURL
@property (strong, nonatomic) NSURL *downloadURL;
//ダウンロードPath
@property (strong, nonatomic) NSString *downloadPath;


//ダウンロード開始
- (void)startDownloadWithURL:(NSURL *)url withSavePath:(NSString *)filePath;
//ダウンロード終了
- (void)stopDownload;

@end

@protocol SFLFDownloaderDelegate <NSObject>

@optional
//ダウンロード開始時
- (void)downloaderStartDownloading:(SFLFDownloader *)downloader fileSize:(float)fileSize;
//ダウンロード中
- (void)downloaderReceivedData:(SFLFDownloader *)downloader downloadedFileSize:(float)fileSize;
//ダウンロード終了
- (void)downloaderFinishDownload:(SFLFDownloader *)downloader;
//ダウンロード失敗
- (void)downloaderFailedDownload:(SFLFDownloader *)downloader error:(NSError *)error;

@end
