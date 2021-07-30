Galaga
======

Arcade Galaga implementation for the MiSTer FPGA

Credits
-------

 * Dar: original Galaga FPGA implementation
 * Daniel Wallner: T80/T80se - Z80 compatible CPU
 * Peter Wendrich: `gen_ram.vhd`
 * Sorgelig: MiSTer port
 * Alan Steremberg: DIP switches, maintenance
 * JimmyStones: Hi-score saving, pause
 * blackwine: Flip-screen, H/V-sync adjustments, full DIP switch mapping, support for nm51xx, low pass filters

Controls
--------

Keyboard inputs:

```
   F2          : Coin + Start 2 players
   F1          : Coin + Start 1 player
   UP,DOWN,LEFT,RIGHT arrows : Movements
   SPACE       : Fire
```

 Joystick support.

Required files
--------------

ROMs are not included. In order to use this arcade, you need to provide the
correct ROMs.

To simplify the process .mra files are provided in the releases folder, that
specifies the required ROMs with checksums. The ROMs .zip filename refers to the
corresponding file of the M.A.M.E. project.

Please refer to
[Arcade ROMS](https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms)
for information on how to setup and use the environment.

Quickreference for folders and file placement:

 * `/_Arcade/<game name>.mra`
 * `/_Arcade/cores/<game rbf>.rbf`
 * `/games/mame/<mame rom>.zip`
 * `/games/hbmame/<hbmame rom>.zip`

Known issues
------------
 * /quote from [MAME sources](https://github.com/mamedev/mame/blob/a32810d97465ae077ece35984a98a92abbf3462f/src/mame/drivers/galaga.cpp#L584-L587)/:
   There is a bug in the sound CPU program.
   During initialization, it enables NMI before clearing RAM, but the NMI
   handler doesn't save the registers, so it cannot interrupt program
   execution. If the NMI happens before the LDIR that clears RAM has finished,
   the program will crash.
 * optional rapid fire board is not implemented.

Easter egg
----------

In service mode with fire button pressed enter the following sequence:
`5xR 6xL 3xR 7xLz`.
[Source](https://github.com/mamedev/mame/blob/a32810d97465ae077ece35984a98a92abbf3462f/src/mame/drivers/galaga.cpp#L555-L559)
