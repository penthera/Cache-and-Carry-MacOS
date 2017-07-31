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

#import <Cocoa/Cocoa.h>
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import <VirtuosoClientSubscriptionManager/VirtuosoSubscriptionManager.h>

/*
 * The main entry point for the demo app, this basic view controller simply displays a list of 
 * assets available in the SDK, sorted by queue order and status.
 */
@interface ViewController : NSViewController<NSCollectionViewDelegate,NSCollectionViewDataSource>

/*
 * Basic collection view, used for showing the assets in this demo.
 */
@property (nonatomic,strong) IBOutlet NSCollectionView* collectionView;

/*
 * Demonstration of the "logout without unregister" use case.  If the user logs out
 * and later logs back in, the same download engine state is preserved.  If a different
 * user logs in, then the download engine is reset and all previously downloaded assets
 * are deleted.
 */
- (IBAction)logout:(id)sender;

/* 
 * Convenience methods to move assets up and down in the download queue.
 */
- (void)moveUpAsset:(VirtuosoAsset*)asset atIndexPath:(NSIndexPath*)indexPath;
- (void)moveDownAsset:(VirtuosoAsset*)asset atIndexPath:(NSIndexPath*)indexPath;

@end

