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

@interface AppDelegate : NSObject <NSApplicationDelegate>

/*
 * Global action for the master SDK enable switch.  
 *
 * Normally you wouldn't expose this directly via UI, but we have made the option
 * available here for testing purposes.
 */
- (IBAction)doEnableEngine:(id)sender;

/*
 * Force an SDK sync immediately.
 *
 * The SDK normally syncs on a regular basis internally and as-needed.  Most of the 
 * time, this is sufficient for standard operations.  During testing, you may wish to
 * sync more frequently, and this option allows you to do so.
 */
- (IBAction)forceSync:(id)sender;

/*
 * Handle to the enable menu item to allow proper UI to indicate state.
 */
@property (nonatomic,strong) IBOutlet NSMenuItem* enableMenuItem;

/*
 * Convenience property to store user login
 *
 * The SDK does not perform any user authentication/validation.  We assume that the
 * user ID value you provide to us has already been validated in your own systems.  This
 * demo app stores the last-used user ID so that future executions of the app do not need
 * to re-request login credentials.
 */
@property (nonatomic,strong) NSString* lastUser;

/*
 * Convenience property to access the current log level in the UI.
 * This value is synced with the VirtuosoLogger log level.
 */
@property (nonatomic,assign) NSUInteger logLevel;

/*
 * Convenience method to startup the SDK from various points in the UI.
 */
- (void)loginToBackplaneWithUser:(NSString*)user;

/*
 * Called when the engine status changes to update the enabled/disabled checkmark.
 */
- (void)updateEngineEnabledState;

@end

