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

/*
 * The subscriptions pane demonstrates how to interact with subscriptions.  The options
 * in this view allow you to subscribe and unsubscribe from feeds, and to force a manual
 * sync with the subscriptions system.
 */
@interface SubscriptionPreferencesViewController : NSViewController

@property (nonatomic,strong) NSString* maxItemsPerFeed;
@property (nonatomic,assign) Boolean autoDeleteOldItems;

@property (nonatomic,strong) IBOutlet NSButton* testFeedSubscription;
@property (nonatomic,strong) IBOutlet NSTextField* customSubFeed;
@property (nonatomic,strong) IBOutlet NSTextField* customUnsubFeed;

- (IBAction)didChangeTestFeedSubscriptionState:(id)sender;
- (IBAction)doSubscribeToCustom:(id)sender;
- (IBAction)doUnsubscribeToCustom:(id)sender;
- (IBAction)syncWithSubscriptionServer:(id)sender;
- (IBAction)pushItemToTestFeed:(id)sender;

@end
