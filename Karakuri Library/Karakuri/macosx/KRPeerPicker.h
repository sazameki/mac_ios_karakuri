//
//  KRPeerPicker.h
//  Karakuri Library
//
//  Created by numata on 09/08/19.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Karakuri/KRNetworkBrowser.h>


@class KRPeerPickerWindow;


@protocol KRPeerPickerDelegate
@optional
- (void)peerPickerCanceled:(KRPeerPickerWindow *)pickerWindow;
- (void)peerPickerAccepted:(KRPeerPickerWindow *)pickerWindow;
- (void)peerPickerDenied:(KRPeerPickerWindow *)pickerWindow;
@end


@interface KRPeerPickerWindow : NSWindow {
    id              mDelegate;

    NSTextField     *mTitleField;
    NSTableView     *mPeerListView;
    NSButton        *mInviteButton;
    
    KRNetworkBrowser    *mNetworkBrowser;
}

- (id)initWithMainWindow:(NSWindow *)mainWindow;

- (void)setDelegate:(id)delegate;

- (void)cancelPeerPicker:(id)sender;
- (void)processAccepted;
- (void)processDenied;

@end

