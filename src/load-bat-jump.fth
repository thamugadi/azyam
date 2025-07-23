
\ r14 : altered gpr 
\ r15 : bepi

\ vs and vp always enabled 
: mask-32-mib 3ff ;
: mask-2-mib 3f ;
: mask-256-kib 7 ;

: wimg-uncached 5 ;
: wimg-cached 0 ;

: pp-rw 2 ;

: asm-disable-interrupts
  7DC000A6 , \ mfmsr r14
  3DE0FFFF , \ lis r15, 0xffff 
  61EF7FFF , \ ori r15, r15, 0x7fff
  7DCE7838 , \ and r14, r14, r15
  7DC00124 , \ mtmsr r14
  4C00012C , \ isync
;

: asm-enable-interrupts
  
  7DC000A6 , \ mfmsr r14
  61CE8000 , \ ori r14, r14, 0x8000
  7DC00124 , \ mtmsr r14
  4C00012C , \ isync
;

: asm-invalidate-bat-registers
  39C00000 , \ li r14, 0
  4C00012C , \ isync
  7DD083A6 , \ mtibatu 0, r14
  7DD883A6 , \ mtdbatu 0, r14
  7DD283A6 , \ mtibatu 1, r14
  7DDA83A6 , \ mtdbatu 1, r14
  7DDC83A6 , \ mtdbatu 2, r14
  7DDE83A6 , \ mtdbatu 3, r14
  4C00012C , \ isync
;

: asm-set-bepi ( bepi -- ) \ assumes paddr is 0x20000-aligned
  16 rshift 3DE00000 or , \ lis r15, bepi 
;

: asm-add-bepi ( n - )
  3DEF0000 or , \ addis r15, r15, n 
;

: asm-set-ibat ( mask-valid brpn ibat pp wimg -- )
  
  7DEE7B78 , \ mr r14, r15
  
  3 lshift or 61CE0000 or ,   \ ori r14, r14, WIMG0PP
  dup 11 lshift 7DD183A6 or , \ mtibatl ibat, r14
  4C00012C ,                  \ isync
  swap 3DC00000 or ,          \ lis r14, brpn 
  swap 61CE0000 or ,          \ ori r14, r14, mask-valid 
  11 lshift 7DD083A6 or ,     \ mtibatu ibat, r14
  4C00012C ,                  \ isync

;

: asm-set-dbat ( mask-valid brpn ibat pp wimg -- )
  
  7DEE7B78 , \ mr r14, r15

  3 lshift or 61CE0000 or ,        \ ori r14, r14, WIMG0PP
  4C00012C ,                       \ isync
  dup 11 lshift 7DD983A6 or , \ mtdbatl dbat, r14
  4C00012C ,                       \ isync
  swap 3DC00000 or ,               \ lis r14, brpn
  swap 61CE0000 or ,               \ ori r14, r14, mask-valid 
  4C00012C ,                       \ isync
  11 lshift 7DD883A6 or ,     \ mtdbatu dbat, r14
  4C00012C ,                       \ isync
;
code load-bat-jump-to-entry
asm-disable-interrupts
\ r15 <- physical address of main memory
main-memory-paddr l@ asm-set-bepi
asm-invalidate-bat-registers
\ todo: figure out WIMG and how i should treat regions supposed to be cached memory
mask-32-mib 8000 0 pp-rw wimg-uncached asm-set-ibat
mask-32-mib 8000 0 pp-rw wimg-uncached asm-set-dbat
mask-32-mib c000 1 pp-rw wimg-cached asm-set-ibat \ idk if the cached mapping is appropriate
mask-32-mib c000 1 pp-rw wimg-cached asm-set-dbat
200 asm-add-bepi
mask-2-mib c800 2 pp-rw wimg-uncached asm-set-dbat
20 asm-add-bepi
mask-256-kib e000 3 pp-rw wimg-uncached asm-set-dbat
\ asm-enable-interrupts

\ load entry point to LR

\ 7DE802A6 , \ mflr r15 /* useless, never returns. just discard lr
3DE00000 dol-entry-point l@ 10 rshift or , \ lis r15, dol-entry-point@ha 
61EF0000 dol-entry-point l@ 0000ffff and or , \ ori r15, dol-entry-point@l
7DE803A6 , \ mtlr r15

\ (for testing, patch entry point to contain b $ as no DOL loading isn't implemented yet) 

3DC04800 , \ lis r14, 0x4800
91CF0000 , \ stw 14, 0(15)

\ jump to the game

4E800020 , \ blr \ seems to crash? todo: fix it
end-code
