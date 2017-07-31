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

#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import <VirtuosoClientSubscriptionManager/VirtuosoSubscriptionManager.h>

#import "CatalogViewController.h"
#import "AssetGroupHeader.h"
#import "CatalogCollectionViewItem.h"

static int addCount = 1;
static NSString* assetsAddLock = @"ASSET_ADD_LOCK";

/*
 * NOTE: These are for test/demo purposes only and you should NEVER access these directly.  They are used here
 *       only to create assets with pre-configured error states to demo SDK capabilities.
 */
@interface VirtuosoAsset()
- (void)_setDownloadRetryCount:(int)newCount;
- (void)_setError:(kVDE_DownloadErrorType)error;
- (void)_setMaximumRetriesExceeded:(Boolean)exceeded;
@end

/*
 * NOTE: This method is for test/demo purposes only and you should NEVER access it outside of this demo application.
 */
@interface VirtuosoSubscriptionManager()
- (void)generatePushUpdate:(NSDictionary*)data;
@end

@interface CatalogViewController ()
@property (nonatomic,strong) NSMutableDictionary* catalog;
@end

@implementation CatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     * Setup the basic collection view UI structure.
     */
    [self.collectionView registerClass:[CatalogCollectionViewItem class] forItemWithIdentifier:@"AssetCollectionViewItem"];
    [self.collectionView registerClass:[AssetGroupHeader class]
            forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader
                        withIdentifier:@"AssetGroupHeader"];
    [self.collectionView reloadData];

    // Path to the plist (in the application bundle)
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"DemoCatalog" ofType:@"plist"];

    // Build the array from the plist
    self.catalog = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    return self.catalog.allKeys.count+1;
}

- (NSView*)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    AssetGroupHeader* header = [collectionView makeSupplementaryViewOfKind:kind withIdentifier:@"AssetGroupHeader" forIndexPath:indexPath];
    NSInteger section = indexPath.section;
    
    if( section < self.catalog.allKeys.count )
    {
        NSMutableArray* keys = self.catalog.allKeys.mutableCopy;
        [keys sortUsingSelector:@selector(compare:)];
        
        header.label.stringValue = [keys objectAtIndex:section];
    }
    else
    {
        section -= self.catalog.allKeys.count;
        
        switch (section) {
            case 0:
                header.label.stringValue = @"Failure Modes";
                break;
                
            default:
                header.label.stringValue = @"";
                break;
        }
    }
    header.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    return header;
}

/* Asks the data source for the number of items in the specified section.
 */
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if( section < self.catalog.allKeys.count )
    {
        NSMutableArray* keys = self.catalog.allKeys.mutableCopy;
        [keys sortUsingSelector:@selector(compare:)];
        
        NSString* key = [keys objectAtIndex:section];
        NSArray* items = [self.catalog objectForKey:key];
        
        return items.count;
    }
    
    section -= self.catalog.allKeys.count;
    
    switch (section) {
        case 0:
            return 10;
            break;
            
        default:
            return 0;
            break;
    }
    return 0;
}

/* Asks the data source to provide an NSCollectionViewItem for the specified represented object.
 
 Your implementation of this method is responsible for creating, configuring, and returning the appropriate item for the given represented object.  You do this by sending -makeItemWithIdentifier:forIndexPath: method to the collection view and passing the identifier that corresponds to the item type you want.  Upon receiving the item, you should set any properties that correspond to the data of the corresponding model object, perform any additional needed configuration, and return the item.
 
 You do not need to set the location of the item's view inside the collection view’s bounds. The collection view sets the location of each item automatically using the layout attributes provided by its layout object.
 
 This method must always return a valid item instance.
 */
- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"CatalogCollectionViewItem"
                                                              forIndexPath:indexPath];

    [self updateCollectionViewItem:item forCatalogEntryAtIndexPath:indexPath];
    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView willDisplayItem:(CatalogCollectionViewItem*)item forRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.item%2 == 0 )
        item.view.layer.backgroundColor = [NSColor colorWithWhite:0.95 alpha:1].CGColor;
    else
        item.view.layer.backgroundColor = [NSColor colorWithWhite:0.9 alpha:1].CGColor;
    
    [self updateCollectionViewItem:item forCatalogEntryAtIndexPath:indexPath];
}

