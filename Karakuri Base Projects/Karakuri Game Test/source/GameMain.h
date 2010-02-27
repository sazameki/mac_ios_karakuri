/*!
    @file   GameMain.h
    @author numata
    @date   10/02/13
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

