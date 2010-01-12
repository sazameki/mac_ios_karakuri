//
//  KRPeerPicker.mm
//  Karakuri Library
//
//  Created by numata on 09/08/19.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KRPeerPicker.h"
#import "KRNetwork.h"
#import "KRGame.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>


@implementation KRPeerPickerWindow

- (id)initWithMainWindow:(NSWindow *)mainWindow
{
    NSRect contentRect = [mainWindow contentRectForFrameRect:[mainWindow frame]];
    
    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0f alpha:0.8f]];
        [self setOpaque:NO];
        
        mNetworkBrowser = [[KRNetworkBrowser alloc] initWithGameID:[NSString stringWithCString:gKRGameInst->getGameIDForNetwork().c_str() encoding:NSUTF8StringEncoding]];
        [mNetworkBrowser setDelegate:self];

        mTitleField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, contentRect.size.height-30, contentRect.size.width-34, 18)];
        [mTitleField setBordered:NO];
        [mTitleField setDrawsBackground:NO];
        [mTitleField setSelectable:NO];
        [mTitleField setFont:[NSFont boldSystemFontOfSize:14.0f]];
        [mTitleField setTextColor:[NSColor whiteColor]];
        if (gKRLanguage == KRLanguageJapanese) {
            [mTitleField setStringValue:@"ネットワーク・ピアの一覧"];
        } else {
            [mTitleField setStringValue:@"Network Peer List"];
        }        
        [[self contentView] addSubview:mTitleField];
        
        NSButton *cancelButton = [[[NSButton alloc] initWithFrame:NSMakeRect(contentRect.size.width-140*2-17*2, 12, 140, 32)] autorelease];
        if (gKRLanguage == KRLanguageJapanese) {
            [cancelButton setTitle:@"キャンセル"];
        } else {
            [cancelButton setTitle:@"Cancel"];
        }
        [cancelButton setBezelStyle:NSRoundedBezelStyle];
        [cancelButton setTarget:self];
        [cancelButton setAction:@selector(cancelPeerPicker:)];
        [[self contentView] addSubview:cancelButton];

        mInviteButton = [[NSButton alloc] initWithFrame:NSMakeRect(contentRect.size.width-140-17, 12, 140, 32)];
        if (gKRLanguage == KRLanguageJapanese) {
            [mInviteButton setTitle:@"招待する"];
        } else {
            [mInviteButton setTitle:@"Invite"];
        }
        [mInviteButton setBezelStyle:NSRoundedBezelStyle];
        [mInviteButton setTarget:self];
        [mInviteButton setAction:@selector(doInvite:)];
        [mInviteButton setEnabled:NO];
        [[self contentView] addSubview:mInviteButton];
        
        mPeerListView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 1, 460, 0)];
        [mPeerListView setRowHeight:22.0f];
        [mPeerListView setFont:[NSFont systemFontOfSize:24.0f]];
        [mPeerListView setDataSource:self];
        [mPeerListView setDelegate:self];
        [mPeerListView setHeaderView:nil];
        [mPeerListView setTarget:self];
        [mPeerListView setDoubleAction:@selector(doInvite:)];
        [mPeerListView setUsesAlternatingRowBackgroundColors:YES];
        
        NSTableColumn *peerNameColumn = [[[NSTableColumn alloc] initWithIdentifier:@"Peer Name"] autorelease];
        [peerNameColumn setWidth:460];
        [[peerNameColumn headerCell] setTitle:@"Peer Name"];
        [mPeerListView addTableColumn:peerNameColumn];
        
        NSScrollView *peerTableScrollView = [[[NSScrollView alloc] initWithFrame:NSMakeRect(20, 51, contentRect.size.width-40, contentRect.size.height-100)] autorelease];
        [peerTableScrollView setBorderType:NSBezelBorder];
        [peerTableScrollView setHasVerticalScroller:YES];
        [[peerTableScrollView contentView] setDocumentView:mPeerListView];
        [[self contentView] addSubview:peerTableScrollView];

        [self setReleasedWhenClosed:NO];
        
        [mainWindow addChildWindow:self ordered:NSWindowAbove];
   }
    return self;
}

- (void)dealloc
{
    [mTitleField release];
    [mPeerListView release];
    [mInviteButton release];
    [mNetworkBrowser release];
    [super dealloc];
}

- (void)setDelegate:(id)delegate
{
    mDelegate = delegate;
}


#pragma mark -
#pragma mark Main Control

- (void)cancelPeerPicker:(id)sender
{
    [[self parentWindow] removeChildWindow:self];
    [self orderOut:self];
    
    if (mDelegate && [mDelegate respondsToSelector:@selector(peerPickerCanceled:)]) {
        [mDelegate peerPickerCanceled:self];
    }
    
    [self release];
}

- (void)doInvite:(id)sender
{
    int selectedRow = [mPeerListView selectedRow];
    if (selectedRow < 0) {
        return;
    }
    
    NSNetService *theService = [[mNetworkBrowser services] objectAtIndex:selectedRow];
    [theService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [theService setDelegate:self];
    [theService resolveWithTimeout:20.0];

}

- (void)processAccepted
{
    [[self parentWindow] removeChildWindow:self];
    [self orderOut:self];

    if (mDelegate && [mDelegate respondsToSelector:@selector(peerPickerAccepted:)]) {
        [mDelegate peerPickerAccepted:self];
    }

    [self release];
}

- (void)processDenied
{
    [[self parentWindow] removeChildWindow:self];
    [self orderOut:self];

    if (mDelegate && [mDelegate respondsToSelector:@selector(peerPickerDenied:)]) {
        [mDelegate peerPickerDenied:self];
    }

    [self release];
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

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[mNetworkBrowser services] count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if ([mPeerListView selectedRow] >= 0) {
        [mInviteButton setEnabled:YES];
    } else {
        [mInviteButton setEnabled:NO];
    }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSNetService *aService = [[mNetworkBrowser services] objectAtIndex:rowIndex];
    return [aService name];
}


#pragma mark -
#pragma mark Network Browser Delegation

- (void)networkBrowserDidUpdatePeerPist:(KRNetworkBrowser *)browser
{
    [mPeerListView reloadData];
}

@end


