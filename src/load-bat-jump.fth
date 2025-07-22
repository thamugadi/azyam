code load-bat-jump-to-entry

\ disable interrupts

7DC000A6 , \ mfmsr r14
3DE0FFFF , \ lis r15, 0xffff 
61EF7FFF , \ ori r15, r15, 0x7fff
7DCE7838 , \ and r14, r14, r14
7DC00124 , \ mtmsr r14
4C00012C , \ isync

\ r15 <- physical address

3DE01000 , \ lis r15, 0x1000
61EF0000 , \ ori r15, r15, 0

\ set BAT registers

39C00000 , \ li r14, 0
4C00012C , \ isync
7DD083A6 , \ mtibatu 0, r14
7DD883A6 , \ mtdbatu 0, r14
7DD283A6 , \ mtibatu 1, r14
7DDA83A6 , \ mtdbatu 1, r14
7DDC83A6 , \ mtdbatu 2, r14
7DDE83A6 , \ mtdbatu 3, r14
4C00012C , \ isync
7DEE7B78 , \ mr r14, r15
61CE0042 , \ ori r14, r14, 0x42
7DD183A6 , \ mtibatl 0, r14
4C00012C , \ isync
3DC08000 , \ lis r14, 0x8000
61CE03FF , \ ori r14, r14, 0x3ff
7DD083A6 , \ mtibatu 0, r14
4C00012C , \ isync
7DEE7B78 , \ mr r14, r15
61CE0042 , \ ori r14, r14, 0x42
4C00012C , \ isync
7DD983A6 , \ mtdbatl 0, r14
4C00012C , \ isync
3DC08000 , \ lis r14, 0x8000
61CE03FF , \ ori r14, r14, 0x3ff
4C00012C , \ isync
7DD883A6 , \ mtdbatu 0, r14
4C00012C , \ isync
7DEE7B78 , \ mr r14, r15
61CE0042 , \ ori r14, r14, 0x42
7DD383A6 , \ mtibatl 1, r14
4C00012C , \ isync
3DC0C000 , \ lis r14, 0xc000
61CE03FF , \ ori r14, r14, 0x3ff
7DD283A6 , \ mtibatu 1, r14
4C00012C , \ isync
7DEE7B78 , \ mr r14, r15
61CE0042 , \ ori r14, r14, 0x42
4C00012C , \ isync
7DDB83A6 , \ mtdbatl 1, r14
4C00012C , \ isync
3DC0C000 , \ lis r14, 0xc000
61CE03FF , \ ori r14, r14, 0x3ff
4C00012C , \ isync
7DDA83A6 , \ mtdbatu 1, r14
4C00012C , \ isync
3DEF0200 , \ addis r15, r15, 0x200
7DEE7B78 , \ mr r14, r15
61CE0042 , \ ori r14, r14, 0x42
4C00012C , \ isync
7DDD83A6 , \ mtdbatl 2, r14
4C00012C , \ isync
3DC0C800 , \ lis r14, 0xc800
61CE003F , \ ori r14, r14, 0x3f
4C00012C , \ isync
7DDC83A6 , \ mtdbatu 2, r14
4C00012C , \ isync
3DEF0020 , \ addis r15, r15, 0x20
7DEE7B78 , \ mr r14, r15
61CE0042 , \ ori r14, r14, 0x42
4C00012C , \ isync
7DDF83A6 , \ mtdbatl 3, r14
4C00012C , \ isync
3DC0E000 , \ lis r14, 0xe000
61CE0007 , \ ori r14, r14, 7
4C00012C , \ isync
7DDE83A6 , \ mtdbatu 3, r14
4C00012C , \ isync

\ enable interrupts

7DC000A6 , \ mfmsr r14
61CE8000 , \ ori r14, r14, 0x8000
7DC00124 , \ mtmsr r14
4C00012C , \ isync

\ loop:
48000000 , \ b loop

\ todo: jump to entry point 

end-code
