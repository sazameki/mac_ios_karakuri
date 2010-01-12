/*!
    @file   KRNetwork.h
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


/*!
    @class KRNetwork
    @group Game Network
    <p>ネットワークを介して、1対1の通信をサポートするためのクラスです。</p>
    <p>gKRNetworkInst 変数を使ってアクセスしてください。</p>
 */
class KRNetwork : public KRObject {
    
private:
    void    *mImpl;
    
public:
    KRNetwork(const std::string& gameID);
    virtual ~KRNetwork();
    
public:
    /*!
        @method getMessages
        通信中のピアから受信したすべてのメッセージを取得します。
     */
    std::list<std::string>  getMessages() throw(KRNetworkError, KRRuntimeError);
    
    /*!
        @method isConnected
        ピアとの通信が保たれているかどうかをチェックします。
     */
    bool                    isConnected();
    
    /*!
        @method reset
        現在のピアとの通信を遮断して、新しいピアの受け入れが可能な状態にリセットします。
     */
    void                    reset();
    
    /*!
        @method sendMessage
        @abstract 通信中のピアに対して、1行分のメッセージを送信します。
        メッセージの終端を示す「\\r\\n」は不要です。メッセージの最大長は128バイトです。ASCII 文字コード以外は送信しないでください。
     */
    int                     sendMessage(const std::string& str) throw(KRNetworkError, KRRuntimeError);
    
    /*!
        @method getOwnName
        ピア上での自分の名前を取得します。
     */
    std::string             getOwnName() const;
    
    /*!
        @method showPeerPicker
        通信相手のピアを選択するためのピッカーを表示します。
     */
    void                    showPeerPicker() throw(KRRuntimeError);
    
public:
    void    doAccept() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    doReject() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
    void    startInvitation(void *peerAddressData, void *peerPickerUI) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

};


/*!
    @var gKRNetworkInst
    @group Game Network
    @abstract 通信クラスのインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRNetwork *gKRNetworkInst;


