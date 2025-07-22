\ relevant: https://el.dolphin-emu.org/blog/2016/09/06/booting-the-final-gc-game/?cr=el

\ physical memory:
unselect-dev
create main-memory-paddr 4 allot
create efb-paddr 4 allot
create fake-cache-paddr 4 allot
create ipl-paddr 4 allot
create dummy-hwreg-paddr 4 allot

create uncached-main-memory-vaddr 4 allot
create cached-main-memory-vaddr 4 allot
create efb-vaddr 4 allot
create fake-cache-vaddr 4 allot
create ipl-vaddr 4 allot
create hwreg-vaddr 4 allot
: init-memory-map
  
\ 10000000 01800000 0 claim-physical main-memory-paddr l! \ 80000000
\ 20000000 00200000 0 claim-physical efb-paddr l! \ C8000000
\ 21000000 00004000 0 claim-physical fake-cache-paddr l! \ E0000000
10000000
01800000 00200000 + 00004000 +
20000 claim-physical main-memory-paddr l!

\ restore-memory is supposed to bring back the ofw-created mapping each time the emulator is called by the exception handler.

\ cc800000 9000 unmap

\ TODO: unmap hwreg-vaddr if mapped already

\ dummy-hwreg-paddr l@ hwreg-vaddr l@ 00009000 0 mmu-map
\ no rw rights for non-supervisor; each access to the hardware registers will be handled by the emulator

;
