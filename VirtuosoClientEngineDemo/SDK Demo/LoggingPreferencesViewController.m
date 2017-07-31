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

#import "LoggingPreferencesViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import "AppDelegate.h"

@interface LoggingPreferencesViewController ()
@end

@implementation LoggingPreferencesViewController

- (NSString*)titleForLogLevel:(int)logLevel
{
    switch(logLevel)
    {
        case 0:
        return @"Error";
        case 1:
        return @"Warning";
        case 2:
        return @"Information";
        case 3:
        return @"Debug";
        case 4:
        return @"Verbose";
    }
    return @"Unknown";
}

- (int)levelForLogString:(NSString*)level
{
    if( [level isEqualToString:@"Error"] )
    return 0;
    if( [level isEqualToString:@"Warning"] )
    return 1;
    if( [level isEqualToString:@"Information"] )
    return 2;
    if( [level isEqualToString:@"Debug"] )
    return 3;
    if( [level isEqualToString:@"Verbose"] )
    return 4;
    
    return 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logLevel removeAllItems];
    [self.logLevel addItemsWithTitles:@[@"Error",@"Warning",@"Information",@"Debug",@"Verbose"]];
    [self.logLevel selectItemWithTitle:[self titleForLogLevel:[VirtuosoLogger logLevel]]];

    [self.logLevel setTarget:self];
    [self.logLevel setAction:@selector(didSelectLogLevel:)];
    
    for( int i = kVLE_AppLaunch; i <= kVLE_DownloadLimitReached; i++ )
    {
        NSButton* button = [self.view viewWithTag:i];
        [button setState:[VirtuosoLogger isLoggingEnabledForEvent:i]?NSOnState:NSOffState];
    }
}

- (void)loggingForEventUpdated:(NSButton*)sender
{
    [VirtuosoLogger setLoggingEnabled:(sender.state==NSOnState) forEvent:sender.tag];
    [sender setState:[VirtuosoLogger isLoggingEnabledForEvent:sender.tag]?NSOnState:NSOffState];
}

- (void)didSelectLogLevel:(NSPopUpButton*)sender
{
    NSInteger level = [sender indexOfSelectedItem];
    AppDelegate* del = (AppDelegate*)[NSApp delegate];
    del.logLevel = level;
    [VirtuosoLogger setLogLevel:level];
}

- (Boolean)logBackplaneComms
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"VirtuosoVerboseBackplaneLogging"];
}

- (void)setLogBackplaneComms:(Boolean)logBackplaneComms
{
    [[NSUserDefaults standardUserDefaults] setBool:logBackplaneComms forKey:@"VirtuosoVerboseBackplaneLogging"];
}

- (Boolean)logHTTPProxyComms
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"VirtuosoVerboseProxyLogging"];
}

- (void)setLogHTTPProxyComms:(Boolean)logHTTPProxyComms
{
    [[NSUserDefaults standardUserDefaults] setBool:logHTTPProxyComms forKey:@"VirtuosoVerboseProxyLogging"];
}

@end
