.globl _start
.extern ofw
_start:
lis 9, ofw@ha
ori 9, 9, ofw@l
stw 5, 0(9)

/*tfi int*/
/* NOTE: interrupts are turned off, and we are in virtual mode now */
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
ori 14, 14, 0b0000000111111111 /* 16 MiB, Vs Vp */
mtibatu 0, 14 
isync

mr 14, 15
ori 14, 14, 0b1000010
isync
mtdbatl 0, 14
isync
lis 14, 0x8000
ori 14, 14, 0b0000000111111111
isync
mtdbatu 0, 14 
isync

mr 14, 15
ori 14, 14, 0b1000010
mtibatl 1, 14
isync
lis 14, 0x8000
ori 14, 14, 0b0000000011111111
mtibatu 1, 14 
isync

mr 14, 15
ori 14, 14, 0b1000010
isync
mtdbatl 1, 14
isync
lis 14, 0x8000
ori 14, 14, 0b0000000011111111
isync
mtdbatu 1, 14 
isync

/* TODO:
paddr = the address present in register 15
- IBAT0 to map 80000000 to paddr for 32 MiB (not enough BAT regs for 16 MiB & 8 MiB ones)
- DBAT0 to map 80000000 to paddr for 32 MiB

- IBAT1 to map c0000000 to paddr for 32 MiB
- DBAT1 to map c0000000 to paddr for 32 MiB

- DBAT2 to map c8000000 to paddr+32MiB for 2MiB

- DBAT4 to map e0000000 to paddr+34MiB for 256 KiB
*/

loop:
b main 
