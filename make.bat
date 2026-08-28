@echo off
set include=C:\masm32\include
set lib=C:\masm32\lib
set path=C:\masm32\bin;%path%
del version.dll
echo on
ml /c /coff version.asm
link /DLL /subsystem:windows /Dll /section:.bss,S /def:version.def version.obj
del version.exp version.lib version.obj
pause