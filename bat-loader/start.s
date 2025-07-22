.globl _start
.extern ofw
_start:
lis 9, ofw@ha
ori 9, 9, ofw@l
stw 5, 0(9)

lis 15, 0x1000
ori 15, 15, 0x0000

li 14, 0

isync
mtibatu 0, 14
mtdbatu 0, 14
mtibatu 1, 14
mtdbatu 1, 14

mtdbatu 2, 14
mtdbatu 3, 14
isync

mr 14, 15
ori 14, 14, 0b1000010 /* WIMG=0b1000, RW */
mtibatl 0, 14
isync
lis 14, 0x8000
ori 14, 14, 0b0000001111111111 /* 32 MiB, Vs Vp */
mtibatu 0, 14 
isync

mr 14, 15
ori 14, 14, 0b1000010
isync
mtdbatl 0, 14
isync
lis 14, 0x8000
ori 14, 14, 0b0000001111111111
isync
mtdbatu 0, 14 
isync

mr 14, 15
ori 14, 14, 0b1000010 /* WIMG=0b1000, RW */
mtibatl 1, 14
isync
lis 14, 0xc000
ori 14, 14, 0b0000001111111111 /* 32 MiB, Vs Vp */
mtibatu 1, 14 
isync

mr 14, 15
ori 14, 14, 0b1000010
isync
mtdbatl 1, 14
isync
lis 14, 0xc000
ori 14, 14, 0b0000001111111111
isync
mtdbatu 1, 14 
isync

addis 15, 15, 0x200 /* r15 += 32 MiB */

mr 14, 15
ori 14, 14, 0b1000010 /* WIMG=0b1000, RW */
isync
mtdbatl 2, 14
isync
lis 14, 0xc800
ori 14, 14, 0b0000000000111111 /* 2 MiB, Vs Vp */
isync
mtdbatu 2, 14 
isync

addis 15, 15, 0x20 /* r15 += 2 MiB */

mr 14, 15
ori 14, 14, 0b1000010 /* WIMG=0b1000, RW */
isync
mtdbatl 3, 14
isync
lis 14, 0xe000
ori 14, 14, 0b0000000000000111 /* 256 KiB, Vs Vp */
isync
mtdbatu 3, 14 
isync

loop:
b main 
