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

#import "SubscriptionPreferencesViewController.h"
#import <VirtuosoClientSubscriptionManager/VirtuosoSubscriptionManager.h>
#import "DJProgressHUD.h"

static NSString* TEST_FEED_ID = @"CLIENT_ADD_ITEM_TEST_FEED";

@interface SubscriptionPreferencesViewController ()

@end

/*
 * NOTE: This method is for test/demo purposes only and you should NEVER access it.
 */
@interface VirtuosoSubscriptionManager()
- (void)generatePushUpdate:(NSDictionary*)data;
@end


@implementation SubscriptionPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.testFeedSubscription.state = [self isSubscribedToFeed:TEST_FEED_ID]?NSOnState:NSOffState;
}

- (NSString*)maxItemsPerFeed
{
    return [NSString stringWithFormat:@"%ld",(long)[VirtuosoSubscriptionManager instance].maximumSubscriptionItemsPerFeed];
}

- (void)setMaxItemsPerFeed:(NSString *)maxItemsPerFeed
{
    [[VirtuosoSubscriptionManager instance] setMaximumSubscriptionItemsPerFeed:(int)[maxItemsPerFeed integerValue]];
}

- (Boolean)autoDeleteOldItems
{
    return [VirtuosoSubscriptionManager instance].autodeleteOldItems;
}

- (void)setAutoDeleteOldItems:(Boolean)autoDeleteOldItems
{
    [VirtuosoSubscriptionManager instance].autodeleteOldItems = autoDeleteOldItems;
}

- (void)subscribe:(Boolean)subscribe toFeed:(NSString*)feed fromButton:(NSButton*)button
{
    if( [VirtuosoSubscriptionManager instance] == nil )
    {
        NSAlert* alert = [[NSAlert alloc]init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"Subscriptions Disabled - Subscription Manager instance is nil."];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        return;
    }
    
    if( subscribe )
    {
        [DJProgressHUD showStatus:@"Subscribing to feed..." FromView:self.view];
        [[VirtuosoSubscriptionManager instance] registerForSubscription:feed onComplete:^(Boolean success, NSError *error) {
            [self setSubscriptionForFeed:feed subscribed:success];
            if( button )
                button.state = [self isSubscribedToFeed:feed]?NSOnState:NSOffState;
            else if( [feed isEqualToString:TEST_FEED_ID] )
                self.testFeedSubscription.state = [self isSubscribedToFeed:feed]?NSOnState:NSOffState;
            [DJProgressHUD showStatus:success?@"Success...":@"Failed..." FromView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [DJProgressHUD dismiss];
            });
        }];
    }
    else
    {
        [DJProgressHUD showStatus:@"Unsubscribing from feed..." FromView:self.view];
        [[VirtuosoSubscriptionManager instance] unregisterForSubscription:feed onComplete:^(Boolean success, NSError *error) {
            [self setSubscriptionForFeed:feed subscribed:!success];
            if( button )
                button.state = [self isSubscribedToFeed:feed]?NSOnState:NSOffState;
            else if( [feed isEqualToString:TEST_FEED_ID] )
                self.testFeedSubscription.state = [self isSubscribedToFeed:feed]?NSOnState:NSOffState;
            [DJProgressHUD showStatus:success?@"Success...":@"Failed..." FromView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [DJProgressHUD dismiss];
            });
        }];
    }
}

- (void)didChangeTestFeedSubscriptionState:(NSButton*)sender
{
    [self subscribe:(sender.state==NSOnState) toFeed:TEST_FEED_ID fromButton:sender];
}

- (void)doSubscribeToCustom:(id)sender
{
    [self subscribe:YES toFeed:self.customSubFeed.stringValue fromButton:nil];
}

- (void)doUnsubscribeToCustom:(id)sender
{
    [self subscribe:NO toFeed:self.customUnsubFeed.stringValue fromButton:nil];
}

- (void)syncWithSubscriptionServer:(id)sender
{
    if( [VirtuosoSubscriptionManager instance] == nil )
    {
        NSAlert* alert = [[NSAlert alloc]init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"Subscriptions Disabled - Subscription Manager instance is nil."];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        return;
    }

    [DJProgressHUD showStatus:@"Syncing subscriptions..." FromView:self.view];
    
    [[VirtuosoSubscriptionManager instance] syncSubscriptionsWithBackplaneNowOnComplete:^(Boolean success, NSArray *subscriptions, NSError *error) {
        [DJProgressHUD showStatus:@"Sync complete..." FromView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [DJProgressHUD dismiss];
        });
    }];    
}

- (void)pushItemToTestFeed:(id)sender
{
    if( [VirtuosoSubscriptionManager instance] == nil )
    {
        NSAlert* alert = [[NSAlert alloc]init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"Subscriptions Disabled - Subscription Manager instance is nil."];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        return;
    }

    // Append a persistently incrementing test number to these items so we can tell them apart.
    NSInteger testNum = [[NSUserDefaults standardUserDefaults]integerForKey:@"TestNum"];
    testNum++;
    [[NSUserDefaults standardUserDefaults] setInteger:testNum forKey:@"TestNum"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[VirtuosoSubscriptionManager instance] generatePushUpdate:@{@"title":[NSString stringWithFormat:@"Dilbert - Pirate's Booty: Test %li",(long)testNum],
                                                                 @"desc":@"Dilbert Test Push Item",
                                                                 @"contentSize":@(1576292),
                                                                 @"contentSizeIsEstimate":@(NO),
                                                                 @"duration":@(30),
                                                                 @"downloadURL":@"http://josh-push-test.s3.amazonaws.com/Dilbert_1000.m4v",
                                                                 @"streamURL":@"http://josh-push-test.s3.amazonaws.com/Dilbert_1000.m4v",
                                                                 @"downloadEnabled":@(YES),
                                                                 @"mediaType":@(0),
                                                                 @"contentType":@"video/x-m4v"}];
    
    [DJProgressHUD showStatus:@"New subscription item posted..." FromView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DJProgressHUD dismiss];
    });
}

- (Boolean)isSubscribedToFeed:(NSString*)feedID
{
    NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"DemoSubscriptions"];
    if( subs == nil )
        subs = [NSArray array];
    
    return [subs containsObject:feedID];
}

- (void)setSubscriptionForFeed:(NSString*)feedID subscribed:(Boolean)sub
{
    NSMutableArray* subs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DemoSubscriptions"]mutableCopy];
    if( subs == nil )
        subs = [NSMutableArray array];
    
    if( ![subs containsObject:feedID] && sub )
        [subs addObject:feedID];
    else if( !sub )
        [subs removeObject:feedID];
    
    [[NSUserDefaults standardUserDefaults] setObject:subs forKey:@"DemoSubscriptions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
