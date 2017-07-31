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

#import "LoginViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import "AppDelegate.h"

@interface LoginViewController ()
{
    NSMutableArray* obs;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     * Register for the backplane sync result notice.  If we successfully logged in (started the SDK), then one of these
     * notices will be sent with the backplane sync result status.  If the backplane successfully synced, then we know
     * login worked and the SDK is started up, so we can remove the login screen.
     */
    obs = [NSMutableArray array];
    id<NSObject> _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kBackplaneSyncResultNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                                                           
                                                           if( [[note.userInfo objectForKey:kDownloadEngineNotificationSuccessValueKey]boolValue] &&
                                                               [VirtuosoDownloadEngine instance].started )
                                                           {
                                                               /*
                                                                * We only register for remote notifications **after** the SDK has successfully 
                                                                * started up.  This allows us to sync the push token with the backplane properly
                                                                * and associate the push token with the device registration.
                                                                */
                                                               [NSApp registerForRemoteNotificationTypes:(NSRemoteNotificationTypeBadge |NSRemoteNotificationTypeAlert | NSRemoteNotificationTypeSound)];
                                                               
                                                               /*
                                                                * Store the registered user, so we can startup without login in the future.
                                                                */
                                                               AppDelegate* del = (AppDelegate*)[NSApp delegate];
                                                               del.lastUser = self.user.stringValue;
                                                               
                                                               /*
                                                                * Remove the login screen.
                                                                */
                                                               [self dismissController:self];
                                                           }
                                                       }];
    [obs addObject:_obs];
}

- (IBAction)doCancel:(id)sender
{
    /*
     * For the purposes of this application, we don't allow unauthenticated users.  If the user chooses
     * not to login, exit the app. 
     */
    [self dismissController:self];
    [NSApp terminate:self];
}

- (IBAction)doLogin:(id)sender
{
    /* 
     * Don't allow login without a user value.
     */
    if( self.user.stringValue.length == 0 )
        return;
    
    /*
     * Call the common SDK startup method.  See the AppDelegate class for details.
     */
    AppDelegate* del = (AppDelegate*)[NSApp delegate];
    [del loginToBackplaneWithUser:self.user.stringValue];
}

- (void)dealloc
{
    for( id<NSObject> _obs in obs )
        [[NSNotificationCenter defaultCenter] removeObserver:_obs];
}

@end
