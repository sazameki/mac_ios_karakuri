//
//  KRPeerPicker.h
//  Karakuri Library
//
//  Created by numata on 09/08/20.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Karakuri/KRNetworkBrowser.h>


@class KRPeerPickerController;


@protocol KRPeerPickerDelegate
@optional
- (void)peerPickerCanceled:(KRPeerPickerController*)pickerController;
- (void)peerPickerAccepted:(KRPeerPickerController*)pickerController;
- (void)peerPickerDenied:(KRPeerPickerController*)pickerController;
@end


@interface KRPeerPickerController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	id      mDelegate;
    
    UITableView*        mTableView;

    KRNetworkBrowser*   mNetworkBrowser;
}

@property (nonatomic, assign) id<KRPeerPickerDelegate> delegate;

- (void)cancelPeerPicker:(id)sender;
- (void)processAccepted;
- (void)processDenied;

@end



