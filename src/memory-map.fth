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

01800000 1 claim-physical main-memory-paddr l!
00200000 1 claim-physical efb-paddr l!
00004000 1 claim-physical fake-cache-paddr l!
00100000 1 claim-physical ipl-paddr l! 

00009000 1 claim-physical dummy-hwreg-paddr l! \ dummy memory region to be mapped to hwreg vaddr 

\ virtual memory (temporary mapping, to be changed by the page table loader)
\ can't be set to the actual gamecube locations while still interacting with openfirmware, as mac-io is mapped to 0x80000000

01800000 1 claim-virtual uncached-main-memory-vaddr l!
01800000 1 claim-virtual cached-main-memory-vaddr l!
00200000 1 claim-virtual efb-vaddr l!
00004000 1 claim-virtual fake-cache-vaddr l! 
00100000 1 claim-virtual ipl-vaddr l! 

00009000 1 claim-virtual hwreg-vaddr l! \ hardware registers (more than necessary)

\ PTL will, if necessary, access the global variables defined above.
\ PTL will change the memory mapping below to match the actual gamecube memory map.

\ restore-memory is supposed to bring back the ofw-created mapping each time the emulator is called by the exception handler.

main-memory-paddr l@ uncached-main-memory-vaddr l@ 01800000 2 mmu-map
main-memory-paddr l@ cached-main-memory-vaddr l@ 01800000 2 mmu-map
efb-paddr l@ efb-vaddr l@ 00200000 2 mmu-map
fake-cache-paddr l@ fake-cache-vaddr l@ 00004000 2 mmu-map
ipl-paddr l@ ipl-vaddr l@ 00100000 2 mmu-map

dummy-hwreg-paddr l@ hwreg-vaddr l@ 00009000 0 mmu-map
