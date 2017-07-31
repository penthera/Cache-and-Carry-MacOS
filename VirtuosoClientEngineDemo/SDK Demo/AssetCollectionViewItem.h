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
#import "ViewController.h"

/*
 * The AssetCollectionViewItem represents an asset in the main collection view.  It is the 
 * main mechanism for displaying asset data in this demo.
 */
@interface AssetCollectionViewItem : NSCollectionViewItem

@property (nonatomic,strong) VirtuosoAsset* asset;
@property (nonatomic,strong) NSIndexPath* indexPath;
@property (nonatomic,strong) NSStoryboard* mainStoryboard;
@property (nonatomic,strong) ViewController* parent;

@property (nonatomic,strong) IBOutlet NSTextField* assetDescription;
@property (nonatomic,strong) IBOutlet NSTextField* assetStatus;
@property (nonatomic,strong) IBOutlet NSTextField* assetDuration;
@property (nonatomic,strong) IBOutlet NSButton* upButton;
@property (nonatomic,strong) IBOutlet NSButton* downButton;
@property (nonatomic,strong) IBOutlet NSButton* resetButton;

- (IBAction)resetErrors:(id)sender;
- (IBAction)playAsset:(id)sender;
- (IBAction)deleteAsset:(id)sender;
- (IBAction)upButtonPressed:(id)sender;
- (IBAction)downButtonPressed:(id)sender;

@end
