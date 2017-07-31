/*!
 *  PENTHERA CONFIDENTIAL
 *
 *  Notice: This file is the property of Penthera Inc.
 *  The concepts contained herein are proprietary to Penthera Inc.
 *  and may be covered by U.S. and/or foreign patents and/or patent
 *  applications, and are protected by trade secret or copyright law.
 *  Distributing and/or reproducing this information is forbidden unless
 *  prior written permission is obtained from Penthera Inc.
 *
 *  The VirtuosoClientEngineDemo project has been provided as an example application
 *  that uses the Virtuoso Download SDK.  It is provided as-is with no warranties whatsoever,
 *  expressed or implied.  This project provides a working example and shows ONE possible
 *  use of the SDK for a end-to-end video download process.  Other configurations
 *  are possible.  Please contact Penthera support if you have any questions.  We
 *  are here to help!
 *
 *  @copyright (c) 2017 Penthera Inc. All Rights Reserved.
 *
 */

#import "PlayerViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoAVPlayer.h>

/*
 * Local declaration of the internal VirtuosoClientHTTPServer instance for offline playback.
 */
@interface PlayerViewController ()
@property (nonatomic,strong) VirtuosoClientHTTPServer* server;
@end

@implementation PlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear
{
    /*
     * Set the view title
     */
    self.title = self.asset.description;
    
    /*
     * If we're playing an MP4, then we can just playback the file path directly.
     *
     * If we're playing an HLS asset, then we need to startup a local copy of the
     * VirtuosoClientHTTPServer and use the URL it provides for playback.
     */
    NSURL* url;
    if( self.asset.type == kVDE_AssetTypeNonSegmented )
    {
        url = [NSURL fileURLWithPath:self.asset.filePath];
    }
    else
    {
        self.server = [[VirtuosoClientHTTPServer alloc]initWithAsset:self.asset];
        NSLog(@"Player URL: %@",self.server.playbackURL);
        url = [NSURL URLWithString:self.server.playbackURL];
    }

    /*
     * We're going to use the VirtuosoAVPlayer for playback, which requires that we 
     * instantiate it with an AVPlayerItem.  The VirtuosoAVPlayer is a drop-in replacement
     * for AVPlayer, and it automatically handles internal event reporting and other
     * convenient business logic for us.
     */
    AVAsset* avAsset = [AVURLAsset assetWithURL:url];
    AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:avAsset];
    VirtuosoAVPlayer* avPlayer = [VirtuosoAVPlayer playerWithPlayerItem:item];
    avPlayer.contentURL = url;
    avPlayer.asset = self.asset;
    [avPlayer prepareToPlay];
    
    /*
     * Set the player into our player view, and then start playback.
     */
    [self.player setPlayer:avPlayer];
    [avPlayer play];
}

@end
