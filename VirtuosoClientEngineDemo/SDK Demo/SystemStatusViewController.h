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
 * The System Status view is a basic status screen that is used to monitor the 
 * state of the download engine.  This is a basic implementation for demonstration
 * purposes only.
 */
@interface SystemStatusViewController : NSViewController

@property (nonatomic,readonly) NSString* engineStatus;
@property (nonatomic,readonly) NSString* networkStatus;
@property (nonatomic,readonly) NSString* storageStatus;
@property (nonatomic,readonly) NSString* queueStatus;
@property (nonatomic,readonly) NSString* accountStatus;
@property (nonatomic,readonly) NSString* authenticationStatus;
@property (nonatomic,readonly) NSString* maxDevices;
@property (nonatomic,readonly) NSString* currentDevices;
@property (nonatomic,readonly) NSString* secureTime;
@property (nonatomic,readonly) NSString* licenseExpires;
@property (nonatomic,readonly) NSString* diskSpaceUsed;
@property (nonatomic,readonly) NSString* downloadBandwidth;

@end
