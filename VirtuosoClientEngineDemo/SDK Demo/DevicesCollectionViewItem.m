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

#import "DevicesCollectionViewItem.h"

@interface DevicesCollectionViewItem ()

@end

@implementation DevicesCollectionViewItem

- (id)init
{
    return [super initWithNibName:@"DevicesCollectionViewItem" bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
}

- (void)viewWillAppear
{
    [self.nickname setStringValue:self.device.nickname];
    self.enabledBtn.state = self.device.downloadEnabled?NSOnState:NSOffState;
    self.nickname.enabled = self.device.isThisDevice;
    self.updateBtn.enabled = self.nickname.enabled;
}

- (IBAction)setEnabled:(NSButton*)sender
{
    [self.device updateDownloadEnabled:sender.state==NSOnState
                            onComplete:^(Boolean success, NSError * _Nullable error) {
                                sender.state = self.device.downloadEnabled?NSOnState:NSOffState;
                                NSLog(@"Set device enabled state %@.  Error: %@",success?@"successfully":@"with errors",error);
                                [self.parent didUpdateDevice:self.device];
                            }];
}

- (IBAction)didUpdateNickname:(NSButton*)sender
{
    if( !self.device.isThisDevice )
        return;
    
    [self.device updateNickname:self.nickname.stringValue
                     onComplete:^(Boolean success, NSError * _Nullable error) {
                         [self.nickname setStringValue:self.device.nickname];
                         NSLog(@"Set device nickname %@.  Error: %@",success?@"successfully":@"with errors",error);
                         [self.parent didUpdateDevice:self.device];
                     }];
}

- (IBAction)unregisterDevice:(NSButton*)sender
{
    [self.device unregisterOnComplete:^(Boolean success, NSError * _Nullable error) {
        if( success )
        {
            if( self.device.isThisDevice )
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLogout" object:nil userInfo:@{@"FromUnregister":@YES}];
                [self dismissController:self];
            }
            else
            {
                [self.parent didDeleteDevice:self.device];
            }
        }
    }];
}

@end
