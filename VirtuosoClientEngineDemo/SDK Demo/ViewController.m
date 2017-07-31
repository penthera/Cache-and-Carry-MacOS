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

#import "ViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import <VirtuosoClientSubscriptionManager/VirtuosoSubscriptionManager.h>
#import "AssetCollectionViewItem.h"
#import "AssetGroupHeader.h"
#import "LoginViewController.h"
#import "AppDelegate.h"

@interface ViewController()
{
    NSMutableArray* obs;
}

/*
 * For performance reasons, we keep the latest lists of pending and complete assets stored
 * in locally sorted arrays, and when we receive updates/notifications from the SDK, we update
 * these local copies appropriately.  
 */
@property (nonatomic,strong) NSMutableArray* pendingAssets;
@property (nonatomic,strong) NSMutableArray* completedAssets;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    obs = [NSMutableArray array];
   
    /*
     * Basic UI setup for the collection view.
     */
    [self.collectionView registerClass:[AssetCollectionViewItem class] forItemWithIdentifier:@"AssetCollectionViewItem"];
    [self.collectionView registerClass:[AssetGroupHeader class]
            forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader
                        withIdentifier:@"AssetGroupHeader"];
    [self reloadData];
    
    /*
     * This notice is sent from the demo app when the user chooses to logout.  In response, this view clears login 
     * states and presents the login view controller again.
     */
    id<NSObject> _obs = [[NSNotificationCenter defaultCenter] addObserverForName:@"DidLogout"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      
                                                      if( ![note.userInfo[@"FromUnregister"]boolValue] )
                                                      {
                                                          [self reloadData];
                                                          AppDelegate* del = (AppDelegate*)[NSApp delegate];
                                                          del.lastUser = nil;
                                                          LoginViewController* loginVC = [self.storyboard instantiateControllerWithIdentifier:@"Login"];
                                                          [self presentViewControllerAsSheet:loginVC];
                                                      }
                                                  }];
    [obs addObject:_obs];

    /*
     *  Called whenever the Backplane finishes syncing.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneSyncResultNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                                                           // If the backplane had forced delete items, then we need to reload data.
                                                           [self reloadData];
                                                       }];
    [obs addObject:_obs];
    
    /*
     *  Called whenever the Backplane deletes assets
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneAssetDeletedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                                                           // If the backplane had forced delete items, then we need to reload data.
                                                           [self reloadData];
                                                       }];
    [obs addObject:_obs];
    
    /*
     *  Called whenever assets get reset for expiry
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidResetExpiredAssetsNotification
                                                             object:nil
                                                              queue:[NSOperationQueue mainQueue]
                                                         usingBlock:^(NSNotification * _Nonnull note) {
                                                             [self reloadData];
                                                         }];

    /*
     *  Called whenever the Engine starts downloading a VirtuosoAsset object.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidStartDownloadingAssetNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      NSLog(@"Download engine started downloading asset: %@",asset.description);
                                                      
                                                      // Update the asset row to contain the new data.
                                                      [self updateRowForAsset:asset];
                                                      
                                                      // In this demo, we fire off local notices so the Caller can see what's going on in the
                                                      // background if the application has been minimized. This is for informational and test
                                                      // purposes only.  It's up to you to determine how and when to notify the user.  The SDK
                                                      // will never post notifications automatically.
                                                      NSUserNotification* notice = [[NSUserNotification alloc] init];
                                                      notice.title = @"Download Started";
                                                      notice.informativeText = [NSString stringWithFormat:@"Download engine reported asset downloading(%@)",asset!=nil?asset.description:@"None"];
                                                      notice.soundName = NSUserNotificationDefaultSoundName;
                                                      [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notice];
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  Called whenever the Engine reports progress for a VirtuosoAsset object
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineProgressUpdatedForAssetNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      
                                                      NSLog(@"Download engine reported download progress for asset: %f",asset.fractionComplete);
                                                      [self updateRowForAsset:asset];
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  Called when internal logic changes queue order.  All we need to do is refresh the tables.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineInternalQueueUpdateNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Download engine reported queue update.");
                                                      [self reloadData];
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  Called whenever the Engine reports a VirtuosoAsset as complete
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidFinishDownloadingAssetNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      NSLog(@"Download engine reported download complete: %@",asset.description);
                                                      
                                                      // In this case we reload the entire table to update all the other asset row positions and
                                                      // update the section counts.  A smoother UI might do all this separately in order to
                                                      // show some slick animations for content updates, but in this basic demo, we'll just
                                                      // refresh it all directly.
                                                      [self reloadData];

                                                      // In this demo, we fire off local notices so the Caller can see what's going on in the
                                                      // background if the application has been minimized. This is for informational and test
                                                      // purposes only.  It's up to you to determine how and when to notify the user.  The SDK
                                                      // will never post notifications automatically.
                                                      NSUserNotification* notice = [[NSUserNotification alloc] init];
                                                      notice.title = @"Download Completed";
                                                      notice.informativeText = [NSString stringWithFormat:@"Download engine reported asset complete (%@)",asset!=nil?asset.description:@"None"];
                                                      notice.soundName = NSUserNotificationDefaultSoundName;
                                                      [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notice];
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  Called whenever the Engine encounters a recoverable issue.  These are events that MAY be of concern to the Caller, but the Engine will continue
     *  the download process without intervention.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidEncounterWarningNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSError* error = [note.userInfo objectForKey:kDownloadEngineNotificationErrorKey];
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      
                                                      NSLog(@"Download engine encountered warning (%@) downloading asset (%@)",[error localizedDescription],asset.description);
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  Called whenever the Engine encounters an error that it cannot recover from.  This type of error will cause the engine to retry 
     *  download of the file.  If too many errors are encountered, the Engine will move on to the next item in the queue.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidEncounterErrorNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSError* error = [note.userInfo objectForKey:kDownloadEngineNotificationErrorKey];
                                                      VirtuosoAsset* asset = [note.userInfo objectForKey:kDownloadEngineNotificationAssetKey];
                                                      NSLog(@"Download error in asset(%@): %@",asset.description,[error localizedDescription]);
                                                      
                                                      [self reloadData];
                                                  }];
    [obs addObject:_obs];

    /*
     *  The Subscription Manager may auto-delete assets that exceed the maximum items per feed.  If you are maintaining your own metadata and
     *  are linking the VirtuosoAsset UUID values to your own metadata, then you should update your bookeeping here.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kSubscriptionManagerAssetDeletedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSArray* deletedAssetUUIDs = [note.userInfo objectForKey:kSubscriptionManagerNotificationVirtuosoAssetUUIDsKey];
                                                      
                                                      // If linking UUID to local metadata, delete the asset in our own bookeeping here.
                                                      NSLog(@"Detected deletion of subscription-based assets with UUIDs: %@",deletedAssetUUIDs);
                                                      
                                                      [self reloadData];
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  The Backplane issued a remote kill request.  The SDK will have reverted back to an uninitialized state and we must call the startup 
     *  method again.  In this demo, we query the User for the Group and User to use, so we're going to revert ourselves back to startup 
     *  state and ask for those values again, before calling startup.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneRemoteKillNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self reloadData];
                                                      AppDelegate* del = (AppDelegate*)[NSApp delegate];
                                                      del.lastUser = nil;
                                                      [del updateEngineEnabledState];
                                                      LoginViewController* loginVC = [self.storyboard instantiateControllerWithIdentifier:@"Login"];
                                                      [self presentViewControllerAsSheet:loginVC];
                                                  }];
    [obs addObject:_obs];

    /*
     * When the Backplane notifies us that our device was unregistered, treat it like a remote wipe request.  The unregister action will already have cleared
     * out all the SDK state, so we just need to reset and ask for credentials again.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneDidUnregisterDeviceNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self reloadData];
                                                      AppDelegate* del = (AppDelegate*)[NSApp delegate];
                                                      del.lastUser = nil;
                                                      [del updateEngineEnabledState];
                                                      LoginViewController* loginVC = [self.storyboard instantiateControllerWithIdentifier:@"Login"];
                                                      [self presentViewControllerAsSheet:loginVC];
                                                  }];
    [obs addObject:_obs];

    /*
     *  When the Subscription Manager adds new assets, we need to refresh the views, so the new assets get shown
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kSubscriptionManagerAssetAddedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self reloadData];
                                                  }];
    [obs addObject:_obs];

    /*
     * Notice sent by the demo app when an asset has been deleted.  In this demo, we'll just refresh the collection view.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:@"AssetDeleted"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self reloadData];
                                                  }];
    [obs addObject:_obs];
}

/*
 * Called when the user chooses to logout
 */
