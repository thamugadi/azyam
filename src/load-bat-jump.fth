\ r3 : altered gpr 
\ r4 : paddr 
\ both are volatile registers, they shouldn't interfere with OFW behavior?

\ vs and vp always enabled 
: mask-32-mib 3ff ;
: mask-2-mib 3f ;
: mask-256-kib 7 ;

: wimg-uncached 5 ;
: wimg-cached 0 ;

: pp-rw 2 ;

: asm-disable-interrupts
  7C6000A6 , \ mfmsr r3
  3C80FFFF , \ lis r4, 0xffff 

  60847FFF , \ ori r4, r4, 0x7fff
  7C632038,  \ and r3, r3, r4
  7C600124 , \ mtmsr r3
  4C00012C , \ isync
;

: asm-enable-interrupts
  
  7C6000A6 , \ mfmsr r3
  60638000 , \ ori r3, r3, 0x8000
  7C600124 , \ mtmsr r3
  4C00012C , \ isync
;

: asm-invalidate-bat-registers
  38600000 , \ li r3, 0
  4C00012C , \ isync
  7C7083A6 , \ mtibatu 0, r3
  7C7883A6 , \ mtdbatu 0, r3
  7C7283A6 , \ mtibatu 1, r3
  7C7A83A6 , \ mtdbatu 1, r3
  7C7C83A6 , \ mtdbatu 2, r3
  7C7E83A6 , \ mtdbatu 3, r3
  4C00012C , \ isync
;

: asm-set-brpn ( paddr -- ) \ assumes paddr is 0x20000-aligned
  10 rshift 3C800000 or , \ lis r4, brpn
;

: asm-add-brpn ( n -- )
  3C840000 or , \ addis r4, r4, n
;

: asm-set-ibat ( mask-valid bepi ibat pp wimg -- )
  
  7C832378 , \ mr r3, r4
  
  3 lshift or 60630000 or ,   \ ori r3, r3, WIMG0PP
  dup 11 lshift 7C7183A6 or , \ mtibatl ibat, r3
  4C00012C ,                  \ isync
  swap 3C600000 or ,          \ lis r3, bepi 
  swap 60630000 or ,          \ ori r3, r3, mask-valid 
  11 lshift 7C7083A6 or ,     \ mtibatu ibat, r3
  4C00012C ,                  \ isync

;

: asm-set-dbat ( mask-valid bepi dbat pp wimg -- )
  
  7C832378 , \ mr r3, r4

  3 lshift or 60630000 or ,   \ ori r3, r3, WIMG0PP
  4C00012C ,                  \ isync
  dup 11 lshift 7C7983A6 or , \ mtdbatl dbat, r3
  4C00012C ,                  \ isync
  swap 3C600000 or ,          \ lis r3, bepi 
  swap 60630000 or ,          \ ori r3, r3, mask-valid 
  4C00012C ,                  \ isync
  11 lshift 7C7883A6 or ,     \ mtdbatu dbat, r3
  4C00012C ,                  \ isync
;

code load-bat-jump-to-entry
asm-disable-interrupts
\ r4 <- physical address of main memory
main-memory-paddr l@ asm-set-brpn
asm-invalidate-bat-registers
\ todo: figure out WIMG and how i should treat regions supposed to be cached memory
\ it seems like it crashes with the uncached mapping

\ TODO: make this uncached without it crashing at blr
mask-32-mib 8000 0 pp-rw wimg-cached asm-set-ibat
mask-32-mib 8000 0 pp-rw wimg-cached asm-set-dbat

mask-32-mib c000 1 pp-rw wimg-cached asm-set-ibat
mask-32-mib c000 1 pp-rw wimg-cached asm-set-dbat
200 asm-add-brpn
mask-2-mib c800 2 pp-rw wimg-uncached asm-set-dbat
20 asm-add-brpn
mask-256-kib e000 3 pp-rw wimg-uncached asm-set-dbat
\ load entry point to LR

3C808000 , \ lis r4, dol-entry-point@ha 
60843140 , \ ori r4, r4, dol-entry-point@l

\ (for testing, patch entry point to contain b $ as no DOL loading is implemented yet) 
3C604800 , \ lis r3, 0x4800
90640000 , \ stw r3, 0(r4)

\

7C0020AC , \ dcbf 0, 4
7C0004AC , \ sync
7C0027AC , \ icbi 0, 4
4C00012C , \ isync

\ TODO: invalidate TLB? 0x80000000 was mapped to mac-io

7C8803A6 , \ mtlr r4 

\ TODO: set registers, etc

\ jump to the game

asm-enable-interrupts
4E800020 , \ blr

end-code
