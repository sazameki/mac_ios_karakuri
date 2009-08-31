#!/bin/bash

cd Contents

sudo chown -R root:admin Karakuri/
sudo chmod -R 775 Karakuri/

sudo find . -name .DS_Store -exec rm {} ";"
