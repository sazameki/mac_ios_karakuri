//
//  KRGameManager.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRInput.h>
#include <Karakuri/KRWorldManager.h>


class KRControlManager;


/*!
    @enum KRAudioMixType
    @group Game System
    @constant KRAudioMixTypeAmbient         iPhone の iPod の曲再生と、このゲーム独自のサウンド効果をミックスして同時に出力します。
    @constant KRAudioMixTypeAmbientSolo     iPhone の iPod の曲再生を中止し、このゲームのサウンド効果のみを出力します。
    iPhone の iPod の曲再生と、ゲームのサウンド効果のミックス方法を指定するための enum 定数です。
 */
typedef enum KRAudioMixType {
    KRAudioMixTypeAmbient,         //!< Mix iPod audio playback and own sound effects
    KRAudioMixTypeAmbientSolo,     //!< Play own background music and own sound effects
} KRAudioMixType;


#pragma mark -
#pragma mark Game Class Declaration

/*!
    @class  KRGameManager
    @group  Game System
 
    <p>ゲームの実行を制御するための基本機能を提供するクラスです。</p>
    <p>このクラスのインスタンスは、グローバル変数の gKRGameMan を使用して、どこからでもアクセスできます。</p>
 */
class KRGameManager : public KRObject {
    std::string     mTitle;
    double          mFrameRate;
    int             mScreenWidth;
    int             mScreenHeight;
    bool            mWasChangingWorld;
    KRAudioMixType  mAudioMixType;
    KRDeviceType    mDeviceType;
    bool            mShowsMouseCursor;
    bool            mShowsFPS;
    int             mMaxChara2DCount;
    size_t          mMaxChara2DSize;
    
    std::string     mGameIDForNetwork;
    std::string     mNetworkStartWorldName;
    
    KRWorldManager* mWorldManager;


#pragma mark -
#pragma mark Constructor

public:
    KRGameManager();
    ~KRGameManager();


public:
    /*!
        @task ゲーム実行に関する関数
     */

    /*!
        @method     exitGame
        @abstract   ゲームを終了します。
        iPhone 用のアプリケーションは、ホームボタンが押された場合などにのみ終了されるべきという<a href="http://developer.apple.com/iphone/library/qa/qa2008/qa1561.html" target="_blank">ガイドライン</a>があるため、iPhone に対応する場合、この関数の使用は推奨されません。
     */
    void            exitGame();
    
    /*!
        @method     getCurrentTime
        @abstract   現在時刻を秒単位で表す数値をリターンします。
        @return     現在時刻
        @discussion この数値は2001年1月1日 0時00分00秒からの経過時間（秒）となっていますが、基本的には差分をとって利用してください。
     */
    double          getCurrentTime();
    
    /*!
        @method     getFrameRate
        @abstract   ゲームに設定されたフレームレートを取得します。
     */
    double          getFrameRate() const;    

    /*!
        @method		setFrameRate
        @abstract	ゲーム実行のフレームレート (&gt; 0) を設定します。
        デフォルトのフレームレートは、60.0 fps に設定されています。
     */
    void            setFrameRate(double value);

    /*!
        @method     sleep
        @abstract   一定時間スリープさせます。
        @param  interval    スリープさせる時間（秒単位）。
     */
    void            sleep(double interval);

    
    /*!
        @task ワールドに関する関数
     */

    /*!
        @method     addWorld
        @abstract   新しいワールドクラスのインスタンスを、名前を付けて登録します。
     */
    void            addWorld(const std::string& name, KRWorld* aWorld);

    /*!
        @method     changeWorld
        @abstract   指定された名前で登録されたワールドを、次フレームからの実行対象に選択します。
        @param  name    ワールドの登録名
     */
    void            changeWorld(const std::string& name);

    /*!
        @method     getCurrentWorld
        @abstract   現在選択されているワールドを取得します。
        @return     現在選択されているワールド
     */
    KRWorld*        getCurrentWorld() const;

    /*!
        @method getWorld
        @abstract 名前を指定して登録されたワールドを取得します。 
     */
    KRWorld*        getWorld(const std::string& name) const;


public:
    /*!
        @task ゲームのセットアップ
     */

    /*!
        @method loadResourceGroup
        @abstract 指定されたIDをもつリソース群を読み込みます。
        @param groupID  読み込む対象のリソース群を表す ID
     */
    void    loadResourceGroup(int groupID);

    /*!
        @method setupResources
        @abstract ゲーム実行に必要なリソース（画像、音）を宣言するために、ゲーム起動直後に呼ばれます。
     */
    virtual void        setupResources();
    
    /*!
        @method setupWorlds
        @abstract ゲーム実行に必要なワールドを追加するために、ゲーム起動直後に呼ばれます。
     */
    virtual std::string setupWorlds() = 0;


    void    cleanUpGame();
    void    updateModel(KRInput* input);
    void    drawView(KRGraphics* g);
    
    
public:
    /*!
        @task 状態を取得するための関数
     */

