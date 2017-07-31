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

#import "AssetCollectionViewItem.h"
#import "PlayerViewController.h"

@interface AssetCollectionViewItem ()
@property(nonatomic,strong) VirtuosoClientHTTPServer* server;
@property(nonatomic,strong) NSDate* playStart;
@end

@implementation AssetCollectionViewItem

- (id)init
{
    return [super initWithNibName:@"AssetCollectionViewItem" bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear
{
    [self updateAll];
}

- (void)downButtonPressed:(id)sender
{
    [self.parent moveDownAsset:self.asset atIndexPath:self.indexPath];
}

- (void)upButtonPressed:(id)sender
{
    [self.parent moveUpAsset:self.asset atIndexPath:self.indexPath];
}

- (void)showPlayerModalForURL:(NSURL*)url
{
    /*
     * If we're not playing with an internal player (HSS and Dash Assets require a web-based
     * player for the purposes of this demo), then we need some way to log playback start 
     * and finish.  Since this is just a demo, we'll show a modal popup in the app that the user
     * needs to click when they're done playing the asset in the web browser.
     */
    [VirtuosoLogger logPlaybackStartedForAsset:self.asset];
    
    // Update the UI.  Expiry after play may have adjusted data.
    [self updateAll];
    
    NSAlert* alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Now Playing Video"];
    [alert setInformativeText:[NSString stringWithFormat:@"The video you requested is now playing at the url %@.  Press OK here when finished.",url.absoluteString]];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    [alert runModal];
    
    [VirtuosoLogger logPlaybackStoppedForAsset:self.asset withSecondsSinceLastStart:abs(((int)[_playStart timeIntervalSinceNow]))];
}

- (void)playAsset:(id)sender
{
    /*
     * First check and make sure that the asset is playable.  Various states may render it unplayable:
     *
     *  1) We're not online and haven't downloaded the beginning of the asset yet.
     *  2) The asset was configured with a publishDate in the future.
     *  3) The asset is expired.
     *  4) The download engine has been offline too long (determined by the maximum offline value) and the user
     *     must return online to re-enable playback.
     */
    if( [self.asset isPlayable] )
    {
        /*
         * If the asset is HLS or MP4, we can play it natively in the app or we can play it via a web browser or
         * external player.  For the purposes of demonstration, we allow both.
         */
        if( self.asset.type == kVDE_AssetTypeHLS || self.asset.type == kVDE_AssetTypeNonSegmented )
        {
            NSAlert* alert = [[NSAlert alloc]init];
            [alert addButtonWithTitle:@"Native"];
            [alert addButtonWithTitle:@"External App"];
            [alert setMessageText:@"Play Video"];
            [alert setInformativeText:@"Select the method used to play this video."];
            [alert setAlertStyle:NSInformationalAlertStyle];
            
            NSModalResponse result = [alert runModal];
            if( result == NSAlertFirstButtonReturn )
            {
                /*
                 * The user chose to play natively.  Startup our internal player view and present it.
                 */
                PlayerViewController* player = [self.mainStoryboard instantiateControllerWithIdentifier:@"Player"];
                player.asset = self.asset;
                [self presentViewControllerAsModalWindow:player];
                
                // Update the UI... expiry after play may have adjusted data.
                [self updateAll];
            }
            else
            {
                NSURL* url = nil;
                if( self.asset.type == kVDE_AssetTypeHLS )
                {
                    /*
                     * The user chose to play an HLS asset externally.  This could be a browser or external player.  In order
                     * to play the downloaded asset, we'll startup (and hold) and instance of VirtuosoClientHTTPServer.  The
                     * server will provide a local version of the HLS manifest that will allow for local playback.
                     */
                    self.server = [[VirtuosoClientHTTPServer alloc]initWithAsset:self.asset];
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.server.playbackURL]];
                    url = [NSURL URLWithString:self.server.playbackURL];
                }
                else
                {
                    /*
                     * The user chose to play an MP4 asset externally.  We have the local file path for this type of asset,
                     * and the file path is accessible if the asset is playable, so just provide the external player that
                     * url directly.
                     */
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:self.asset.filePath]];
                    url = [NSURL fileURLWithPath:self.asset.filePath];
                }
                
                /*
                 * We're not playing via an in-app native player, so we need some way to determine, for demo purposes, when playback starts
                 * and finishes.  We'll show a modal popup to trigger these states in this demo.
                 */
                [self showPlayerModalForURL:url];
            }
        }
        else if( self.asset.type == kVDE_AssetTypeHSS )
        {
            /*
             * We don't have a native HSS player in this demo, so we're going to startup an instance of the VirtuosoClientHTTPServer and
             * hand that URL off to a web-based javascript player.
             */
            self.server = [[VirtuosoClientHTTPServer alloc]initWithAsset:self.asset];
            NSString* url = [NSString stringWithFormat:@"http://pressnells.net/penthera/hss/SmoothStreamingPlayer.php?url=%@",self.server.playbackURL];
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
            [self showPlayerModalForURL:[NSURL URLWithString:url]];
        }
        else if( self.asset.type == kVDE_AssetTypeDASH )
        {
            /*
             * We don't have a native DASH player in this demo, so we're going to startup an instance of the VirtuosoClientHTTPServer and
             * hand that URL off to a web-based javascript player.  We handle clear assets in this demo.  If the asset is widevine protected,
             * we show an error.  The SDK can download and provide local playback capability for widevine assets, but you need to provide
             * a player that supports widevine for this to work.
             */
            self.server = [[VirtuosoClientHTTPServer alloc]initWithAsset:self.asset];
            NSURL* url;
            if( self.asset.assetProtectionType == kVDE_AssetProtectionTypePassthrough )
            {
                NSString* _url = [NSString stringWithFormat:@"http://pressnells.net/penthera/dash/player.php?url=%@",self.server.playbackURL];
                url = [NSURL URLWithString:_url];
                
                [[NSWorkspace sharedWorkspace] openURLs:@[url]
                                withAppBundleIdentifier:@"com.google.Chrome"
                                                options:0
                         additionalEventParamDescriptor:nil
                                      launchIdentifiers:nil];
                [self showPlayerModalForURL:url];
            }
            else
            {
                NSAlert* alert = [[NSAlert alloc]init];
                [alert setMessageText:@"Widevine Not Supported"];
                [alert setInformativeText:@"Widevine is not currently supported in this demo."];
                [alert addButtonWithTitle:@"OK"];
                [alert runModal];
            }
        }
    }
    else
    {
        if( self.asset.isExpired )
        {
            NSAlert* alert = [[NSAlert alloc]init];
            [alert setMessageText:@"Expired Asset"];
            [alert setInformativeText:@"The item you've selected has expired."];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
        }
        else if( !self.asset.isWithinViewingWindow )
        {
            NSAlert* alert = [[NSAlert alloc]init];
            [alert setMessageText:@"Not Available Yet"];
            [alert setInformativeText:@"The item you've selected has not passed its publish time.  Please wait and try again later."];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
        }
        else
        {
            NSAlert* alert = [[NSAlert alloc]init];
            [alert setMessageText:@"Not Playable"];
            [alert setInformativeText:@"The item you've selected is not playable."];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
        }
        [self updateAll];
    }
}

