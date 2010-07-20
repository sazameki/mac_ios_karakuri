/*!
    @file   Globals.h
    @author ___FULLUSERNAME___
    @date   ___DATE___

    Defines global constant values for multimedia resources.
 */

#pragma once

#include "GameResourceID.h"


// Group IDs
struct GroupID {
    enum {
        LogoAndLoading  = 0,
        Title           = 1,
        Play            = 2,
    };
};


// Texture IDs
struct TexID {
    enum {
        Logo,
        LoadingText,
        LoadingOff,
        LoadingOn,
        LoadingChara,
        Title,
    };
};

struct CharaType {
    enum {
        Player,
        Enemy
    };
};

struct HitType {
    enum {
        Attack  = 1,
        Block   = 2,
    };
};

// BGM IDs
struct BGM_ID {
    enum {
        Loading,
        Title,
        Play,
    };
};

// SE IDs
struct SE_ID {
    enum {
        Burn,
    };
};

