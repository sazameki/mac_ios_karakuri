#!/bin/bash
sudo chown -R root:admin Contents/
sudo chmod -R 775 Contents/

sudo find . -name .DS_Store -exec rm {} ";"
