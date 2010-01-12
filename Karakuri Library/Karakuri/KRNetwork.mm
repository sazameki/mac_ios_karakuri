/*!
    @file   KRNetwork.mm
    @author numata
    @date   09/08/18
 */

#include <Karakuri/KarakuriLibrary.h>

#include "KRNetwork.h"
#include "KRGameController.h"

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#include <CFNetwork/CFSocketStream.h>
#endif


@class KRTCPServer;

extern NSString * const KRTCPServerErrorDomain;

typedef enum {
    kKRTCPServerCouldNotBindToIPv4Address = 1,
    kKRTCPServerCouldNotBindToIPv6Address = 2,
    kKRTCPServerNoSocketsAvailable = 3,
} KRTCPServerErrorCode;


@protocol KRTCPServerDelegate <NSObject>
@optional
- (void)serverDidEnableBonjour:(KRTCPServer*)server withName:(NSString*)name;
- (void)server:(KRTCPServer*)server didNotEnableBonjour:(NSDictionary *)errorDict;
- (void)didAcceptConnectionForServer:(KRTCPServer*)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr socket:(int)socket;
@end


@interface KRTCPServer : NSObject {
@private
	id _delegate;
    uint16_t _port;
	CFSocketRef _ipv4socket;
	NSNetService* _netService;
}

- (BOOL)start:(NSError **)error;
- (BOOL)stop;
- (BOOL)enableBonjourWithDomain:(NSString*)domain applicationProtocol:(NSString*)protocol name:(NSString*)name; //Pass "nil" for the default local domain - Pass only the application protocol for "protocol" e.g. "myApp"
- (void)disableBonjour;

//@property(assign) id<TCPServerDelegate> delegate;
- (id<KRTCPServerDelegate>)delegate;
- (void)setDelegate:(id<KRTCPServerDelegate>)delegate;

+ (NSString*)bonjourTypeFromIdentifier:(NSString*)identifier;

@end


typedef enum {
    KRNetworkServerStateWaitForClient,
    KRNetworkServerStateWaitForName,
    KRNetworkServerStateConnected,
    KRNetworkServerStateInviting,
    KRNetworkServerStateWaitForInviteReply,
} KRNetworkServerState;


const int KRNetworkBufferSize = 2048;


@interface KRNetworkImpl : NSObject<KRTCPServerDelegate> {
    KRTCPServer   *mTCPServer;
    
    NSInputStream       *mInStream;
	NSOutputStream      *mOutStream;
    
    BOOL        mInReady;
    BOOL        mOutReady;
    
    char        mInBuffer[KRNetworkBufferSize];
    int         mInPos;
    std::list<std::string>  *mInMessages;
    
    KRNetworkServerState    mState;
    NSLock                  *mDataLock;
    
    int         mSocket;    
    NSString    *mOwnName;

    void        *mPeerPickerUI;
}

- (id)initWithGameID:(NSString *)gameID;

- (std::list<std::string>)receivedMessages;

- (KRNetworkServerState)state;
- (void)setState:(KRNetworkServerState)value;

- (CFSocketNativeHandle)nativeHandle;

- (void)processConnectCallback;
- (void)processDataCallback:(NSData *)data;

- (void)doAccept;
- (void)doReject;

@end


KRNetwork *gKRNetworkInst = NULL;


NSString * const KRTCPServerErrorDomain = @"KRTCPServerErrorDomain";

@interface KRTCPServer ()

- (NSNetService *)netService;

//@property(nonatomic,retain) NSNetService* netService;
//@property(assign) uint16_t port;
@end

@implementation KRTCPServer

//@synthesize delegate=_delegate, netService=_netService, port=_port;
- (NSNetService *)netService
{
    return _netService;
}

- (void)setNetService:(NSNetService *)netService
{
    _netService = netService;
}

- (id<KRTCPServerDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<KRTCPServerDelegate>)delegate
{
    _delegate = delegate;
}

- (uint16_t)port
{
    return _port;
}

- (void)setPort:(uint16_t)port
{
    _port = port;
}

- (id)init
{
    return self;
}

- (void)dealloc
{
    [self stop];
    [super dealloc];
}

- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)inStream outputStream:(NSOutputStream *)outStream socket:(int)socket
{
    // if the delegate implements the delegate method, call it
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(didAcceptConnectionForServer:inputStream:outputStream:socket:)]) { 
        [[self delegate] didAcceptConnectionForServer:self inputStream:inStream outputStream:outStream socket:socket];
    }
}