- (void)updateCollectionViewItem:(CatalogCollectionViewItem*)item forCatalogEntryAtIndexPath:(NSIndexPath*)indexPath
{
    if( indexPath.section < self.catalog.allKeys.count )
    {
        NSMutableArray* keys = self.catalog.allKeys.mutableCopy;
        [keys sortUsingSelector:@selector(compare:)];
        
        NSString* key = [keys objectAtIndex:indexPath.section];
        NSArray* items = [self.catalog objectForKey:key];
        
        NSDictionary* _item = [items objectAtIndex:indexPath.item];
        item.name.stringValue = [_item objectForKey:@"title"];
    }
    else
    {
        NSInteger section = indexPath.section;
        section -= self.catalog.allKeys.count;
        
        switch (section) {
            case 0:
            {
                switch (indexPath.item ) {
                    case 0:
                        item.name.stringValue = @"File Returning HTTP 404";
                        break;
                        
                    case 1:
                        item.name.stringValue = @"File With Invalid Mime";
                        break;
                        
                    case 2:
                        item.name.stringValue = @"File Exceeding Max Errors+Loops";
                        break;
                        
                    case 3:
                        item.name.stringValue = @"File With Some Pre-Errors";
                        break;
                        
                    case 4:
                        item.name.stringValue = @"File with publishDate 5 minutes from now";
                        break;
                        
                    case 5:
                        item.name.stringValue = @"File with expiryDate 5 minutes from now";
                        break;
                        
                    case 6:
                        item.name.stringValue = @"File with expiryAfterDownload at 5 minutes";
                        break;
                        
                    case 7:
                        item.name.stringValue = @"File with expiryAfterPlay at 5 minutes";
                        break;
                        
                    case 8:
                        item.name.stringValue = @"HLS File with Expiry 5 minutes from now";
                        break;
                        
                    case 9:
                        item.name.stringValue = @"File with broken download in middle";
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)handleError:(NSError*)error
{
    if( error )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            /*
             * If permissions are enabled on the backplane, then we may run into this error while creating the asset.  This indicates
             * the asset has been downloaded as many times as permitted, and it cannot be downloaded by this account again without
             * administrative intervention.
             */
            if( error.code == kVDE_PermissionsErrorLifetimeDownloadLimit )
            {
                NSAlert* alert = [[NSAlert alloc]init];
                [alert setMessageText:@"Permissions Error"];
                [alert setInformativeText:@"This asset has already been downloaded by this account as many times as permitted."];
                [alert addButtonWithTitle:@"OK"];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
            }
            /*
             * If permissions are enabled on the backplane, then we may run into this error while creating the asset.  This indicates
             * that the user has more than the permitted number of downloads for the account, and the user must delete some downloaded
             * assets, on this device or other devices, to allow downloading to continue.  Once the user deletes some assets, downloading
             * will automatically commence without further user intervention.
             */
            else if( error.code == kVDE_PermissionsErrorMaximumDownloadsPerAccount )
            {
                NSAlert* alert = [[NSAlert alloc]init];
                [alert setMessageText:@"Permissions Error"];
                [alert setInformativeText:@"You have downloaded the maximum number of assets permitted for this account.  Please delete some assets from one of your devices to continue with this download."];
                [alert addButtonWithTitle:@"OK"];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
            }
            else
            {
                NSAlert* alert = [[NSAlert alloc]init];
                [alert setMessageText:@"Download Error"];
                [alert setInformativeText:error.localizedDescription];
                [alert addButtonWithTitle:@"OK"];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
            }
        });
    }
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [collectionView deselectItemsAtIndexPaths:indexPaths];
    });
    
    NSIndexPath* indexPath = [indexPaths allObjects][0];
    
    if( indexPath.section < self.catalog.allKeys.count )
    {
        NSMutableArray* keys = self.catalog.allKeys.mutableCopy;
        [keys sortUsingSelector:@selector(compare:)];
        
        NSString* key = [keys objectAtIndex:indexPath.section];
        NSArray* items = [self.catalog objectForKey:key];
        
        NSDictionary* item = [items objectAtIndex:indexPath.item];
        
        NSString* itemDescription = [NSString stringWithFormat:@"%@: %i",[item objectForKey:@"description"],addCount];
        
        // Enqueue based on defined catalog record type.  0 = HLS, 1 = HSS, 2 = MP4, 3 = UNUSED, 4 = UNUSED, 5 = DASH
        // Note: This demo catalog only contains HLS and MP4 assets.
        switch( [[item objectForKey:@"type"]intValue] )
        {
            case 0:
            {
                [VirtuosoAsset assetWithAssetID:[item objectForKey:@"assetID"]
                                    description:itemDescription
                                    manifestUrl:[item objectForKey:@"downloadURL"]
                                 protectionType:[[item objectForKey:@"protectionType"]intValue]
                          includeEncryptionKeys:[[item objectForKey:@"includeEncryptionKeys"]boolValue]
                                 maximumBitrate:([[item objectForKey:@"maximumBitrate"]longLongValue]>=0)?[[item objectForKey:@"maximumBitrate"]longLongValue]:INT_MAX
                                    publishDate:([item objectForKey:@"publishDelay"]!=nil)?[NSDate dateWithTimeIntervalSinceNow:[[item objectForKey:@"publishDelay"]doubleValue]]:nil
                                     expiryDate:([item objectForKey:@"expiryDelay"]!=nil)?[NSDate dateWithTimeIntervalSinceNow:[[item objectForKey:@"expiryDelay"]doubleValue]]:nil
                            expiryAfterDownload:([item objectForKey:@"eadDelay"]!=nil)?[[item objectForKey:@"eadDelay"]doubleValue]:kInvalidExpiryTimeInterval
                                expiryAfterPlay:([item objectForKey:@"eapDelay"]!=nil)?[[item objectForKey:@"eapDelay"]doubleValue]:kInvalidExpiryTimeInterval
                                 enableFastPlay:NO
                                       userInfo:[item objectForKey:@"userInfo"]
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset)
                             {
                                 NSLog(@"Item is ready for download: %@",itemDescription);
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                     [self handleError:error];
                                 }];
                             }
                             onParseComplete:^(VirtuosoAsset *parsedAsset, NSError* error)
                             {
                                 NSLog(@"Finished parsing %@", itemDescription);
                                 if( error != nil )
                                 {
                                     NSLog(@"Detected error creating new asset: %@",error);
                                     [self handleError:error];
                                 }
                             }
                ];
                addCount++;
            }
            break;
                
            case 1:
            {
                [VirtuosoAsset assetWithAssetID:[item objectForKey:@"assetID"]
                                    description:itemDescription
                                    manifestUrl:[item objectForKey:@"downloadURL"]
                            maximumVideoBitrate:([[item objectForKey:@"maximumBitrate"]longLongValue]>=0)?[[item objectForKey:@"maximumBitrate"]longLongValue]:INT_MAX
                            maximumAudioBitrate:([[item objectForKey:@"maximumAudioBitrate"]longLongValue]>=0)?[[item objectForKey:@"maximumAudioBitrate"]longLongValue]:INT_MAX
                                    publishDate:([item objectForKey:@"publishDelay"]!=nil)?[NSDate dateWithTimeIntervalSinceNow:[[item objectForKey:@"publishDelay"]doubleValue]]:nil
                                     expiryDate:([item objectForKey:@"expiryDelay"]!=nil)?[NSDate dateWithTimeIntervalSinceNow:[[item objectForKey:@"expiryDelay"]doubleValue]]:nil
                            expiryAfterDownload:([item objectForKey:@"eadDelay"]!=nil)?[[item objectForKey:@"eadDelay"]doubleValue]:kInvalidExpiryTimeInterval
                                expiryAfterPlay:([item objectForKey:@"eapDelay"]!=nil)?[[item objectForKey:@"eapDelay"]doubleValue]:kInvalidExpiryTimeInterval
                                 enableFastPlay:NO
                                       userInfo:[item objectForKey:@"userInfo"]
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset)
                             {
                                 NSLog(@"Item is ready for download: %@",itemDescription);
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                     [self handleError:error];
                                 }];
                             }
                             onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error)
                             {
                                 NSLog(@"Finished parsing %@", itemDescription);
                                 if( error != nil )
                                 {
                                     NSLog(@"Detected error creating new asset: %@",error);
                                     [self handleError:error];
                                 }
                             }
                ];
                addCount++;
            }
            break;

            case 2:
            {
                [VirtuosoAsset assetWithRemoteURL:[item objectForKey:@"downloadURL"]
                                          assetID:[item objectForKey:@"assetID"]
                                      description:itemDescription
                                      publishDate:([item objectForKey:@"publishDelay"]!=nil)?[NSDate dateWithTimeIntervalSinceNow:[[item objectForKey:@"publishDelay"]doubleValue]]:nil
                                       expiryDate:([item objectForKey:@"expiryDelay"]!=nil)?[NSDate dateWithTimeIntervalSinceNow:[[item objectForKey:@"expiryDelay"]doubleValue]]:nil
                              expiryAfterDownload:([item objectForKey:@"eadDelay"]!=nil)?[[item objectForKey:@"eadDelay"]doubleValue]:kInvalidExpiryTimeInterval
                                  expiryAfterPlay:([item objectForKey:@"eapDelay"]!=nil)?[[item objectForKey:@"eapDelay"]doubleValue]:kInvalidExpiryTimeInterval
                                   enableFastPlay:NO
                                         userInfo:[item objectForKey:@"userInfo"]
                               onReadyForDownload:^(VirtuosoAsset *parsedAsset)
                               {
                                   NSLog(@"Item is ready for download: %@",itemDescription);
                                   [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error)
                                   {
                                       [self handleError:error];
                                   }];
                               }
                               onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error)
                               {
                                   NSLog(@"Finished parsing %@", itemDescription);
                                   if( error != nil )
                                   {
                                       NSLog(@"Detected error creating new asset: %@",error);
                                       [self handleError:error];
                                   }
                               }
                ];
                addCount++;
            }
            break;
                
            case 5:
            {
                [VirtuosoAsset assetWithAssetID:[item objectForKey:@"assetID"]
                                    description:itemDescription
                                         mpdUrl:[item objectForKey:@"downloadURL"]
                                 protectionType:[[item objectForKey:@"protectionType"]intValue]
                            maximumVideoBitrate:([[item objectForKey:@"maximumBitrate"]longLongValue]>=0)?[[item objectForKey:@"maximumBitrate"]longLongValue]:INT_MAX
                            maximumAudioBitrate:([[item objectForKey:@"maximumAudioBitrate"]longLongValue]>=0)?[[item objectForKey:@"maximumAudioBitrate"]longLongValue]:INT_MAX
                                    publishDate:([item objectForKey:@"publishDelay"]!=nil)?[NSDate dateWithTimeIntervalSinceNow:[[item objectForKey:@"publishDelay"]doubleValue]]:nil
                                     expiryDate:([item objectForKey:@"expiryDelay"]!=nil)?[NSDate dateWithTimeIntervalSinceNow:[[item objectForKey:@"expiryDelay"]doubleValue]]:nil
                            expiryAfterDownload:([item objectForKey:@"eadDelay"]!=nil)?[[item objectForKey:@"eadDelay"]doubleValue]:kInvalidExpiryTimeInterval
                                expiryAfterPlay:([item objectForKey:@"eapDelay"]!=nil)?[[item objectForKey:@"eapDelay"]doubleValue]:kInvalidExpiryTimeInterval
                                 enableFastPlay:NO
                                       userInfo:[item objectForKey:@"userInfo"]
                             onReadyForDownload:^(VirtuosoAsset *parsedAsset)
                             {
                                 NSLog(@"Item is ready for download: %@",itemDescription);
                                 [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                     [self handleError:error];
                                 }];
                             }
                             onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error)
                             {
                                 NSLog(@"Finished parsing %@", itemDescription);
                                 if( error != nil )
                                 {
                                     NSLog(@"Detected error creating new asset: %@",error);
                                     [self handleError:error];
                                 }
                             }
                ];
                addCount++;
            }
            break;

            default:
            break;
        }
        return;
    }
    else
    {
        NSInteger section = indexPath.section;
        section -= self.catalog.allKeys.count;
        
        switch (section)
        {
            case 0:
            {
                // All of these options are various error modes for test and example purposes.
                switch (indexPath.item)
                {
                    case 0:
                    {
                        [VirtuosoAsset assetWithRemoteURL:@"http://www.pressnells.net/dead.mp4"
                                                  assetID:@"DeadLink"
                                              description:@"File with 404 Error"
                                              publishDate:nil
                                               expiryDate:nil
                                           enableFastPlay:NO
                                                 userInfo:nil
                                       onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                           [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                               [self handleError:error];
                                           }];
                                       }
                                          onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error) {
                                              if( error != nil )
                                              {
                                                  NSLog(@"Detected error creating new asset: %@",error);
                                                  [self handleError:error];
                                              }
                                          }];
                    }
                        break;
                        
                    case 1:
                    {
                        [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/Pirates_Booty_21-May-2012_11-00-00_GMT_BadMime.mp4"
                                                  assetID:@"InvalidMime"
                                              description:@"File With Invalid Mime"
                                              publishDate:nil
                                               expiryDate:nil
                                           enableFastPlay:NO
                                                 userInfo:nil
                                       onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                           [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                               [self handleError:error];
                                           }];
                                       }
                                          onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error) {
                                              if( error != nil )
                                              {
                                                  NSLog(@"Detected error creating new asset: %@",error);
                                                  [self handleError:error];
                                              }
                                          }];
                    }
                        break;
                        
                    case 2:
                    {
                        [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/Pirates_Booty_21-May-2012_11-00-00_GMT.mp4"
                                                  assetID:@"DeadFile"
                                              description:@"File Exceeding Max Errors + Loops"
                                              publishDate:nil
                                               expiryDate:nil
                                           enableFastPlay:NO
                                                 userInfo:nil
                                       onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                           
                                           [parsedAsset _setDownloadRetryCount:4];
                                           [parsedAsset _setError:kVDE_DownloadNetworkError];
                                           [parsedAsset _setMaximumRetriesExceeded:YES];
                                           [parsedAsset save];
                                           
                                           [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                               [self handleError:error];
                                           }];
                                       }
                                          onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error) {
                                              if( error != nil )
                                              {
                                                  NSLog(@"Detected error creating new asset: %@",error);
                                                  [self handleError:error];
                                              }
                                          }];
                    }
                        break;
                        
                    case 3:
                    {
                        [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/Pirates_Booty_21-May-2012_11-00-00_GMT.mp4"
                                                  assetID:@"ErroredFile"
                                              description:@"File With Some Pre-Errors"
                                              publishDate:nil
                                               expiryDate:nil
                                           enableFastPlay:NO
                                                 userInfo:nil
                                       onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                           [parsedAsset _setDownloadRetryCount:1];
                                           [parsedAsset _setError:kVDE_DownloadNetworkError];
                                           [parsedAsset _setMaximumRetriesExceeded:NO];
                                           [parsedAsset save];
                                           
                                           [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                               [self handleError:error];
                                           }];
                                       }
                                          onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error)
                         {
                             if( error != nil )
                             {
                                 NSLog(@"Detected error creating new asset: %@",error);
                                 [self handleError:error];
                             }
                         }];
                    }
                        break;
                        
                    case 4:
                    {
                        [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/Pirates_Booty_21-May-2012_11-00-00_GMT.mp4"
                                                  assetID:@"PublishDate"
                                              description:@"File With Publish Date Now + 5m"
                                              publishDate:[NSDate dateWithTimeIntervalSinceNow:5.0*60.0]
                                               expiryDate:nil
                                           enableFastPlay:NO
                                                 userInfo:nil
                                       onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                           [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                               [self handleError:error];
                                           }];
                                       }
                                          onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error)
                         {
                             if( error != nil )
                             {
                                 NSLog(@"Detected error creating new asset: %@",error);
                                 [self handleError:error];
                             }
                         }];
                    }
                        break;
                        
                    case 5:
                    {
                        [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/Pirates_Booty_21-May-2012_11-00-00_GMT.mp4"
                                                  assetID:@"ExpiryDate"
                                              description:@"File With Expiry Date Now + 5m"
                                              publishDate:nil
                                               expiryDate:[NSDate dateWithTimeIntervalSinceNow:5.0*60.0]
                                           enableFastPlay:NO
                                                 userInfo:nil
                                       onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                           [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                               [self handleError:error];
                                           }];
                                       }
                                          onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error)
                         {
                             if( error != nil )
                             {
                                 NSLog(@"Detected error creating new asset: %@",error);
                                 [self handleError:error];
                             }
                         }];
                    }
                        break;
                        
                    case 6:
                    {
                        [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/Pirates_Booty_21-May-2012_11-00-00_GMT.mp4"
                                                  assetID:@"ExpiryAfterDownload"
                                              description:@"File With Expiry After Download = 5m"
                                              publishDate:nil
                                               expiryDate:nil
                                      expiryAfterDownload:5.0*60.0
                                          expiryAfterPlay:0.0
                                           enableFastPlay:NO
                                                 userInfo:nil
                                       onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                           [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                               [self handleError:error];
                                           }];
                                       }
                                          onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error)
                         {
                             if( error != nil )
                             {
                                 NSLog(@"Detected error creating new asset: %@",error);
                                 [self handleError:error];
                             }
                         }];
                    }
                        break;
                        
                    case 7:
                    {
                        [VirtuosoAsset assetWithRemoteURL:@"http://hls-vbcp.s3.amazonaws.com/testmp4s/Pirates_Booty_21-May-2012_11-00-00_GMT.mp4"
                                                  assetID:@"ExpiryAfterPlay"
                                              description:@"File With Expiry After Play = 5m"
                                              publishDate:nil
                                               expiryDate:nil
                                      expiryAfterDownload:0.0
                                          expiryAfterPlay:5.0*60.0
                                           enableFastPlay:NO
                                                 userInfo:nil
                                       onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                           [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                               [self handleError:error];
                                           }];
                                       }
                                          onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error)
                         {
                             if( error != nil )
                             {
                                 NSLog(@"Detected error creating new asset: %@",error);
                                 [self handleError:error];
                             }
                         }];
                    }
                        break;
                        
                    case 8:
                    {
                        [VirtuosoAsset assetWithAssetID:@"IRONMAN2SHORT1"
                                            description:@"HLS File With Expiry Date Now + 5m"
                                            manifestUrl:@"http://hls-vbcp.s3.amazonaws.com/normal/1200/im2_short_1.m3u8"
                                         protectionType:kVDE_AssetProtectionTypePassthrough
                                  includeEncryptionKeys:YES
                                         maximumBitrate:INT_MAX
                                            publishDate:nil
                                             expiryDate:[NSDate dateWithTimeIntervalSinceNow:5.0*60.0]
                                         enableFastPlay:NO
                                               userInfo:nil
                                     onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                         NSLog(@"Finished parsing manifest.");
                                         [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                             [self handleError:error];
                                         }];
                                     }
                                        onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error) {
                                            if( error != nil )
                                            {
                                                NSLog(@"Detected error creating new asset: %@",error);
                                                [self handleError:error];
                                            }
                                        }];
                        
                    }
                        break;
                        
                    case 9:
                    {
                        [VirtuosoAsset assetWithAssetID:@"BROKEN_MIDDLE"
                                            description:@"File with broken download in middle"
                                            manifestUrl:@"http://hls-vbcp.s3.amazonaws.com/normal/1200/httyd_rel_broken.m3u8"
                                         protectionType:kVDE_AssetProtectionTypePassthrough
                                  includeEncryptionKeys:YES
                                         maximumBitrate:INT_MAX
                                            publishDate:nil
                                             expiryDate:nil
                                         enableFastPlay:NO
                                               userInfo:nil
                                     onReadyForDownload:^(VirtuosoAsset *parsedAsset) {
                                         NSLog(@"Finished parsing manifest.");
                                         [[VirtuosoDownloadEngine instance] addToQueue:parsedAsset atIndex:NSUIntegerMax onComplete:^(VirtuosoAsset *asset, NSError *error) {
                                             [self handleError:error];
                                         }];
                                     }
                                        onParseComplete:^(VirtuosoAsset *parsedAsset,NSError* error) {
                                            if( error != nil )
                                            {
                                                NSLog(@"Detected error creating new asset: %@",error);
                                                [self handleError:error];
                                            }
                                        }];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
        }
    }
}

@end
