@version 1.0

# キャラクタ 0
chara: 0, player.png, (40, 32)
    state: 0 (interval=4, repeat=ever)
        image: 0, 0
        image: 1, 0
        image: 2, 0

    state: 1 (interval=4, repeat=ever)
        back-to: 0, 2
        image: 3, 0
        image: 4, 0 *
        image: 5, 0

    state: 2 (interval=4, repeat=ever)
        back-to: 0, 1
        image: 6, 0
        image: 7, 0 *
        image: 8, 0

# キャラクタ 1
chara: 1, chara.png, (50, 50)