- (void)logout:(id)sender
{
    /*
     * This particular demo use case shows how to use the shutdown method.  When the shutdown method is called,
     * the SDK is put into an "unauthenticated" mode, and the system will behave as if the startup methods were
     * never called.  This state continues until you call the startupWithBackplane method to login a new user.
     *
     * If the newly logged in user is the same as the previously logged in user, then the SDK continues from 
     * where it left off before shutdown.  If the new user is different than the previous user, then the SDK 
     * resets its internal state and deletes all download assets, similar to the behavior if you had called 
     * the device unregister method.
     */
    [[VirtuosoDownloadEngine instance] shutdown];
    
    /* 
     * Reload the collection view data.  In an unauthenticated state, this will result in an empty view.
     */
    [self reloadData];
    
    /*
     * Clear user state and show the login dialog
     */
    AppDelegate* del = (AppDelegate*)[NSApp delegate];
    del.lastUser = nil;
    [del updateEngineEnabledState];
    LoginViewController* loginVC = [self.storyboard instantiateControllerWithIdentifier:@"Login"];
    [self presentViewControllerAsSheet:loginVC];
}

/*
 * Convenience method to move an asset up in the queue.  Assets at the top of the queue are 
 * downloaded before assets that are lower in the queue.
 */
- (void)moveUpAsset:(VirtuosoAsset*)asset atIndexPath:(NSIndexPath*)indexPath
{
    NSArray* queue = [VirtuosoDownloadEngine instance].assetsInQueue;
    NSUInteger pos = [queue indexOfObject:asset.uuid];
    if( pos > 0 )
    {
        pos--;
        
        [[VirtuosoDownloadEngine instance] moveAsset:asset inQueueToIndex:pos];
        [self reloadData];
    }
}

