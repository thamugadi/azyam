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
\ no ipl region

\ TODO!!! change the permissions to make hwregs non-r and non-w in supervisor mode
  
01800000 1000 claim-physical main-memory-paddr l!
00200000 1000 claim-physical efb-paddr l!
00004000 1000 claim-physical fake-cache-paddr l!
00009000 1000 claim-physical dummy-hwreg-paddr l! \ dummy memory region to be mapped to hwreg vaddr 

\ virtual memory (temporary mapping, to be changed by the page table loader)
\ can't be set to the actual gamecube locations while still interacting with openfirmware, as mac-io is mapped to 0x80000000

\ TODO: add error handling. 

70000000 01800000 0 claim-virtual uncached-main-memory-vaddr l! \ should be 80000000
d0000000 01800000 0 claim-virtual cached-main-memory-vaddr l! \ should be c0000000
d8000000 00200000 0 claim-virtual efb-vaddr l! \ should be c8000000
e0000000 00004000 0 claim-virtual fake-cache-vaddr l! 

dc000000 00009000 0 claim-virtual hwreg-vaddr l! \ hardware registers (more than necessary) (should be cc000000)

\ PTL will change the memory mapping below to match the actual gamecube memory map.
\ PTL will have to swap SR8 with SR7 and SR12 with SR13

\ restore-memory is supposed to bring back the ofw-created mapping each time the emulator is called by the exception handler.

main-memory-paddr l@ uncached-main-memory-vaddr l@ 01800000 2 mmu-map
main-memory-paddr l@ cached-main-memory-vaddr l@ 01800000 2 mmu-map
efb-paddr l@ efb-vaddr l@ 00200000 2 mmu-map
fake-cache-paddr l@ fake-cache-vaddr l@ 00004000 2 mmu-map

dummy-hwreg-paddr l@ hwreg-vaddr l@ 00009000 0 mmu-map
\ no rw rights for non-supervisor; each access to the hardware registers will be handled by the emulator

;
