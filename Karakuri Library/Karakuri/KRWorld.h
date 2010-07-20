//
//  KRWorld.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/23.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KRInput.h>
#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRSaveBox.h>


class KRControlManager;
class KRControl;
class KRButton;
class KRSlider;
class KRSwitch;


typedef struct KRInputSourceData {
    unsigned        frame;
    unsigned char   command[2];
    
    unsigned long long  data_mask;
#if KR_MACOSX
    KRVector2D          location;
#endif
#if KR_IPHONE
    KRVector3D          location;
#endif
} KRInputSourceData;


/*!
    @class KRWorld
    @group  Game System
 
    <p>ロゴ画面、タイトル画面、プレイ画面といった各画面に対応したクラスです。Karakuri Framework では、これを「ワールド」と呼びます。</p>
    <p>現在のワールドから他のワールドに移動する場合には、KRChangeWorld() 関数を使ってください。</p>
    <p>なお、他のワールドへの移動は、updateModel() 関数の処理中にのみ実行できます。</p>
 */
class KRWorld : public KRObject {
    
private:
    std::string         mName;
    KRControlManager*   mControlManager;
    bool                mHasProcessedControl;
    bool                mIsControlProcessDisabled;
    bool                mIsManualControlManagementEnabled;
    bool                mIsLoadingWorld;
    bool                mHasDummyInputSource;
    unsigned                            mDummyInputSourceDataPos;
    std::vector<KRInputSourceData>      mDummyInputSourceDataList;
    bool                mIsShowingLoadingWorld;
    std::vector<int>    mLoadingResourceGroupIDs;
    double              mLoadingResourceMinDuration;
    int                 mLoadingResourceAllSize;
    int                 mLoadingResourceFinishedSize;
    KRWorld*            mResourceLoadingWorld;

public:
    KRWorld();

    /*!
        @task リソースの読み込み
     */

    /*!
        @method hasLoadedResourceGroup
        指定されたグループIDをもつすべてのリソースが読み込まれているかどうかをチェックします。
     */
    bool    hasLoadedResourceGroup(int groupID);

    /*!
        @method loadResourceGroup
        @abstract このワールド内のゲーム実行中に使用するリソースを読み込みます。
        リソースの読み込みに1秒以上の時間がかかる場合には、この関数呼び出しの前後で startLoadingWorld() 関数と finishLoadingWorld() 関数を呼び出して、読み込み画面を表示してください。
     */
    void    loadResourceGroup(int groupID);
    
    /*!
        @method unloadResourceGroup
        @abstract このワールド内で使用したリソースを解放します。
     */
    void    unloadResourceGroup(int groupID);

    /*!
        @task 読み込み画面のサポートのための関数（起動側ワールド）
     */
        
    /*!
        @method finishLoadingWorld
        @abstract 読み込み画面の表示を終了します。
     */
    void    finishLoadingWorld();
    
    /*!
        @method startLoadingWorld
        @abstract 読み込み画面の表示を開始します。この関数の呼び出し後は必ず finishLoadingWorld() 関数を呼び出し、その間では loadResourceGroup() 関数の呼び出し以外の処理は行わないでください。
     */
    void    startLoadingWorld(const std::string& loadingWorldName, double minDuration=2.0);

    /*!
        @task 読み込み画面のサポートのための関数（表示側ワールド）
     */
    
    /*!
        @method getLoadingProgress
        @abstract 現在のリソースの読み込みの進行度合い (0.0〜1.0) を取得します。読み込み画面を表示するためのワールドでのみ使用できます。
     */
    double  getLoadingProgress() const;

    int     _getFinishedSize();
    void    _setFinishedSize(int size);


    void    startBecameActive();
    void    startResignedActive();
    void    startUpdateModel(KRInput* input);
    void    startDrawView(KRGraphics* g);

    /*!
        @task ゲーム実行のためのオーバーライド関数
     */
    
