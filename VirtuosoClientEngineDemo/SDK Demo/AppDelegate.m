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

#import "AppDelegate.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

#define BACKPLANE_URL INSERT_BACKPLANE_URL_HERE
#define PRIVATE_KEY INSERT_PRIVATE_KEY_HERE
#define PUBLIC_KEY INSERT_PUBLIC_KEY_HERE

@interface AppDelegate () <NSUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /*
     *  Penthera recommends configuration all logging as early as possible in the didFinishLaunchingWithOptions method.  For the
     *  purpose of our example, we're going to setup logging to be as verbose as possible on all log output paths.  For real-world
     *  applications, you'll want to configure your own log options.
     */
    
    /* We'll track logging through the OSX Console app, which provides better filtering and export.  Turn off logging to file,
     * unless it's needed, in order to slightly improve performance. 
     */
    [VirtuosoLogger enableLogsToFile:NO];
    
    /*
     * If we've never set the log level, then initialize log level to the default VirtuosoLogger level.  Otherwise,
     * reset the VirtuosoLogger level to our previously stored settings.
     */
    if( [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedLogLevel"] == nil )
        self.logLevel = [VirtuosoLogger logLevel];
    else
        [VirtuosoLogger setLogLevel:self.logLevel];

    /*
     * Initialize the UI's enabled state using the download engine's state.
     */
    self.enableMenuItem.state = [VirtuosoDownloadEngine instance].enabled?NSOnState:NSOffState;
    
    /*
     * Setup this class as the user notification center delegate so that we can post notices
     * to the Mac OSX notification center.
     */
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

/*
 * This convenience method is called from various listeners when the download engine status changes, and
 * is used to update the menu item checkmarks for the current engine state.
 */
- (void)updateEngineEnabledState
{
    self.enableMenuItem.state = [VirtuosoDownloadEngine instance].enabled?NSOnState:NSOffState;
}

/*
 * Called when the menu item to enable/disable the engine is clicked
 */
- (IBAction)doEnableEngine:(NSMenuItem*)sender
{
    [VirtuosoDownloadEngine instance].enabled = ![VirtuosoDownloadEngine instance].enabled;
    sender.state = [VirtuosoDownloadEngine instance].enabled?NSOnState:NSOffState;
}

/*
 * Called when the menu item for force sync is clicked
 */
- (IBAction)forceSync:(id)sender
{
    [[VirtuosoDownloadEngine instance] syncWithBackplaneNow:YES];
}

/*
 * Sent from the OS after successful push notice registration.  In order for proper SDK function, you should
 * store the provided token to the VirtuosoSettings instance, in addition to any processing you need to do in
 * in your own app.
 */
- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Forward the token to your server.
    NSLog(@"Got push token: %@",deviceToken);
    [VirtuosoSettings instance].devicePushToken = [deviceToken description];
}

/*
 * Sent from the OS when push registration fails.  In order to maintain smooth operation, you should set the 
 * devicePushToken to nil, in order to clear out the token registration in the Backplane servers.
 */
- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Remote notification support is unavailable due to error: %@", error);
    [VirtuosoSettings instance].devicePushToken = nil;
}

/*
 * Sent from the OS when a push notice is received.  Following the example below, you should pass the userInfo object
 * to the VirtuosoEventHander for processing.  If the push notice is handled by the SDK, then this method will return
 * true, indicating that no further action is required on your part.  If the method returns false, then the push notice
 * was not generated by Cache & Carry, and you should process it within your own application code.
 */
- (void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary<NSString *,id> *)userInfo
{
    NSLog(@"Received notification: %@",userInfo);
    if( [VirtuosoEventHandler processRemotePushNotice:userInfo] )
    {
        NSLog(@"Notification was handled by Virtuoso.");
    }
    else
    {
        NSLog(@"Notification was not handled by Virtuoso.");
    }
}

/*
 * Called from various points in the UI to startup the Cache & Carry SDK.  This is usually done only after you have authenticated
 * the user in your own systems and can pass the known user ID to the SDK for startup.  This method must be called prior to accessing
 * any other methods in the SDK.
 */
- (void)loginToBackplaneWithUser:(NSString *)user
{
    [[VirtuosoDownloadEngine instance] startupWithBackplane:BACKPLANE_URL
                                                       user:user
                                           externalDeviceID:nil
                                                 privateKey:PRIVATE_KEY
                                                  publicKey:PUBLIC_KEY];
}

/*
 * Convenience method to return the user ID of the last user to login.  This is used in this demo to persist the user's login session
 * across restarts of the app.  In your own application code, this would be handled by your own authentication mechanisms.
 */
- (NSString*)lastUser
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUser"];
}

/*
 * Convenience method to store the user login session.
 */
- (void)setLastUser:(NSString *)lastUser
{
    if( lastUser )
        [[NSUserDefaults standardUserDefaults] setObject:lastUser forKey:@"LastUser"];
    else
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastUser"];
}

/*
 * Convenience method to return the persisted log level.
 */
- (NSUInteger)logLevel
{
    return [[NSUserDefaults standardUserDefaults]integerForKey:@"SavedLogLevel"];
}

/* 
 * Convenience method to persist the chosen log level.
 */
- (void)setLogLevel:(NSUInteger)logLevel
{
    [[NSUserDefaults standardUserDefaults] setInteger:logLevel forKey:@"SavedLogLevel"];
}

/*
 * --------------- OS Defined Configuration/Helper Methods -----------------------
 */

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end