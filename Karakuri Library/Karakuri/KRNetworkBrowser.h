//
//  KRNetworkBrowser.h
//  Karakuri Library
//
//  Created by numata on 09/08/19.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Foundation/Foundation.h>


@class KRNetworkBrowser;


@protocol KRNetworkBrowserDelegate
@optional
- (void)networkBrowserDidUpdatePeerPist:(KRNetworkBrowser*)browser;
@end


@interface KRNetworkBrowser : NSObject {
    id              mDelegate;

    NSNetServiceBrowser*    mNetServiceBrowser;
    NSMutableArray*         mServices;
}

+ (NSString*)bonjourTypeFromIdentifier:(NSString*)identifier;

- (id)initWithGameID:(NSString*)gameID;

- (void)setDelegate:(id)delegate;

- (NSArray*)services;

@end
