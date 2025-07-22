code load-bat-jump-to-entry

\ TODO: make wimg globals

\ disable interrupts

7DC000A6 , \ mfmsr r14
3DE0FFFF , \ lis r15, 0xffff 
61EF7FFF , \ ori r15, r15, 0x7fff
7DCE7838 , \ and r14, r14, r15
7DC00124 , \ mtmsr r14
4C00012C , \ isync

\ r15 <- physical address of main memory

3DE00000 main-memory-paddr l@ 32 14 - rshift or , \ lis r15, 14 upper bits of physical address (assume it's 0x20000-aligned) 

\ invalidate BAT registers

39C00000 , \ li r14, 0
4C00012C , \ isync
7DD083A6 , \ mtibatu 0, r14
7DD883A6 , \ mtdbatu 0, r14
7DD283A6 , \ mtibatu 1, r14
7DDA83A6 , \ mtdbatu 1, r14
7DDC83A6 , \ mtdbatu 2, r14
7DDE83A6 , \ mtdbatu 3, r14
4C00012C , \ isync

\ map 0x80000000 to paddr for 32 MiB

\ todo: figure out WIMG and how i should treat regions supposed to be cached memory

7DEE7B78 , \ mr r14, r15
61CE002A , \ ori r14, r14, 0b0101010 /* WIMG=0b0101, RW */
7DD183A6 , \ mtibatl 0, r14
4C00012C , \ isync
3DC08000 , \ lis r14, 0x8000
61CE03FF , \ ori r14, r14, 0x3ff /* 32 MiB, Vs Vp */
7DD083A6 , \ mtibatu 0, r14
4C00012C , \ isync

7DEE7B78 , \ mr r14, r15
61CE002A , \ ori r14, r14, 0b0101010 /* WIMG=0b0101, RW */
4C00012C , \ isync
7DD983A6 , \ mtdbatl 0, r14
4C00012C , \ isync
3DC08000 , \ lis r14, 0x8000
61CE03FF , \ ori r14, r14, 0x3ff /* 32 MiB, Vs, Vp */
4C00012C , \ isync
7DD883A6 , \ mtdbatu 0, r14
4C00012C , \ isync

\ map 0xc0000000 to paddr for 32 MiB

7DEE7B78 , \ mr r14, r15
61CE0002 , \ ori r14, r14, 0b0000010 /* WIMG=0b0000, RW */
7DD383A6 , \ mtibatl 1, r14
4C00012C , \ isync
3DC0C000 , \ lis r14, 0xc000
61CE03FF , \ ori r14, r14, 0x3ff /* 32 MiB, Vs Vp */
7DD283A6 , \ mtibatu 1, r14
4C00012C , \ isync

7DEE7B78 , \ mr r14, r15
61CE0002 , \ ori r14, r14, 0b0000010 /* WIMG=0b0000, RW */ 
4C00012C , \ isync
7DDB83A6 , \ mtdbatl 1, r14
4C00012C , \ isync
3DC0C000 , \ lis r14, 0xc000
61CE03FF , \ ori r14, r14, 0x3ff /* 32 MiB, Vs Vp */
4C00012C , \ isync
7DDA83A6 , \ mtdbatu 1, r14
4C00012C , \ isync

\ map 0xc8000000 to paddr+32MiB for 2 MiB

3DEF0200 , \ addis r15, r15, 0x200
7DEE7B78 , \ mr r14, r15
61CE002A , \ ori r14, r14, 0b0101010 /* WIMG=0b0101, RW */
4C00012C , \ isync
7DDD83A6 , \ mtdbatl 2, r14
4C00012C , \ isync
3DC0C800 , \ lis r14, 0xc800
61CE003F , \ ori r14, r14, 0x3f /* 2 MiB, Vs Vp */
4C00012C , \ isync
7DDC83A6 , \ mtdbatu 2, r14
4C00012C , \ isync

\ map 0xe0000000 to paddr+34MiB for 256 KiB

3DEF0020 , \ addis r15, r15, 0x20
7DEE7B78 , \ mr r14, r15
61CE002A , \ ori r14, r14, 0b0101010 /* WIMG=0b0101, RW */
4C00012C , \ isync
7DDF83A6 , \ mtdbatl 3, r14
4C00012C , \ isync
3DC0E000 , \ lis r14, 0xe000
61CE0007 , \ ori r14, r14, 7 /* 256 KiB, Vs Vp */
4C00012C , \ isync
7DDE83A6 , \ mtdbatu 3, r14
4C00012C , \ isync

\ enable interrupts

7DC000A6 , \ mfmsr r14
61CE8000 , \ ori r14, r14, 0x8000
7DC00124 , \ mtmsr r14
4C00012C , \ isync

\ load entry point to LR

7DE802A6 , \ mflr r15 /* useless, never returns. just discard lr
3DE00000 dol-entry-point l@ 16 rshift or , \ lis r15, dol-entry-point@ha 
61EF0000 dol-entry-point l@ 0000ffff and or , \ ori r15, dol-entry-point@l
7DE803A6 , \ mtlr r15

\ (for testing, patch entry point to contain b $ as no DOL loading isn't implemented yet) 

48000000 , \ b loop
3DC04800 , \ lis r14, 0x4800
91CF0000 , \ stw 14, 0(15)

\ jump to the game

4E800020 , \ blr


\ loop:
\ 48000000 , \ b loop
end-code
