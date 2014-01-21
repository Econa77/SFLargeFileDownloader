//
//  SFLFDownloader.m
//  DemoApp
//
//  Created by 古林 俊祐 on 2014/01/21.
//  Copyright (c) 2014年 ShunsukeFurubayashi. All rights reserved.
//

#import "SFLFDownloader.h"

@implementation SFLFDownloader
{
    NSURLConnection *connection;
    NSFileHandle *fileHandle;
    NSUInteger downloadedBytes;
}

#pragma mark - Init
- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Self Methods
- (void)startDownloadWithURL:(NSURL *)url withSavePath:(NSString *)filePath
{
    self.downloadURL  = url;
    self.downloadPath = filePath;
    //リクエスト作成
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    //ダウンロード再開サイズ取得
    downloadedBytes = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath
                                                            error:&error];
        if (!error && fileDictionary)
            downloadedBytes = [fileDictionary fileSize];
    } else {
        [fm createFileAtPath:filePath contents:nil attributes:nil];
    }
    if (downloadedBytes > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%lu-", (unsigned long)downloadedBytes];
        [request setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    //コネクション作成
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    //ダウンロード開始
    [connection start];
}

- (void)stopDownload
{
    [connection cancel];
}

#pragma mark - NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([self.delegate respondsToSelector:@selector(downloaderStartDownloading:fileSize:)]) {
        [self.delegate downloaderStartDownloading:self fileSize:downloadedBytes + [response expectedContentLength]];
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) return;
    
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:self.downloadPath];
    fileHandle = fh;
    switch (httpResponse.statusCode) {
        case 206: {
            NSString *range = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
            NSError *error = nil;
            NSRegularExpression *regex = nil;
            
            regex = [NSRegularExpression regularExpressionWithPattern:@"bytes (\\d+)-\\d+/\\d+"
                                                              options:NSRegularExpressionCaseInsensitive
                                                                error:&error];
            if (error) {
                [fh truncateFileAtOffset:0];
                break;
            }
            
            NSTextCheckingResult *match = [regex firstMatchInString:range
                                                            options:NSMatchingAnchored
                                                              range:NSMakeRange(0, range.length)];
            if (match.numberOfRanges < 2) {
                [fh truncateFileAtOffset:0];
                break;
            }
            
            NSString *byteStr = [range substringWithRange:[match rangeAtIndex:1]];
            NSInteger bytes = [byteStr integerValue];
            if (bytes <= 0) {
                [fh truncateFileAtOffset:0];
                break;
            } else {
                [fh seekToFileOffset:bytes];
            }
            break;
        }
        default:
            [fh truncateFileAtOffset:0];
            break;
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fileHandle writeData:data];
    [fileHandle synchronizeFile];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.downloadPath]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:self.downloadPath
                                                            error:&error];
        if (!error && fileDictionary) {
            if ([self.delegate respondsToSelector:@selector(downloaderReceivedData:downloadedFileSize:)]) {
                [self.delegate downloaderReceivedData:self downloadedFileSize:[fileDictionary fileSize]];
            }
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [fileHandle closeFile];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.downloadPath]) {
        if ([self.delegate respondsToSelector:@selector(downloaderFinishDownload:)]) {
            [self.delegate downloaderFinishDownload:self];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(downloaderFailedDownload:error:)]) {
        [self.delegate downloaderFailedDownload:self error:error];
    }
}

@end
