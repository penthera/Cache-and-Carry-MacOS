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

#import "PerformancePreferencesViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>

@interface PerformancePreferencesViewController ()

@end

@implementation PerformancePreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (Boolean)useClientCert
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UseClientSSL"];
}

- (void)setUseClientCert:(Boolean)useClientCert
{
    [[NSUserDefaults standardUserDefaults] setBool:useClientCert forKey:@"UseClientSSL"];
    if( useClientCert )
    {
        [VirtuosoSettings instance].clientSSLCertificatePath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
        [VirtuosoSettings instance].clientSSLCertificatePassword = @"p3nth3ra";
    }
    else
    {
        // Reset this just in case it was saved from some previous session.  Not strictly needed, but safer to be explicit.
        [VirtuosoSettings instance].clientSSLCertificatePath = nil;
        [VirtuosoSettings instance].clientSSLCertificatePassword = nil;
    }
}

- (NSString*)maxHTTPConnections
{
    return [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"VFM_MaxHTTPConn"]];
}

- (void)setMaxHTTPConnections:(NSString *)maxHTTPConnections
{
    [[NSUserDefaults standardUserDefaults] setInteger:[maxHTTPConnections integerValue] forKey:@"VFM_MaxHTTPConn"];
}

- (NSString*)taskRefillLimit
{
    NSInteger taskRefillLimit = [[NSUserDefaults standardUserDefaults] integerForKey:@"VFM_TaskRefillLimit"];
    if( taskRefillLimit <= 0 )
    taskRefillLimit = 10;

    return [NSString stringWithFormat:@"%ld",(long)taskRefillLimit];
}

- (void)setTaskRefillLimit:(NSString *)taskRefillLimit
{
    [[NSUserDefaults standardUserDefaults] setInteger:[taskRefillLimit integerValue] forKey:@"VFM_TaskRefillLimit"];
}

- (NSString*)taskRefillSize
{
    NSInteger taskRefillSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"VFM_TaskRefillSize"];
    if( taskRefillSize <= 0 )
    taskRefillSize = 40;

    return [NSString stringWithFormat:@"%ld",(long)taskRefillSize];
}

- (void)setTaskRefillSize:(NSString *)taskRefillSize
{
    [[NSUserDefaults standardUserDefaults] setInteger:[taskRefillSize integerValue] forKey:@"VFM_TaskRefillSize"];
}

- (Boolean)sendHTTP404WithProxy
{
    return [VirtuosoSettings instance].sendHTTPErrorForErroredSegments;
}

- (void)setSendHTTP404WithProxy:(Boolean)sendHTTP404WithProxy
{
    [VirtuosoSettings instance].sendHTTPErrorForErroredSegments = sendHTTP404WithProxy;
}

- (NSString*)permittedSegmentErrors
{
    return [NSString stringWithFormat:@"%ld",(long)[VirtuosoSettings instance].permittedSegmentDownloadErrors];
}

- (void)setPermittedSegmentErrors:(NSString *)permittedSegmentErrors
{
    [VirtuosoSettings instance].permittedSegmentDownloadErrors = [permittedSegmentErrors integerValue];
}


@end
