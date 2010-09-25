//
//  KRNetworkBrowser.mm
//  Karakuri Library
//
//  Created by numata on 09/08/19.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KRNetworkBrowser.h"
#import "KRNetwork.h"
#import "KRGameController.h"


@implementation KRNetworkBrowser

+ (NSString*)bonjourTypeFromIdentifier:(NSString*)identifier
{
	if (![identifier length]) {
		return nil;
    }
    
    return [NSString stringWithFormat:@"_%@._tcp.", identifier];
}

- (id)initWithGameID:(NSString*)gameID
{
    self = [super init];
    if (self) {
        mServices = [NSMutableArray new];

        mNetServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [mNetServiceBrowser setDelegate:self];
        [mNetServiceBrowser searchForServicesOfType:[KRNetworkBrowser bonjourTypeFromIdentifier:gameID] inDomain:@"local"];
    }
    return self;
}

- (void)dealloc
{
    [mNetServiceBrowser release];
    [mServices release];
    [super dealloc];
}

- (void)setDelegate:(id)delegate
{
    mDelegate = delegate;
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing
{
    NSString* serviceName = [service name];
    NSString* ownName = [NSString stringWithCString:gKRNetworkInst->getOwnName().c_str() encoding:NSUTF8StringEncoding];
    if (![serviceName isEqualToString:ownName]) {
        [mServices removeObject:service];
        if (mDelegate && [mDelegate respondsToSelector:@selector(networkBrowserDidUpdatePeerPist:)]) {
            [mDelegate networkBrowserDidUpdatePeerPist:self];
        }
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing
{
    NSString* serviceName = [service name];
    NSString* ownName = [NSString stringWithCString:gKRNetworkInst->getOwnName().c_str() encoding:NSUTF8StringEncoding];
    if (![serviceName isEqualToString:ownName]) {
        [mServices addObject:service];
        if (mDelegate && [mDelegate respondsToSelector:@selector(networkBrowserDidUpdatePeerPist:)]) {
            [mDelegate networkBrowserDidUpdatePeerPist:self];
        }
    }
}

- (NSArray*)services
{
    return mServices;
}

@end

