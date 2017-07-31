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
 * This view controller is presented whenever a stored user session does not exist.  Its function is to
 * modally request that the user sign in.  Normally, user authentication and session persistence will be 
 * handled by your own authentication functions.  In this demo, we simply request the user name from the 
 * user.
 */
@interface LoginViewController : NSViewController

@property (nonatomic,strong) IBOutlet NSTextField* user;

- (IBAction)doCancel:(id)sender;
- (IBAction)doLogin:(id)sender;

@end
