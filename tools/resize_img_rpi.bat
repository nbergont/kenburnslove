@echo off
set root=%cd%
:treeProcess
%root%\magick.exe mogrify -resize 2048x2048 -monitor List *.jpg
for /f "delims=" %%i in ('dir /ad/s/b') do (
	cd %%i
	call :treeProcess
	cd ..
)