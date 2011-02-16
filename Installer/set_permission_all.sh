#!/bin/bash

sudo sleep 0

echo File Tempaltes
cd File\ Template
./set_permission.sh

echo Project Tempaltes
cd ../Project\ Template
./set_permission.sh

echo Karakuri Library
cd ../Karakuri\ Library
./set_permission.sh

echo Scripts
cd ../Scripts
./set_permission.sh
