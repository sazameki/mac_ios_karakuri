/*!
    @file   GameMain.h
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#pragma once

#include <Karakuri/Karakuri.h>


class GameMain : public KRGameManager {
    
public:
    GameMain();
    virtual ~GameMain();

    virtual void        setupResources();
    virtual std::string setupWorlds();

};

