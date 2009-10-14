#!/bin/bash

cd Contents

sudo chown -R root:wheel Karakuri/
sudo chmod -R 755 Karakuri/

sudo chown -R root:admin Karakuri/images/Control\ Images/
sudo chmod -R 775 Karakuri/images/Control\ Images/

sudo find . -name .DS_Store -exec rm {} ";"
