\ relevant: https://el.dolphin-emu.org/blog/2016/09/06/booting-the-final-gc-game/?cr=el

\ physical memory:
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
  
\ 24 MiB (MEM1) + 8 MiB of padding (32 MiB mapped in BATs instead of 24 MiB) + 2 MiB (EFB) + 16 KiB (cache) + 240 KiB of padding
\ (256 KiB mapped in BATs instead of 16 KiB)

01800000 00200000 + 00800000 + 00040000 +
20000 \ alignment

claim-physical
main-memory-paddr l!

\ TODO: error if not 0x20000-aligned

\ restore-memory is supposed to bring back the ofw-created mapping each time the emulator is called by the exception handler.

\ cc800000 9000 unmap

\ TODO: unmap hwreg-vaddr if mapped already

\ dummy-hwreg-paddr l@ hwreg-vaddr l@ 00009000 0 mmu-map
\ no rw rights for non-supervisor; each access to the hardware registers will be handled by the emulator

;
