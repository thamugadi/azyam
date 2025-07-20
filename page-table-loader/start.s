.globl _start
.extern ofw
_start:
lis 9, ofw@ha
ori 9, 9, ofw@l
stw 5, 0(9)

/* enables interrupts*/
mfmsr 22
ori 22, 22, 0x8000
mtmsr 22
isync

/* swaps SR8 with SR7, and SR12 with SR13 (see memory-map.fth for details)*/
/*mfsr 22, 8
mfsr 23, 7
mtsr 8, 23
mtsr 7, 22
mfsr 22, 13
mfsr 23, 12
mtsr 13, 23
mtsr 12, 22*/
loop:
b main 
