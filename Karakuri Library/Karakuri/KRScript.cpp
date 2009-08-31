/*
 *  KRScript.cpp
 *  Karakuri Library
 *
 *  Created by numata on 09/08/20.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KRScript.h"

#include <Karakuri/lua/lua.h>
#include <Karakuri/lua/lauxlib.h>
#include <Karakuri/lua/lualib.h>


KRScript::KRScript()
{
    mLuaState = lua_open();

    luaL_openlibs((lua_State *)mLuaState);
}

KRScript::~KRScript()
{
    lua_close((lua_State *)mLuaState);
}