- (void)resetErrors:(NSButton*)sender
{
    sender.enabled = NO;
    [self.asset clearRetryCountOnComplete:^{
        [self updateAll];
        sender.enabled = YES;
    }];
}

- (void)deleteAsset:(NSButton*)sender
{
    sender.enabled = NO;
    [self.asset deleteAssetOnComplete:^{
        sender.enabled = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AssetDeleted" object:nil];
    }];
}

- (void)updateAll
{
    [self updateDescription];
    [self updateDuration];
    [self updateStatus];
    
    Boolean hidden = (self.indexPath.section != 0);

    self.upButton.hidden = hidden;
    self.downButton.hidden = hidden;
    self.resetButton.hidden = hidden;
}

- (void)updateDescription
{
    _assetDescription.stringValue = _asset.description;
}

- (void)updateDuration
{
    if( _asset.duration == kInvalidDuration )
    {
        _assetDuration.stringValue = @"Duration: Unknown";
    }
    else
    {
        int durH = _asset.duration/60/60;
        int durM = (_asset.duration/60)-(durH*60);
        int durS = (int)_asset.duration - (durH*60*60) - (durM*60);
        NSString* secondLine = [NSString stringWithFormat:@"Duration: %02i:%02i:%02i",durH,durM,durS];
        
        _assetDuration.stringValue = secondLine;
    }
}

