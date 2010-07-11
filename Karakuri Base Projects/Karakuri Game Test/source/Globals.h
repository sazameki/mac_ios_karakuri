/*
 *  Globals.h
 *  Karakuri Game Test
 *
 *  Created by numata on 10/02/13.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#pragma once


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
        LoadingChara,
        Title,
        TitleChara,
    };
};

// Character IDs (IDs are defined in Karakuri Box)
struct CharaID {
    enum {
        Player      = 1000,
        Enemy1      = 1001,
        Explosion   = 1002,
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

struct ParticleID {
    enum {
        Particle1   = 1000,
    };
};

// BGM IDs
struct BGM_ID {
    enum {
        Title,
        Play,
    };
};

// SE IDs
struct SE_ID {
    enum {
        Hit,
    };
};