    /*!
        @method becameActive
        このワールドの実行のための初期化（モデルの初期化とマルチメディアリソースの読み込み）を行います。
     */
    virtual void    becameActive() = 0;
    
    /*!
     @method drawView
     このワールド内のゲームモデルを元にして、画面描画を行います。
     */
    virtual void    drawView(KRGraphics* g) = 0;
    
    /*!
        @method resignedActive
        このワールドの実行中に作成したオブジェクトの解放を行います。
     */
    virtual void    resignedActive() = 0;
    
    /*!
        @method updateModel
        このワールド内のゲームモデルの更新を行います。
     */
    virtual void    updateModel(KRInput* input) = 0;

    
    /*!
        @task   緊急終了サポートのためのオーバーライド関数
     */

    /*!
        @method saveForEmergency
        ウィンドウの閉じるボタンを押して終了した場合、iPhone のホームボタンが押された場合、電話コールを受信した場合に対応するために、この関数をオーバーライドして、ゲームの実行状態を保存します。
     */
    virtual void    saveForEmergency(KRSaveBox* saveBox);
    
#pragma mark -
#pragma mark Control Support
public:
    /*!
        @task コントロールのサポート
     */
    
    /*!
        @method addControl
        @abstract 新しいコントロールをこのワールドに追加します。追加されたコントロールは、自動的に解放されます。自分では delete しないように注意してください。
        groupID を指定することで、コントロールのグループを指定できます。デフォルトのグループIDは 0 です。0 以外のグループIDをもつコントロールは、自動的にはユーザ入力の受け付けや描画が行われません。
     */
    void    addControl(KRControl* aControl, int groupID = 0);
    
    /*!
        @method removeControl
        指定されたコントロールを、このワールドから削除します。一度追加されたこのコントロールは、自動的に解放されます。自分では delete しないように注意してください。
     */
    void    removeControl(KRControl* aControl);
    
    /*!
        @method hasProcessedControl
        このワールドに登録されたいずれかのコントロールが、直前にユーザからの入力を受け付けたかどうかを取得します。
     */
    bool    hasProcessedControl() const;
    
    /*!
        @method disableControlProcess
        @abstract コントロールのユーザ入力受け付けを無効化（有効化）します。
        ワールドの開始時には、ユーザ入力受け付けが行われる状態になっています。
     */
    void    disableControlProcess(bool flag);
    
    /*!
        @method enableManualControlManagement
        @abstract 手動でのコントロール処理を有効化（無効化）します。
        手動でのコントロール処理を有効にすると、ユーザ入力の受け付けと描画が自動的に行われないようになります。
        ワールドの開始時には、コントロールの処理が自動的に行われる状態になっています。
     */
    void    enableManualControlManagement(bool flag);

    /*!
        @method isManualControlManagementEnabled
        手動でのコントロール処理が有効化されているかどうかを取得します。
     */
    bool    isManualControlManagementEnabled() const;

    /*!
        @method drawControls
        @abstract コントロールを手動で描画します。
        <p>デフォルトでは groupID が 0 のコントロールを描画しますが、groupID を指定することで、そのグループのコントロールを描画します。</p>
        <p>同じ groupID を共有するコントロールは、領域が重ならないことを前提としています。</p>
     */
    void    drawControls(KRGraphics* g, int groupID = 0);
    
    /*!
        @method processControls
        @abstract コントロールのユーザ入力受け付けを行い、ユーザ入力が処理された場合には true を、そうでなければ false をリターンします。
        <p>デフォルトでは groupID が 0 のコントロールを処理しますが、groupID を指定することで、そのグループのコントロールを処理します。</p>
     */
    bool    processControls(KRInput* input, int groupID = 0);


    /*!
        @task コントロールのサポートのためのオーバーライド関数
     */
    
    /*!
        @method buttonPressed
        このワールドに追加されているボタンが押されたときに呼び出されます。この関数は、updateModel() 関数が呼び出される直前に呼び出されます。
     */
    virtual void    buttonPressed(KRButton* aButton);

