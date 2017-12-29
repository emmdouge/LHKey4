
@echo off
SET PATH=%PATH%;
cd ..\tools

 
%ComSpec% /c "scd . && pushd . && %WDK%\bin\setenv %WDK% fre x64 WIN7 no_oacr && popd && build"

PAUSE