# Emul8or

A Chip-8 emulator written in Vala and SDL

![alt tag](https://raw.githubusercontent.com/zesterer/emul8or/master/doc/pong-chip8.png)

## What is Emul8or?

Emul8or is, as the title suggests, a Chip-8 emulator written in the Vala programming language, utilising the SDL library for graphics. It is designed to emulate the Chip-8 and play Chip-8 ROMs.

## What is the 'Chip-8'

From Wikipedia:

> CHIP-8 is an interpreted programming language, developed by Joseph Weisbecker. It was initially used on the COSMAC VIP and Telmac 1800 8-bit microcomputers in the mid-1970s. CHIP-8 programs are run on a CHIP-8 virtual machine. It was made to allow video games to be more easily programmed for said computers.

> Roughly twenty years after CHIP-8 was introduced, derived interpreters appeared for some models of graphing calculators (from the late 1980s onward, these handheld devices in many ways have more computing power than most mid-1970s microcomputers for hobbyists).

## Compiling and running the program

Compilation is easy:

`make build`

Then to execute, simply run:

`./emul8or`

**Warning**

You *may* need to modify your ``/usr/include/SDL/SDL_keysym.h`` file for this to compile. For this reason, I have included in this repository a copy of that file. It has a seperate license to the rest of this repository.

## Usage

Controls are mapped to the number keys, 0-9.

For more information, once compiled run:

`./emul8or --help`

## Installation

To install Emul8or after compilation, run:

`sudo make install`
