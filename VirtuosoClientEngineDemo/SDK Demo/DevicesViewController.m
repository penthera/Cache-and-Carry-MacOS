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

#import "DevicesViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import "DevicesCollectionViewItem.h"

@interface DevicesViewController ()
{
    NSMutableArray* devices;
    NSMutableArray* obs;
}
@end

@implementation DevicesViewController

- (void)didUpdateDevice:(VirtuosoDevice *)device
{
    /*
     * This may have come in on a background thread, so we'll dispatch the update to the main thread for UI updates.
     *
     * This is a simple demo, so to handle the update, we'll just get a fresh list of the devices, sort them to the
     * current device is on top, and refresh the view.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger previousCount = devices.count;
        devices = [[VirtuosoDownloadEngine instance].devices mutableCopy];
        [devices sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"isThisDevice" ascending:NO],
                                        [NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES]]];
        if( previousCount != devices.count )
            [self.collectionView reloadData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.wantsLayer = true;
    obs = [NSMutableArray array];
    
    /*
     * Standard UI setup
     */
    [self.collectionView registerClass:[DevicesCollectionViewItem class] forItemWithIdentifier:@"DevicesCollectionViewItem"];
    
    /*
     * Get the current device list, sort so the current device is on top.
     */
    devices = [[VirtuosoDownloadEngine instance].devices mutableCopy];
    [devices sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"isThisDevice" ascending:NO],
                                    [NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES]]];
    
    /*
     * Register for the logout notice sent from this app, so we can close our window if the user logs out.
     */
    id<NSObject> _obs = [[NSNotificationCenter defaultCenter] addObserverForName:@"DidLogout"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self dismissController:self];
                                                  }];
    [obs addObject:_obs];
    
    /*
     * Register for the backplane sync result notice from the SDK. 
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneSyncResultNotification
                                                             object:nil
                                                              queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                                                                  
                                                                  /*
                                                                   * If the sync was a success, but the engine instance is no longer started, then we
                                                                   * processed an unregister for this device or a logout for this device.  In both cases,
                                                                   * close the device list, as it's no longer valid.  
                                                                   *
                                                                   * If the engine is started, then reload the device list.
                                                                   */
                                                                  if( [[note.userInfo objectForKey:kDownloadEngineNotificationSuccessValueKey]boolValue] &&
                                                                     ![VirtuosoDownloadEngine instance].started )
                                                                  {
                                                                      [self dismissController:self];
                                                                  }
                                                                  else if( [VirtuosoDownloadEngine instance].started )
                                                                  {
                                                                      devices = [[VirtuosoDownloadEngine instance].devices mutableCopy];
                                                                      [devices sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"isThisDevice" ascending:NO],
                                                                                                      [NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES]]];
                                                                      [self.collectionView reloadData];
                                                                  }
                                                              }];
    [obs addObject:_obs];

}

- (void)didDeleteDevice:(VirtuosoDevice*)device
{
    [devices removeObject:device];
    [self.collectionView reloadData];
}

- (void)dealloc
{
    for( id<NSObject> _obs in obs )
        [[NSNotificationCenter defaultCenter] removeObserver:_obs];
}

/* Asks the data source for the number of items in the specified section.
 */
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return devices.count;
}

/* Asks the data source to provide an NSCollectionViewItem for the specified represented object.
 
 Your implementation of this method is responsible for creating, configuring, and returning the appropriate item for the given represented object.  You do this by sending -makeItemWithIdentifier:forIndexPath: method to the collection view and passing the identifier that corresponds to the item type you want.  Upon receiving the item, you should set any properties that correspond to the data of the corresponding model object, perform any additional needed configuration, and return the item.
 
 You do not need to set the location of the item's view inside the collection view’s bounds. The collection view sets the location of each item automatically using the layout attributes provided by its layout object.
 
 This method must always return a valid item instance.
 */
- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    DevicesCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"DevicesCollectionViewItem"
                                                                forIndexPath:indexPath];
    
    item.device = [devices objectAtIndex:indexPath.item];
    item.parent = self;
    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView willDisplayItem:(DevicesCollectionViewItem *)item forRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.item%2 == 0 )
        item.view.layer.backgroundColor = [NSColor colorWithWhite:0.95 alpha:1].CGColor;
    else
        item.view.layer.backgroundColor = [NSColor colorWithWhite:0.9 alpha:1].CGColor;
    
    item.device = [devices objectAtIndex:indexPath.item];
    item.parent = self;
    [item viewWillAppear];
}

@end