- (void)updateStatus
{
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    NSDate* effectiveExpiry = _asset.effectiveExpiryDate;

    NSString* errorAdd = @"";
    if( _asset.downloadRetryCount > 0 )
    {
        errorAdd = [NSString stringWithFormat:@" (Errors: %i)",_asset.downloadRetryCount];
    }

    // The Engine can handle downloads without knowing the expected size ahead of time.  How the asset's download status is reported changes
    // slightly if there is no expected size currently available.  To make sure we show data that makes sense based on the download status,
    // this example goes through several different options.  Depending on what you need to show in a production UI, this logic can be greatly
    // simplified.  As this is a demo intended to show utility of the SDK, Penthera has opted to show as much detail as possible to the User,
    // so the User can see what the SDK is doing in various asset configurations.
    double fractionComplete = _asset.fractionComplete;
    kVDE_DownloadStatusType status = _asset.status;
    
    if( _asset.isExpired )
    {
        _assetStatus.stringValue = [NSString stringWithFormat:@"Expired on %@",[df stringFromDate:effectiveExpiry]];
    }
    else if( _indexPath.section == 0 && status == kVDE_DownloadNone )
    {
        NSString* fastPlayAdd = @"";
        if( _asset.fastPlayEnabled )
        {
            if( _asset.fastPlayReady )
                fastPlayAdd = @" FastPlay(Ready)";
            else
                fastPlayAdd = @" FastPlay(Not Ready)";
        }
        _assetStatus.stringValue = [NSString stringWithFormat:@"Deferred%@%@",fastPlayAdd,errorAdd];
    }
    else if( fractionComplete == 0.0 && !_asset.isExpired && (status == kVDE_DownloadPending || status == kVDE_DownloadPendingOnPermission) )
    {
        NSString* permissionAdd = @"";
        if( status == kVDE_DownloadPendingOnPermission )
            permissionAdd = @"(No Permission)";
        
        if( effectiveExpiry != nil )
        {
            _assetStatus.stringValue = [NSString stringWithFormat:@"Waiting%@ (Expires on %@)%@",permissionAdd,[df stringFromDate:effectiveExpiry],errorAdd];
        }
        else
        {
            _assetStatus.stringValue = [NSString stringWithFormat:@"Waiting%@%@",permissionAdd,errorAdd];
        }
    }
    else if( status != kVDE_DownloadComplete && status != kVDE_DownloadProcessing )
    {
        NSString* permissionAdd = @"";
        if( status == kVDE_DownloadPendingOnPermission )
            permissionAdd = @"(No Permission)";
        
        if( effectiveExpiry != nil )
        {
            _assetStatus.stringValue = [NSString stringWithFormat:@"%0.02f%% (%qi MB)%@ (Expires on %@)%@",fractionComplete*100.0,_asset.currentSize/1024/1024,permissionAdd,[df stringFromDate:effectiveExpiry],errorAdd];
        }
        else
        {
            _assetStatus.stringValue = [NSString stringWithFormat:@"%0.02f%% (%qi MB)%@%@",fractionComplete*100.0,_asset.currentSize/1024/1024,permissionAdd,errorAdd];
        }
    }
    else
    {
        NSString* statusText = @"Complete";
        if( status == kVDE_DownloadProcessing )
        {
            statusText = @"Processing";
        }
        if( effectiveExpiry != nil )
        {
            _assetStatus.stringValue = [NSString stringWithFormat:@"%@ (%qi MB) (Expires on: %@)",statusText,_asset.currentSize/1024/1024,[df stringFromDate:effectiveExpiry]];
        }
        else
        {
            _assetStatus.stringValue = [NSString stringWithFormat:@"%@ (%qi MB)",statusText,_asset.currentSize/1024/1024];
        }
    }
}

@end
