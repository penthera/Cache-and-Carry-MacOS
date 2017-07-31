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

#import "SystemStatusViewController.h"
#import <VirtuosoClientDownloadEngine/VirtuosoClientDownloadEngine.h>
#import <VirtuosoClientSubscriptionManager/VirtuosoSubscriptionManager.h>
#import <mach/mach.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <CommonCrypto/CommonHMAC.h>

@interface SystemStatusViewController ()
{
    NSMutableArray* obs;
}
@end

@implementation SystemStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    obs = [NSMutableArray array];
    
    id<NSObject> _obs = [[NSNotificationCenter defaultCenter] addObserverForName:@"DidLogout"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self dismissController:self];
                                                  }];
    [obs addObject:_obs];
    
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:@"AssetDeleted"
                                                             object:nil
                                                              queue:[NSOperationQueue mainQueue]
                                                         usingBlock:^(NSNotification * _Nonnull note) {
                                                             [self reloadData];
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
     *  Called whenever the Engine status changes
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineStatusDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self reloadData];
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  Called whenever the Engine starts downloading a VirtuosoAsset object.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineDidStartDownloadingAssetNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self reloadData];
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  Called whenever the Engine reports progress for a VirtuosoAsset object
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineProgressUpdatedForAssetNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self reloadData];
                                                  }];
    [obs addObject:_obs];
    
    /*
     *  Called when internal logic changes queue order.  All we need to do is refresh the tables.
     */
    _obs = [[NSNotificationCenter defaultCenter] addObserverForName:kDownloadEngineInternalQueueUpdateNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
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
                                                      [self reloadData];
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
}

- (void)dealloc {
    for( id<NSObject> _obs in obs )
        [[NSNotificationCenter defaultCenter] removeObserver:_obs];
}

- (void)reloadData
{
    unsigned int numberOfProperties, i;
    objc_property_t *properties = class_copyPropertyList([SystemStatusViewController class],
                                                         &numberOfProperties);
    for (i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if (propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [self willChangeValueForKey:propertyName];
            [self didChangeValueForKey:propertyName];
        }
    }
}

- (NSString*)engineStatus
{
    switch ([VirtuosoDownloadEngine instance].status) {
        case kVDE_Idle:
        return @"Idle";
        break;
        
        case kVDE_Errors:
        return @"Download Errors";
        break;
        
        case kVDE_Blocked:
        return @"Blocked on Environment";
        break;
        
        case kVDE_Disabled:
        return @"Disabled";
        break;
        
        case kVDE_Downloading:
        return @"Downloading";
        break;
        
        case kVDE_AuthenticationFailure:
        return @"Blocked on License";
        break;
        
        default:
        break;
    }
    return @"";
}

- (NSString*)networkStatus
{
    return [VirtuosoDownloadEngine instance].networkStatusOK?@"OK":@"Blocked";
}

- (NSString*)storageStatus
{
    return [VirtuosoDownloadEngine instance].diskStatusOK?@"OK":@"Blocked";
}

- (NSString*)queueStatus
{
    return [VirtuosoDownloadEngine instance].queueStatusOK?@"OK":@"Blocked";
}

- (NSString*)accountStatus
{
    return [VirtuosoDownloadEngine instance].accountStatusOK?@"OK":@"Blocked";
}

- (NSString*)authenticationStatus
{
    return [VirtuosoDownloadEngine instance].authenticationOK?@"OK":@"Blocked";
}

- (NSString*)maxDevices
{
    return [NSString stringWithFormat:@"%lld",[VirtuosoSettings instance].maxDevicesForDownload];
}

- (NSString*)currentDevices
{
    return [NSString stringWithFormat:@"%lld",[VirtuosoSettings instance].numberOfDevicesEnabled];
}

- (NSString*)secureTime
{
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.timeStyle = NSDateFormatterMediumStyle;
    df.dateStyle = NSDateFormatterMediumStyle;
    
    return [df stringFromDate:[[VirtuosoSecureClock instance]secureDate]];
}

- (NSString*)licenseExpires
{
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.timeStyle = NSDateFormatterMediumStyle;
    df.dateStyle = NSDateFormatterMediumStyle;
    
    if( [VirtuosoDownloadEngine instance].licenseExpiry )
        return [df stringFromDate:[VirtuosoDownloadEngine instance].licenseExpiry];
    else
        return @"Never";
}

- (NSString*)signatureForString:(NSString*)theString
{
    const char *cKey  = [[[VirtuosoDownloadEngine instance] secret] cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [theString cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData* sig = [[NSData alloc]initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString* signature = [[[[NSString stringWithFormat:@"%@",sig]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return signature;
}

- (NSString*)diskSpaceUsed
{
    long long used = [VirtuosoAsset storageUsed]/1024/1024;
    return [NSString stringWithFormat:@"%qi MB",used];
}

- (NSString*)downloadBandwidth
{
    return [[VirtuosoDownloadEngine instance] downloadBandwidthString];
}

@end
