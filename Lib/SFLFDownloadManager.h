//
//  SFLFDownloadManager.h
//  DemoApp
//
//  Created by 古林 俊祐 on 2014/01/21.
//  Copyright (c) 2014年 ShunsukeFurubayashi. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kLFDownloadStartNotification;
extern NSString * const kLFDownloadReceiveNotification;
extern NSString * const kLFDownloadFinishNotification;
extern NSString * const kLFDownloadFailNotification;
extern NSString * const kLFDownloadStopNotification;

@interface SFLFDownloadManager : NSObject

//読み込みフラグ
@property (nonatomic) BOOL isLoading;
//ダウンロード済みバイト
@property (nonatomic) float downloadedBytes;
//ダウンロードするファイルのサイズ
@property (nonatomic) float downloadFileSize;
//ダウンロードしているファイル
@property (strong,nonatomic) NSURL *downloadingURL;


//インスタンス作成
+ (SFLFDownloadManager *)sharedManager;


//ダウンロード済み確認
- (BOOL)isDownloadedFile:(NSString *)filePath;
//ダウンロード待ち確認
- (BOOL)isDownloadingFile:(NSString *)filePath;
//ダウンロード
- (void)downloadFileWithURL:(NSURL *)url withSavePath:(NSString *)filePath;
//ダウンロード再開
- (void)restartDownload;
//ダウンロード停止
- (void)stopDownloading;

@end
