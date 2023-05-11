# aoc_ti83p
Ti83+ Calculator ASM Solutions for [Advent of Code 2022](https://adventofcode.com/2022)

## Prerequisites
* `make`
* [`spasm-ng`](https://github.com/alberthdev/spasm-ng)
* A TI83+ calculator or emulator (e.g., <https://www.cemetech.net/projects/jstified/>)
* A way of uploading files to the calculator/emulator
* Python3
* `m4` (optional, I include the `.z80` files generated from the `.m4` files; may or may not be general `m4` compatible, I use the GNU version)

## Files
* `Makefile` (basic makefile, includes `make` to create `.8xs` files from `.input` files and `.8xp` files from `.z80` files)
* `conventions` (some basic ASM conventions for this repo to have the assembly be slightly more readable)
* `*.z80` asm programs
* `*.input` input files

## Running
* Copy input to `day{n}.input`
* Run `make`
* Copy `day{n}p{x}.8xp` and `day{n}.8xs` to calculator
* On the calculator, run the corresponding ASM program (`2nd + Catalog -> Asm(` then `PRGM -> Exec -> DAYNPX`)