// This function is called by CFSocket when a new connection comes in.
// We gather some data here, and convert the function call to a method
// invocation on TCPServer.
static void KRTCPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    KRTCPServer *server = (KRTCPServer *)info;
    if (kCFSocketAcceptCallBack == type) { 
        // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        uint8_t name[SOCK_MAXADDRLEN];
        socklen_t namelen = sizeof(name);
        NSData *peer = nil;
        if (0 == getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen)) {
            peer = [NSData dataWithBytes:name length:namelen];
        }
        CFReadStreamRef readStream = NULL;
		CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
        if (readStream != NULL && writeStream != NULL) {
            [server handleNewConnectionFromAddress:peer inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream socket:nativeSocketHandle];
        } else {
            // on any failure, need to destroy the CFSocketNativeHandle 
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}

- (BOOL)start:(NSError **)error
{
    CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
    _ipv4socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&KRTCPServerAcceptCallBack, &socketCtxt);
	
    if (NULL == _ipv4socket) {
        if (error) *error = [[NSError alloc] initWithDomain:KRTCPServerErrorDomain code:kKRTCPServerNoSocketsAvailable userInfo:nil];
        if (_ipv4socket) CFRelease(_ipv4socket);
        _ipv4socket = NULL;
        return NO;
    }
	
	
    int yes = 1;
    setsockopt(CFSocketGetNative(_ipv4socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
	
    // set up the IPv4 endpoint; use port 0, so the kernel will choose an arbitrary port for us, which will be advertised using Bonjour
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = 0;
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
	
    if (kCFSocketSuccess != CFSocketSetAddress(_ipv4socket, (CFDataRef)address4)) {
        if (error) *error = [[NSError alloc] initWithDomain:KRTCPServerErrorDomain code:kKRTCPServerCouldNotBindToIPv4Address userInfo:nil];
        if (_ipv4socket) CFRelease(_ipv4socket);
        _ipv4socket = NULL;
        return NO;
    }
    
	// now that the binding was successful, we get the port number 
	// -- we will need it for the NSNetService
	NSData *addr = [(NSData *)CFSocketCopyAddress(_ipv4socket) autorelease];
	memcpy(&addr4, [addr bytes], [addr length]);
	[self setPort:ntohs(addr4.sin_port)];
    
    NSLog(@"Bonjour server at port: %d", [self port]);
	
    // set up the run loop sources for the sockets
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4socket, 0);
    CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
    CFRelease(source4);
	
    return YES;
}

- (BOOL)stop
{
    [self disableBonjour];
    
	if (_ipv4socket) {
		CFSocketInvalidate(_ipv4socket);
		CFRelease(_ipv4socket);
		_ipv4socket = NULL;
	}
	
    return YES;
}

- (BOOL)enableBonjourWithDomain:(NSString*)domain applicationProtocol:(NSString*)protocol name:(NSString*)name
{
	if ([domain length] == 0) {
		domain = @""; //Will use default Bonjour registration doamins, typically just ".local"
    }

	if ([name length] == 0) {
		name = @""; //Will use default Bonjour name, e.g. the name assigned to the device in iTunes
    }
	
	if (!protocol || [protocol length] == 0 || _ipv4socket == NULL) {
		return NO;
    }
    
	[self setNetService:[[NSNetService alloc] initWithDomain:domain type:protocol name:name port:[self port]]];
	if (![self netService]) {
		return NO;
    }
	
	[[self netService] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[[self netService] publish];
	[[self netService] setDelegate:self];
	
	return YES;
}

/*
 Bonjour will not allow conflicting service instance names (in the same domain), and may have automatically renamed
 the service if there was a conflict.  We pass the name back to the delegate so that the name can be displayed to
 the user.
 See http://developer.apple.com/networking/bonjour/faq.html for more information.
 */

- (void)netServiceDidPublish:(NSNetService *)sender
{
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(serverDidEnableBonjour:withName:)])
		[[self delegate] serverDidEnableBonjour:self withName:sender.name];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
	[super netService:sender didNotPublish:errorDict];
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(server:didNotEnableBonjour:)])
		[[self delegate] server:self didNotEnableBonjour:errorDict];
}

