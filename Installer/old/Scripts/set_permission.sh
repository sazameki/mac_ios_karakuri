#!/bin/bash

cd Contents

sudo chown -R root:admin *
sudo chmod -R 775 *

sudo find . -name .DS_Store -exec rm {} ";"