    bool            _checkDeviceType(KRDeviceType type) const;    

    /*!
        @method getAudioMixType
        @abstract 設定されたオーディオ再生の方法を取得します。
     */
    KRAudioMixType  getAudioMixType() const;
    
    /*!
        @method     getGameIDForNetwork
     */
    std::string     getGameIDForNetwork() const;
    
    /*!
        @method     getMaxChara2DCount
        2Dアニメーション機構で使用する最大のキャラクタ個数を取得します。
     */
    int             getMaxChara2DCount() const;
    
    size_t          getMaxChara2DSize() const;

    /*!
        @method     getNetworkStartWorldName
     */
    std::string     getNetworkStartWorldName() const;
    
    /*!
        @-method     getScreenHeight
        @abstract   ゲームに設定された画面サイズの高さを取得します。
     */
    int             getScreenHeight() const;

    /*!
        @method     getScreenSize
        @abstract   ゲームに設定された画面サイズを取得します。
     */
    KRVector2D      getScreenSize() const;

    /*!
        @-method     getScreenWidth
        @abstract   ゲームに設定された画面サイズの横幅を取得します。
     */
    int             getScreenWidth() const;

    /*!
        @method     getShowsFPS
        @abstract   現在の FPS 情報をデバッグ用に表示するようになっているかどうかを取得します。
     */
    bool            getShowsFPS() const;

    /*!
        @method     getShowsMouseCursor
        @abstract   ゲームウィンドウ内にマウスカーソルが乗っているときに、Mac OS X 標準のマウスカーソルを表示するかどうかを取得します。
     */
    bool            getShowsMouseCursor() const;

    /*!
        @method     getTitle
        @abstract   ゲームに設定されたタイトル文字列を取得します。
     */
    std::string     getTitle() const;

protected:
    /*!
        @task コンストラクタの中でだけ使用できる関数
     */

    void            addResources(const std::string& filename);
    
    /*!
        @method		setAudioMixType
        @abstract	オーディオ再生の方法を設定します。
        デフォルトでは KRAudioMixTypeAmbientSolo が設定されています。
     */
    void            setAudioMixType(KRAudioMixType type);
    
    /*!
        @method     setMaxChara2DCount
        2Dアニメーション機構で使用する最大のキャラクタ個数を設定します。デフォルトの個数は256個です。
        この個数には、パーティクル用のキャラクタも含まれることに留意してください。
     */
    void            setMaxChara2DCount(int count);
    
    /*!
        @method		setNetworkGameID
        @abstract   ネットワーク対応のための識別子を設定します。
        ネットワーク上でこのゲームを識別するための識別子と、ネットワークのピア通信開始時にアクティブになるワールドの名前を指定します。識別子には、英数字（a-zA-Z0-9）とアンダーバー (_) のみを用いてください。
     */
    void            setNetworkGameID(const std::string& gameID, const std::string& startWorldName);
    
    /*!
        @method     setScreenSize
        @abstract   ゲーム画面のサイズを設定します。
        iPhone 環境では、(480, 320) あるいは (320, 480) のみが指定できます。(480, 320) を指定した場合には横方向で使用するモードになり、(320, 480) を指定した場合には縦方向で使用するモードになります。
     */
    void            setScreenSize(int width, int height);
    
    /*!
        @method     setShowsFPS
        @abstract   デバッグ用の FPS 情報の表示／非表示を設定します。
        FPS 情報は、Debug ビルドの環境でのみ表示されます。
     */
    void            setShowsFPS(bool flag);
    
    /*!
        @method		setShowsMouseCursor
        @abstract	マウスカーソルの表示／非表示を設定します。
        Mac OS X 環境での実行にのみ影響します。
     */
    void            setShowsMouseCursor(bool flag);
    
    /*!
        @method     setTitle
        @abstract   ゲームのタイトルを設定します。
        設定されたタイトルは、Mac OS X 環境のウィンドウのタイトルバーや、警告メッセージのタイトルなどに使用されます。
     */
    void            setTitle(const std::string& str);
    
    void            updateMaxChara2DSize(size_t size);
    
    
public:
    void            _changeWorldImpl(const std::string& name, bool useLoadingThread = true, bool isFirstInitialization = false) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void            _startWorldChanging() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void            _checkDeviceType() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
public:
    void            _saveForEmergency() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;


#pragma mark -
#pragma mark Debug Support

public:
    std::string     to_s() const;

};


class KRGame : public KRGameManager {
};


/*!
    @var    gKRGameMan
    @group  Game System
    @abstract ゲームのインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRGameManager*   gKRGameMan;


// 後方互換のための以前のゲームマネージャ変数
extern KRGameManager*   gKRGameInst;


/*!
    @var    gKRScreenSize
    @group  Game System
    ゲームの画面サイズを示す変数です。
 */
extern KRVector2D   gKRScreenSize;

