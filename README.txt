---------------------------------------------------------------------------------
-- 
-- Arcade: Galaga port to MiSTer by Sorgelig
-- 23 October 2017
-- 
---------------------------------------------------------------------------------
-- Galaga Midway by Dar (darfpga@aol.fr) (29 December 2016)
-- http://darfpga.blogspot.fr
---------------------------------------------------------------------------------
-- gen_ram.vhd
-------------------------------- 
-- Copyright 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
---------------------------------------------------------------------------------
-- T80/T80se - Version : 0247
-----------------------------
-- Z80 compatible microprocessor core
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
---------------------------------------------------------------------------------
-- 
-- Support screen and controls rotation on HDMI output.
-- Only controls are rotated on VGA output.
-- 
-- 
-- Keyboard inputs :
--
--   F2          : Coin + Start 2 players
--   F1          : Coin + Start 1 player
--   UP,DOWN,LEFT,RIGHT arrows : Movements
--   SPACE       : Fire  
--
-- Joystick support.
-- 
-- 
---------------------------------------------------------------------------------

                                *** Attention ***

ROM is not included. In order to use this arcade, you need to provide a correct ROM file.

1) Put bat and 7za.exe files from releases folder into the same folder on PC.

2) Execute bat file - it will show the name of zip file containing required files.

3) Find this zip file somewhere. You need to find the file exactly as required.
   Do not rename other zip files even if they also replresent the same game - they are not compatible!
   The name of zip is taken from M.A.M.E. project, so you can get more info about
   hashes and contained files there.

4) Put required zip into the same folder and execute the bat again.

5) If everything will go without errors or warnings, then you will get the rom file.

6) Place the rom file into root of SD card.
