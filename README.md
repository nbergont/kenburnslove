# kenburnslove
Beautiful Ken Burns slideshow with Love2d (raspberry compatible)  
[![Alt text for your video](https://img.youtube.com/vi/IOrIK-4IhOI/1.jpg)](http://www.youtube.com/watch?v=IOrIK-4IhOI)

## Features
- GPU optimised pan and zoom slideshow (very fluid)
- Use love engine
- Display album title
- Fisher-Yates shuffle
- Customisable

## How to use
- Clone repository
- Add new albums in "pictures" folder
- Put your pictures in album
- Enjoy

## How it work
- Load all album
- Shuffle album list and show each album
- Shuffle pictures and show 10 first pictures

## Windows
- Download love binary : https://love2d.org/
- run "love.exe kenburnslove"

## Raspberry Pi
- Use pilove : http://pilove.mitako.eu/ 
- Or use my customised version of pilove (to upload):
    - Upgraded with pilove 0.4 (LÖVE 0.10.2)
	- Read-only filesystem (more robust)
	- Auto-launch love programm on usb-key
- On Raspberry Pi pictures must have maximum resolution of 4096*4096 (GPU limitation)