- (void)disableBonjour
{
	if ([self netService]) {
		[[self netService] stop];
		[[self netService] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[self setNetService:nil];
	}
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | port %d | netService = %@>", [self class], (long)self, [self port], [self netService]];
}

+ (NSString*)bonjourTypeFromIdentifier:(NSString*)identifier
{
	if (![identifier length]) {
		return nil;
    }
    
    return [NSString stringWithFormat:@"_%@._tcp.", identifier];
}

@end



#pragma mark -

@implementation KRNetworkImpl

- (id)initWithGameID:(NSString *)gameID
{
    self = [super init];
    if (self) {
        mInReady = NO;
        mOutReady = NO;
        
        mDataLock = [NSLock new];
        
        mInMessages = new std::list<std::string>();
        
        mInPos = 0;
        
        mState = KRNetworkServerStateWaitForClient;

        mTCPServer = [KRTCPServer new];
        [mTCPServer setDelegate:self];
        
        NSError *error;
        if (!mTCPServer || ![mTCPServer start:&error]) {
            NSLog(@"Failed to create a TCP server: %@", error);
            [self release];
            return nil;
        }
        
        //Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
        if (![mTCPServer enableBonjourWithDomain:@"local" applicationProtocol:[KRTCPServer bonjourTypeFromIdentifier:gameID] name:nil]) {
            NSLog(@"Failed to advertise the TCP server via Bonjour.");
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [mTCPServer release];
    [mDataLock release];
    
    [mOwnName release];
    
    delete mInMessages;

    [super dealloc];
}

- (void)openStreams
{
	[mInStream setDelegate:self];
	[mOutStream setDelegate:self];

	[mInStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[mOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	[mInStream open];
	[mOutStream open];
}

- (std::list<std::string>)receivedMessages
{
    //[mDataLock lock];
    std::list<std::string> ret(*mInMessages);
    mInMessages->clear();
    //[mDataLock unlock];

    return ret;
}

- (BOOL)isConnected
{
    return (mState == KRNetworkServerStateConnected);
}

- (NSString *)ownName
{
    return mOwnName;
}

- (void)reset
{
}

- (KRNetworkServerState)state
{
    return mState;
}

- (void)setState:(KRNetworkServerState)value
{
    mState = value;
}

- (CFSocketNativeHandle)nativeHandle
{
    return mSocket;
}

- (int)sendMessage:(const char *)message
{
    static const char *CRLF = "\r\n";
    
    int length = 0;
    length += write(mSocket, message, strlen(message));
    length += write(mSocket, CRLF, 2);
//    length += [mOutStream write:(uint8_t *)message maxLength:strlen(message)];
//    length += [mOutStream write:(uint8_t *)CRLF maxLength:2];
    
    return length;
}

- (void)showPeerPicker
{
    [[KRGameController sharedController] performSelectorOnMainThread:@selector(showNetworkPeerPicker) withObject:nil waitUntilDone:NO];
}

- (void)doAccept
{
    [self sendMessage:"KRaccept"];

    mState = KRNetworkServerStateConnected;
}

- (void)doReject
{
    uint8_t buffer[] = "KRreject\r\n";
    write(mSocket, buffer, 10);

    [mInStream close];
    [mInStream release];
    mInStream = nil;

    [mOutStream close];
    [mOutStream release];
    mOutStream = nil;

    close(mSocket);

    mState = KRNetworkServerStateWaitForClient;
}

static void InvitationCallBack(CFSocketRef socketRef,
                         CFSocketCallBackType type,
                         CFDataRef address,
                         const void *data,
                         void *info)
{
    KRNetworkImpl *impl = (KRNetworkImpl *)info;
    
    if (type == kCFSocketConnectCallBack) {
        [impl processConnectCallback];
    }
    else if (type == kCFSocketDataCallBack) {
        [impl processDataCallback:(NSData *)data];
    }
}

- (void)startInvitation:(NSData *)peerAddressData peerPickerUI:(void *)peerPickerUI
{
    mPeerPickerUI = peerPickerUI;
    mState = KRNetworkServerStateInviting;

    CFSocketContext socketCtxt = { 0, self, NULL, NULL, NULL };
    CFSocketRef socketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP,
                                           kCFSocketDataCallBack | kCFSocketConnectCallBack, (CFSocketCallBack)InvitationCallBack, &socketCtxt);
    if (socketRef == NULL) {
        return;
    }

    mSocket = CFSocketGetNative(socketRef);

    CFSocketError err = CFSocketConnectToAddress(socketRef, (CFDataRef)peerAddressData, -1.0);
    if (err != kCFSocketSuccess) {
        return;
    }

    CFRunLoopRef runLoopRef = [[NSRunLoop currentRunLoop] getCFRunLoop];
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socketRef, 0);
    CFRunLoopAddSource(runLoopRef, sourceRef, kCFRunLoopCommonModes);
    CFRelease(sourceRef);
}

- (void)processConnectCallback
{
    if (mState == KRNetworkServerStateInviting) {
        NSString *inviteMessage = [NSString stringWithFormat:@"KRname %@", [self ownName]];
        [self sendMessage:[inviteMessage cStringUsingEncoding:NSUTF8StringEncoding]];
        mState = KRNetworkServerStateWaitForInviteReply;
    }    
}

static BOOL isFDReady(int fd)
{
    int rc;
    fd_set fds;
    struct timeval tv;
    
    FD_ZERO(&fds);
    FD_SET(fd,&fds);
    tv.tv_sec = tv.tv_usec = 0;
    
    rc = select(fd+1, &fds, NULL, NULL, &tv);
    if (rc < 0) {
        return NO;
    }
    
    return FD_ISSET(fd,&fds)? YES: NO;
}

- (void)processDataCallback:(NSData *)data
{
    [mDataLock lock];
    
    if (!data) {
        while (YES) {
            if (mInStream) {
                int length = [mInStream read:(uint8_t *)(mInBuffer + mInPos) maxLength:256];
                if (length <= 0) {
                    break;
                }
                mInPos += length;
                if (![mInStream hasBytesAvailable]) {
                    break;
                }
            } else {
                int length = read(mSocket, mInBuffer + mInPos, 256);
                if (length <= 0) {
                    break;
                }
                mInPos += length;                
                if (!isFDReady(mSocket)) {
                    break;
                }
            }
        }
    } else {
        [data getBytes:mInBuffer + mInPos];
        mInPos += [data length];
    }

    for (int i = 0; i < mInPos; i++) {
        if (mInBuffer[i] == '\r' || mInBuffer[i] == '\n') {
            std::string str(mInBuffer, i);
            mInMessages->push_back(str);
            i++;
            if (mInBuffer[i] == '\n') {
                i++;
            }
            int rest = mInPos - i;
            for (int j = 0; j < rest; j++) {
                mInBuffer[j] = mInBuffer[i+j];
            }
            mInPos = rest;
            i = 0;
            continue;
        }
    }
    if (mState == KRNetworkServerStateWaitForName && mInMessages->size() > 0) {
        std::string nameMessage = *(mInMessages->begin());
        mInMessages->erase(mInMessages->begin());
        std::string name = nameMessage.substr(7, nameMessage.length()-7);
        [[KRGameController sharedController] processNetworkRequest:[NSString stringWithCString:name.c_str() encoding:NSUTF8StringEncoding]];
    } else if (mState == KRNetworkServerStateWaitForInviteReply && mInMessages->size() > 0) {
        std::string replyMessage = *(mInMessages->begin());
        mInMessages->erase(mInMessages->begin());
#if KR_MACOSX || KR_MACPHONE_EMU
        if (replyMessage.compare("KRaccept") == 0) {
            mState = KRNetworkServerStateConnected;
            [(KRPeerPickerWindow *)mPeerPickerUI processAccepted];
        } else {
            mState = KRNetworkServerStateWaitForClient;
            [(KRPeerPickerWindow *)mPeerPickerUI processDenied];
        }
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
        if (replyMessage.compare("KRaccept") == 0) {
            mState = KRNetworkServerStateConnected;
            [(KRPeerPickerController *)mPeerPickerUI processAccepted];
        } else {
            mState = KRNetworkServerStateWaitForClient;
            [(KRPeerPickerController *)mPeerPickerUI processDenied];
        }
#endif

        mPeerPickerUI = nil;
    }
    [mDataLock unlock];
}

@end


@implementation KRNetworkImpl (NSStreamDelegate)

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	switch (eventCode) {
        case NSStreamEventOpenCompleted:
            if (stream == mInStream) {
                mInReady = YES;
            } else {
                mOutReady = YES;
            }
            if (mInReady && mOutReady) {
                [self processConnectCallback];
            }
            break;

        case NSStreamEventHasBytesAvailable: {
            [self processDataCallback:nil];
            break;
        }

        case NSStreamEventErrorOccurred:
            NSLog(@"NSStreamEventErrorOccurred");
            break;

        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");
            mState = KRNetworkServerStateWaitForClient;
            break;

        default:
            NSLog(@"default");
            break;
    }
}

@end


@implementation KRNetworkImpl (KRTCPServerDelegate)

- (void)serverDidEnableBonjour:(KRTCPServer *)server withName:(NSString *)string
{
    mOwnName = [string copy];
}

- (void)didAcceptConnectionForServer:(KRTCPServer *)server inputStream:(NSInputStream *)inStream outputStream:(NSOutputStream *)outStream socket:(int)socket
{
    if (mState != KRNetworkServerStateWaitForClient) {
        uint8_t buffer[] = "KRbusy\r\n";
        write(socket, buffer, 8);
        close(socket);
        return;
    }

    mState = KRNetworkServerStateWaitForName;
    
    mSocket = socket;
    mInStream = [inStream retain];
    mOutStream = [outStream retain];
    
    [self openStreams];    
}

@end


#pragma mark -
#pragma mark Karakuri Network

KRNetwork::KRNetwork(const std::string& gameID)
{
    gKRNetworkInst = this;
    if (gameID.length() > 0) {
        mImpl = (KRNetworkImpl *)[[KRNetworkImpl alloc] initWithGameID:[NSString stringWithCString:gameID.c_str() encoding:NSUTF8StringEncoding]];
    } else {
        mImpl = NULL;
    }
}

KRNetwork::~KRNetwork()
{
    if (mImpl != NULL) {
        [(KRNetworkImpl *)mImpl release];
    }
}

std::list<std::string> KRNetwork::getMessages() throw(KRNetworkError, KRRuntimeError)
{
    if (mImpl == NULL) {
        std::string errorFormat = "You have tried to invoke KRNetwork::getMessages() without setting the game ID.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ゲームIDが設定されていない環境で、KRNetwork::getMessages() 関数が呼ばれました。";
        }
        throw KRRuntimeError(errorFormat);
    }
    if (![(KRNetworkImpl *)mImpl isConnected]) {
        throw KRNetworkError("No connection");
    }
    return [(KRNetworkImpl *)mImpl receivedMessages];
}

bool KRNetwork::isConnected()
{
    if (mImpl == NULL) {
        return false;
    }
    return ([(KRNetworkImpl *)mImpl isConnected]? true: false);
}

void KRNetwork::reset()
{
    if (mImpl == NULL) {
        return;
    }
    return [(KRNetworkImpl *)mImpl reset];
}

std::string KRNetwork::getOwnName() const
{
    if (mImpl == NULL) {
        std::string errorFormat = "You have tried to invoke KRNetwork::getOwnName() without setting the game ID.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ゲームIDが設定されていない環境で、KRNetwork::getOwnName() 関数が呼ばれました。";
        }
        throw KRRuntimeError(errorFormat);
    }
    NSString *ownName = [(KRNetworkImpl *)mImpl ownName];
    return std::string([ownName cStringUsingEncoding:NSUTF8StringEncoding]);
}

