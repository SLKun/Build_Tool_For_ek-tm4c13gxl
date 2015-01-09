#!/bin/bash

rm -rf stable.zip Stable
wget https://github.com/Summerslyb/Build_Tool_For_ek-tm4c13gxl/archive/stable.zip
7z x stable.zip
rm -rf stable.zip
mv Build_Tool_For_ek-tm4c13gxl-stable Stable