    /*!
        @method sliderValueChanged
        このワールドに追加されているスライダの値が変更されたときに呼び出されます。この関数は、updateModel() 関数が呼び出される直前に呼び出されます。
     */
    virtual void    sliderValueChanged(KRSlider* slider);
    
    /*!
        @method switchStateChanged
        このワールドに追加されている ON/OFF スイッチの状態が変更されたときに呼び出されます。この関数は、updateModel() 関数が呼び出される直前に呼び出されます。
     */
    virtual void    switchStateChanged(KRSwitch* switcher);


#pragma mark -
#pragma mark Dummy Input Support
protected:
    /*!
        @task ダミー入力のサポートのための関数
     */
    
    /*!
        @method hasDummyInputSource
        ダミーの入力ソースが設定されているかどうかをリターンします。
     */
    bool    hasDummyInputSource() const;
    
    /*!
        @method hasMoreDummyInputData
        ダミーの入力データが残っているかどうかをリターンします。
     */
    bool    hasMoreDummyInputData() const;
    
    /*!
        @method     listAllInputLogFiles
        @abstract   使用可能なすべてのユーザ入力ログのファイルの一覧を取得します。
        <p>ユーザ入力ログのファイルは、以下の場所から検索されます。</p>
        <ul>
            <li>"~/Library/Application Support/Karakuri/&lt;アプリケーション識別子&gt;/&lt;ゲームのタイトル&gt;/Input Log" フォルダ (Mac OS X / iPhone エミュレータ)</li>
            <li>"&lt;Application_Home&gt;/Documents/Input Log" フォルダ(iPhone)</li>
        </ul>
     */
    std::vector<std::string>    listAllInputLogFiles() const;
    
    /*!
        @method setDummyInputSource
        @abstract このワールドの実行中に使用する入力ソースのファイルを設定します。
        <p>この関数は、becameActive() 関数の中でのみ使用できます。</p>
        <p>ダミーの入力ソースが設定されている間は、ユーザの入力は通常の方法では取得できなくなります。</p>
        <p>入力ソースのファイルは、次のいずれかの場所にある必要があります。</p>
        <ul>
            <li>アプリケーション・バンドルの Resources フォルダ (Mac OS X / iPhone / iPhone エミュレータ)</li>
            <li>"~/Library/Application Support/Karakuri/&lt;アプリケーション識別子&gt;/&lt;ゲームのタイトル&gt;/Input Log" フォルダ (Mac OS X / iPhone エミュレータ)</li>
            <li>"&lt;Application_Home&gt;/Documents/Input Log" フォルダ(iPhone)</li>
        </ul>
     */
    void    setDummyInputSource(const std::string& filename);

    /*!
        @method startInputLog
        @abstract ユーザ入力のログファイルへの書き出しを開始します。
        <p>ログファイルの名前がリターンされます。ログファイルの名前は、システムによって自動的に決定されます。ログファイルの書き出しは、ワールドが切り替わる時点で終了します。</p>
        <p>ログファイルは、環境に応じて次の場所に格納されます。</p>
        <ul>
            <li>"~/Library/Application Support/Karakuri/&lt;アプリケーション識別子&gt;/&lt;ゲームのタイトル&gt;/Input Log" フォルダ (Mac OS X / iPhone エミュレータ)</li>
            <li>"&lt;Application_Home&gt;/Documents/Input Log" フォルダ(iPhone)</li>
        </ul>
        <p>読み込み中画面に使用しているワールドでは、ログファイルへのユーザ入力書き出しはできません。</p>
     */
    std::string startInputLog();
    

public:
    void            setLoadingWorld() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
private:
    void            setResourceLoadingWorld(KRWorld* aWorld) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

#pragma mark -
#pragma mark Debug Support

public:
    std::string     getName() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void            setName(const std::string& str) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    std::string     to_s() const;

};

extern void*    gInputLogHandle KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
extern unsigned gInputLogFrameCounter KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