int KRNetwork::sendMessage(const std::string& str) throw(KRNetworkError, KRRuntimeError)
{
    if (mImpl == NULL) {
        std::string errorFormat = "You have tried to invoke KRNetwork::sendMessage() without setting the game ID.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ゲームIDが設定されていない環境で、KRNetwork::sendMessage() 関数が呼ばれました。";
        }
        throw KRRuntimeError(errorFormat);
    }
    if (![(KRNetworkImpl *)mImpl isConnected]) {
        throw KRNetworkError("No connection");
    }
    return [(KRNetworkImpl *)mImpl sendMessage:str.c_str()];
}

void KRNetwork::showPeerPicker() throw(KRRuntimeError)
{
    if (mImpl == NULL) {
        std::string errorFormat = "You have tried to invoke KRNetwork::showPeerPicker() without setting the game ID.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ゲームIDが設定されていない環境で、KRNetwork::showPeerPicker() 関数が呼ばれました。";
        }
        throw KRRuntimeError(errorFormat);
    }
    
    [(KRNetworkImpl *)mImpl showPeerPicker];
}

void KRNetwork::doAccept() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    if (mImpl != NULL) {
        [(KRNetworkImpl *)mImpl doAccept];
    }
}

void KRNetwork::doReject() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    if (mImpl != NULL) {
        [(KRNetworkImpl *)mImpl doReject];
    }
}

void KRNetwork::startInvitation(void *peerAddressData, void *peerPickerUI) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    if (mImpl != NULL) {
        [(KRNetworkImpl *)mImpl startInvitation:(NSData *)peerAddressData peerPickerUI:peerPickerUI];
    }
}



