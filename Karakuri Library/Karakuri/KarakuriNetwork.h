/*!
    @file   KarakuriNetwork.h
    @author numata
    @date   09/08/18
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>
#include <Karakuri/KarakuriException.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>


class KarakuriNetwork {
    
private:
    void    *mImpl;
    
public:
    KarakuriNetwork(const std::string& gameID);
    virtual ~KarakuriNetwork();
    
public:
    std::list<std::string>  getMessages() throw(KRNetworkError, KRRuntimeError);
    bool                    isConnected();
    void                    reset();
    int                     sendMessage(const std::string& str) throw(KRNetworkError, KRRuntimeError);
    
    std::string             getOwnName() const;
    
    void                    showPeerPicker() throw(KRRuntimeError);
    
public:
    void    doAccept() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    doReject() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
    void    startInvitation(void *peerAddressData, void *peerPickerUI) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

};


extern KarakuriNetwork *KRNetwork;


