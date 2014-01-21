//
//  ViewController.m
//  DemoApp
//
//  Created by 古林 俊祐 on 2014/01/22.
//  Copyright (c) 2014年 Shunsuke Furubayashi. All rights reserved.
//

#import "ViewController.h"
#import "SFLFDownloadManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@end

@implementation ViewController
{
    AVAudioPlayer *player;
}

#pragma mark - Init
- (void)initTitles
{
    //SavePath
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/holiday.mp3"];
    
    if ([[SFLFDownloadManager sharedManager] isDownloadingFile:path]) {
        if ([[SFLFDownloadManager sharedManager] isLoading]) {
            [self.downloadButton setTitle:@"Downloading" forState:UIControlStateNormal];
            [self.fileSizeLabel setText:[NSString stringWithFormat:@"%d％ Downloaded", (int)([[SFLFDownloadManager sharedManager] downloadedBytes] / [[SFLFDownloadManager sharedManager] downloadFileSize] * 100)]];
        }
        else {
            [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
            [self.fileSizeLabel setText:@""];
        }
    }
    else if ([[SFLFDownloadManager sharedManager] isDownloadedFile:path]) {
        [self.downloadButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.fileSizeLabel setText:@"100％ Downloaded"];
    }
    else {
        [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
        [self.fileSizeLabel setText:@"0％ Downloaded"];
    }
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTitles];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDownload:) name:kLFDownloadStartNotification object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDownload:) name:kLFDownloadReceiveNotification object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishDownload:) name:kLFDownloadFinishNotification object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedDownload:) name:kLFDownloadFailNotification object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDownload:) name:kLFDownloadStopNotification object:Nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions
- (IBAction)downloadAudioFile:(id)sender
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/holiday.mp3"];
    
    if ([[SFLFDownloadManager sharedManager] isDownloadedFile:path]) {
        //Play
        if (player.playing) {
            [player stop];
            [self.downloadButton setTitle:@"Play" forState:UIControlStateNormal];
        }
        else {
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:Nil];
            [player play];
            [self.downloadButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
    }
    else {
        [[SFLFDownloadManager sharedManager] downloadFileWithURL:[NSURL URLWithString:@"http://mr3.douban.com/201401220010/e6b3de9875be0e0eafcc17d9597917cb/view/song/small/p1454239.mp3"] withSavePath:path];
    }
}


- (void)startDownload:(NSNotification *)notification
{
    [self initTitles];
}

- (void)receiveDownload:(NSNotification *)notification
{
    [self initTitles];
}

- (void)finishDownload:(NSNotification *)notification
{
    [self initTitles];
}

- (void)failedDownload:(NSNotification *)notification
{
    [self initTitles];
}

- (void)stopDownload:(NSNotification *)notification
{
    [self initTitles];
}

@end
