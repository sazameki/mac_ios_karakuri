//
//  KRPeerPicker.mm
//  Karakuri Library
//
//  Created by numata on 09/08/20.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KRPeerPicker.h"
#import "KarakuriNetwork.h"
#import "KarakuriGame.h"


@implementation KRPeerPickerController

@synthesize delegate = mDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Peer Picker";
        
        BOOL isHorizontal = (gKRScreenSize.x > gKRScreenSize.y);

        mNetworkBrowser = [[KRNetworkBrowser alloc] initWithGameID:[NSString stringWithCString:gKRGameInst->getGameIDForNetwork().c_str() encoding:NSUTF8StringEncoding]];
        [mNetworkBrowser setDelegate:self];

        NSString *ownName = [NSString stringWithCString:gKRNetworkInst->getOwnName().c_str() encoding:NSUTF8StringEncoding];
        
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPeerPicker:)];
        //UIBarButtonItem *bluetoothButton = [[UIBarButtonItem alloc] initWithTitle:@"Bluetooth" style:UIBarButtonItemStylePlain target:self action:@selector(changeToBluetoothMode:)];
        //bluetoothButton.enabled = NO;
        
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:(isHorizontal? CGRectMake(0, 0, 480, 74): CGRectMake(0, 0, 320, 74))];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:ownName];
        navItem.leftBarButtonItem = closeButton;
        //navItem.rightBarButtonItem = bluetoothButton;
        if (gKRLanguage == KRLanguageJapanese) {
            navItem.prompt = @"ネットワーク・ピアの一覧";
        } else {
            navItem.prompt = @"Network Peer List";
        }        
        [navBar setItems:[NSArray arrayWithObject:navItem] animated:NO];
        [self.view addSubview:navBar];
        
        mTableView = [[UITableView alloc] initWithFrame:(isHorizontal? CGRectMake(0, 74, 480, 320-74): CGRectMake(0, 74, 320, 480-74)) style:UITableViewStylePlain];
        mTableView.alpha = 0.7f;
        mTableView.delegate = self;
        mTableView.dataSource = self;
        [self.view addSubview:mTableView];
    }
    return self;
}

- (void)dealloc
{
    [mNetworkBrowser release];
    [super dealloc];
}

- (void)cancelPeerPicker:(id)sender
{
    if (mDelegate && [mDelegate respondsToSelector:@selector(peerPickerCanceled:)]) {
        [mDelegate peerPickerCanceled:self];
    }
}

- (void)changeToBluetoothMode:(id)sender
{
}

- (void)processAccepted
{
    if (mDelegate && [mDelegate respondsToSelector:@selector(peerPickerAccepted:)]) {
        [mDelegate peerPickerAccepted:self];
    }
}

- (void)processDenied
{
    if (mDelegate && [mDelegate respondsToSelector:@selector(peerPickerDenied:)]) {
        [mDelegate peerPickerDenied:self];
    }
}


#pragma mark -
#pragma mark NetService delgation

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict
{
    [service stop];
    NSLog(@"netServiceDidNotResolve: %@", errorDict);
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    struct sockaddr *sockAddr = NULL;
    NSData *addressData = nil;
    for (int i = 0; i < [[service addresses] count]; i++) {
        NSData *addrData = [[service addresses] objectAtIndex:i];
        sockAddr = (struct sockaddr *)[addrData bytes];
        if (sockAddr->sa_family == AF_INET && sockAddr->sa_len == sizeof(struct sockaddr_in)) {
            addressData = addrData;
            break;
        }
    }
    
    if (!addressData) {
        return;
    }
    
    gKRNetworkInst->startInvitation(addressData, self);
}


#pragma mark -
#pragma mark Table View DataSource & Delegation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[mNetworkBrowser services] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *tableCellIdentifier = @"UITableViewCell";

	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier] autorelease];
	}
    
    NSNetService *aService = [[mNetworkBrowser services] objectAtIndex:indexPath.row];
    cell.textLabel.text = [aService name];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNetService *theService = [[mNetworkBrowser services] objectAtIndex:indexPath.row];
    [theService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [theService setDelegate:self];
    [theService resolveWithTimeout:20.0];    
}


#pragma mark -
#pragma mark Network Browser Delegation

- (void)networkBrowserDidUpdatePeerPist:(KRNetworkBrowser *)browser
{
    [mTableView reloadData];
}

@end



