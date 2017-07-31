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

/*
 * The DevicesViewController demonstrates a basic user interface for device management.  Examples are
 * shown for how to unregister a device and how to rename a device.
 */
@interface DevicesViewController : NSViewController<NSCollectionViewDelegate,NSCollectionViewDataSource>

@property(nonatomic,strong) IBOutlet NSCollectionView* collectionView;

/*
 * Called to update the UI when a device has been unregistered.
 */
- (void)didDeleteDevice:(VirtuosoDevice*)device;

/*
 * Called to update the UI when a device has been updated.
 */
- (void)didUpdateDevice:(VirtuosoDevice*)device;

@end
