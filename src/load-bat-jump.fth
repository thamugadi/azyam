\ r3 : altered gpr 
\ r4 : paddr 
\ both are volatile registers, they shouldn't interfere with OFW behavior?

\ vs and vp always enabled 

: mask-32-mib-vs-vp 3ff ;
: mask-2-mib-vs-vp 3f ;
: mask-256-kib-vs-vp 7 ;

: wimg-uncached-dbat 5 ;
: wimg-uncached-ibat 4 ;
: wimg-cached 0 ;

: pp-rw 2 ;

: asm-disable-interrupts
  7C6000A6 , \ mfmsr r3
  3C80FFFF , \ lis r4, 0xffff 

  60847FFF , \ ori r4, r4, 0x7fff
  7C632038 , \ and r3, r3, r4
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

\ i have to do this trick, because the code depends on dol-entry-point whose value is not available at compile time
\ TODO? find a better trick?

code load-bat-jump-to-entry 400 allot end-code \ MAX SIZE: 256 instructions

: compile-load-bat-jump-to-entry
here ['] load-bat-jump-to-entry over - allot

\ now what's going to be specified with ',' is located at the beginning of load-bat-jump-to-entry

\ r4 <- physical address of main memory
asm-disable-interrupts
main-memory-paddr l@ asm-set-brpn
asm-invalidate-bat-registers
\ todo: figure out WIMG and how i should treat regions supposed to be cached memory

\ note that 0x80000000 region is mapped to mac-io through page tables; those BATs are overriding this mapping
\ https://hitmen.c02.at/files/yagcd/yagcd/chap4.html

mask-32-mib-vs-vp 8000 0 pp-rw wimg-uncached-ibat asm-set-ibat
mask-32-mib-vs-vp 8000 0 pp-rw wimg-uncached-dbat asm-set-dbat

mask-32-mib-vs-vp c000 1 pp-rw wimg-cached asm-set-ibat
mask-32-mib-vs-vp c000 1 pp-rw wimg-cached asm-set-dbat
200 asm-add-brpn
mask-2-mib-vs-vp c800 2 pp-rw wimg-uncached-dbat asm-set-dbat
20 asm-add-brpn
mask-256-kib-vs-vp e000 3 pp-rw wimg-uncached-dbat asm-set-dbat

asm-enable-interrupts
 
3C600000 dol-entry-point l@ 10 rshift or , \ lis r3, dol-entry-point@ha
60630000 dol-entry-point l@ 0000ffff and or , \ ori r3, r3, dol-entry-point@l

\ (for testing, this patches entry point to contain framebuffer-altering code as no DOL loading is implemented yet) 
\ TODO: test cached code

7C651B78 , \ mr r5, r3
3C803C60 , \ lis r4, 0x3C60
frame-buffer-adr 10 rshift 60840000 or , \ ori r4, r4, frame-buffer-adr@ha 
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C806063 , \ lis r4, 0x6063
frame-buffer-adr 0000ffff and 60840000 or , \ ori r4, r4, frame-buffer-adr@l 
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C803C80 , \ lis r4, 0x3c80
frame-buffer-adr 10 rshift 300 + 60840000 or , \ ori r4, r4, frame-buffer-adr@ha + 0x300
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C806084 , \ lis r4, 0x6084
60840000 , \ ori r4, r4, 0
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C8038A0 , \ lis r4, 0x38a0
60840021 , \ ori r4, r4, 0x21
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C8098A3 , \ lis r4, 0x98a3
60840000 , \ ori r4, r4, 0
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C803863 , \ lis r4, 0x3863
60840001 , \ ori r4, r4, 1
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C807C03 , \ lis r4, 0x7c03
60842040 , \ ori r4, r4, 0x2040
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C804180 , \ lis r4, 0x4180
6084FFF4 , \ ori r4, r4, 0xfff4
90830000 , \ stw r4, 0(r3)
38630004 , \ addi r3, r3, 4
3C804E80 , \ lis r4, 0x4e80
60840020 , \ ori r4, r4, 0x20
90830000 , \ stw r4, 0(r3)

38630004 , \ addi r3, r3, 4

3C804800 , \ lis r4, 0x4800
90830000 , \ stw r4, 0(r3)
7CA803A6 , \ mtlr r5 

\ TODO: set registers, etc
\ jump to the game

4E800020 , \ blr

here ['] load-bat-jump-to-entry - allot 

;