/*
 * Convenience method to move an asset down in the queue.  Assets at the top of the queue are
 * downloaded before assets that are lower in the queue.
 */
- (void)moveDownAsset:(VirtuosoAsset*)asset atIndexPath:(NSIndexPath*)indexPath
{
    NSArray* queue = [VirtuosoDownloadEngine instance].assetsInQueue;
    NSUInteger pos = [queue indexOfObject:asset.uuid];
    if( pos < self.pendingAssets.count-1 )
    {
        pos++;
    
        [[VirtuosoDownloadEngine instance] moveAsset:asset inQueueToIndex:pos];
        [self reloadData];
    }
}

/*
 * This method is called when an asset has been updated.  The asset passed to this
 * method is an updated copy of the asset.  This method needs to identify the row that
 * needs updating, and update the UI.
 */
- (void)updateRowForAsset:(VirtuosoAsset*)asset
{
   /*
    * Find the asset, if it's in the pending assets section, and update the locally
    * cached object.
    */
    NSInteger updatedSection = -1;
    NSInteger updatedRow = -1;
    for( int i = 0; i < self.pendingAssets.count; i++ )
    {
        VirtuosoAsset* test = self.pendingAssets[i];
        if( [test.uuid isEqualToString:asset.uuid] )
        {
            self.pendingAssets[i] = asset;
            updatedRow = i;
            updatedSection = 0;
            break;
        }
    }
    
    /*
     * Find the asset, if it's in the completed assets section, and update the locally
     * cached object.
     */
    for( int i = 0; i< self.completedAssets.count; i++ )
    {
        VirtuosoAsset* test = self.completedAssets[i];
        if( [test.uuid isEqualToString:asset.uuid] )
        {
            self.completedAssets[i] = asset;
            updatedRow = i;
            updatedSection = 1;
            break;
        }
    }
    
    /*
     * If we found the asset in our lists, then the updatedSection and updatedRow variables will be set.
     * In that case, we know the index path to update.  Tell the collection view to reload just that indexPath.
     * If something went wrong, then reload the whole collection view, so make sure we're caught up with SDK
     * state.
     */
    if( updatedRow >= 0 && updatedSection >= 0 )
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:updatedRow inSection:updatedSection];
        [self.collectionView reloadItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
    }
    else
    {
        [self reloadData];
    }
}

- (void)viewDidAppear
{
    /*
     * Calling reloadData before the SDK starts up sets up the data structures and shows a blank screen.
     */
    [self reloadData];
    
    /*
     * Now, if there's no previously stored user, show the login screen.  If we already have a stored user,
     * then startup the SDK with that user.
     */
    AppDelegate* del = (AppDelegate*)[NSApp delegate];
    
    if( del.lastUser.length == 0 )
    {
        LoginViewController* loginVC = [self.storyboard instantiateControllerWithIdentifier:@"Login"];
        [self presentViewControllerAsSheet:loginVC];
    }
    else
    {
        /*
         * Startup the SDK with the stored user.
         */
        [del loginToBackplaneWithUser:del.lastUser];
        
        /*
         * Register for remote notifications here.  We only want to register for notifications after we've started the SDK,
         * so that when we get the push token, we can assign the push token to the SDK and associate the token with the 
         * device in the backplane.
         */
        [NSApp registerForRemoteNotificationTypes:(NSRemoteNotificationTypeBadge |NSRemoteNotificationTypeAlert | NSRemoteNotificationTypeSound)];
        
        // We've started up the SDK now, so we should refresh to get any existing assets shown as early as possible.
        [self reloadData];
    }
}

