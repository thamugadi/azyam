\ relevant: https://hitmen.c02.at/files/yagcd/yagcd/chap4.html
\ https://el.dolphin-emu.org/blog/2016/09/06/booting-the-final-gc-game/?cr=el

\ physical memory:
create main-memory-paddr 4 allot

: init-memory-map
  
\ 24 MiB (MEM1) + 8 MiB of padding (32 MiB mapped in BATs instead of 24 MiB) + 2 MiB (EFB) + 16 KiB (cache) + 240 KiB of padding
\ (256 KiB mapped in BATs instead of 16 KiB)

01800000 00200000 + 00800000 + 00040000 +
20000 \ alignment

claim-physical
main-memory-paddr l!

\ restore-memory is supposed to bring back the ofw-created mapping each time the emulator is called by the exception handler.

cc800000 9000 mmu-unmap

\ TODO: unmap hwreg-vaddr if mapped already

;