- (void)reloadData
{
    /*
     * If we've started the engine, then get the pending and completed asset lists from the SDK.  These
     * helper methods will provide the appropriate assets for each, properly sorted for most uses.
     * If the engine hasn't started, invalidate our local data cache, which will show an empty screen.
     */
    if( [[VirtuosoDownloadEngine instance]started] )
    {
        self.pendingAssets = [[VirtuosoAsset pendingAssetsWithAvailabilityFilter:NO]mutableCopy];
        self.completedAssets = [[VirtuosoAsset completedAssetsWithAvailabilityFilter:NO]mutableCopy];
    }
    else
    {
        self.pendingAssets = nil;
        self.completedAssets = nil;
    }
    [self.collectionView reloadData];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    /*
     * For this demo app, we only have 2 sections.  The top section is for assets that haven't
     * downloaded yet (pending assets), and the bottom section is for assets that have
     * finished downloading.
     */
    return 2;
}

- (NSView*)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    AssetGroupHeader* header = [collectionView makeSupplementaryViewOfKind:kind withIdentifier:@"AssetGroupHeader" forIndexPath:indexPath];
    if( indexPath.section == 0 )
        header.label.stringValue = @"Pending Assets";
    else
        header.label.stringValue = @"Complete Assets";
    return header;
}

/* 
 * Asks the data source for the number of items in the specified section.
 */
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if( section == 0 )
        return _pendingAssets.count;
    return _completedAssets.count;
}

/*
 * In this basic demo, we don't support dragging.
 */
- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event
{
    return NO;
}

/* Asks the data source to provide an NSCollectionViewItem for the specified represented object.
 *
 * Your implementation of this method is responsible for creating, configuring, and returning the
 * appropriate item for the given represented object.  You do this by sending -makeItemWithIdentifier:forIndexPath: 
 * method to the collection view and passing the identifier that corresponds to the item type you want.  Upon 
 * receiving the item, you should set any properties that correspond to the data of the corresponding model object, 
 * perform any additional needed configuration, and return the item.
 *
 * You do not need to set the location of the item's view inside the collection view’s bounds. The collection 
 * view sets the location of each item automatically using the layout attributes provided by its layout object.
 *
 * This method must always return a valid item instance.
 */
- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    AssetCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"AssetCollectionViewItem"
                                                                forIndexPath:indexPath];
    
    /*
     * The item needs to know the indexPath it's currently representing, so that when "move up" or "move down" events are called, 
     * the item knows how to tell us which item we're moving.
     */
    item.indexPath = indexPath;
    
    /*
     * We pass the storyboard in so that we can properly instantiate views and play the asset when requested.
     */
    item.mainStoryboard = self.storyboard;
    
    /*
     * We tell the item who to call for button clicks events.
     */
    item.parent = self;
    
    /*
     * And we set the asset that this item will represent in the UI.  The AssetCollectionViewItem will handle
     * UI layout and structuring itself.
     */
    if( indexPath.section == 0 )
        item.asset = [_pendingAssets objectAtIndex:indexPath.item];
    else
        item.asset = [_completedAssets objectAtIndex:indexPath.item];
    
    [item viewWillAppear];
    
    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView willDisplayItem:(AssetCollectionViewItem *)item forRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    /* 
     * This method is called when the AssetCollectionViewItem is about to be displayed.  In this demo, we alternate
     * the background color of the rows, so we can easily separate items visually.  We also make sure to update the 
     * item's local properties, so make sure it's ready for display.  
     */
    if( indexPath.item%2 == 0 )
        item.view.layer.backgroundColor = [NSColor colorWithWhite:0.95 alpha:1].CGColor;
    else
        item.view.layer.backgroundColor = [NSColor colorWithWhite:0.9 alpha:1].CGColor;
    
    item.indexPath = indexPath;
    item.mainStoryboard = self.storyboard;
    item.parent = self;
    if( indexPath.section == 0 )
        item.asset = [_pendingAssets objectAtIndex:indexPath.item];
    else
        item.asset = [_completedAssets objectAtIndex:indexPath.item];
    
    [item viewWillAppear];
}

- (void)dealloc
{
    for( id<NSObject> _obs in obs )
        [[NSNotificationCenter defaultCenter] removeObserver:_obs];
}

@end
