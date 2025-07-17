: page-loader-location " :2,\boot\page-table-loader.elf" ;
." main" cr

\ loads the page table loader
" load &device;" encode-bytes
page-loader-location encode-bytes
encode+
evaluate
" loaded the page table loader at 0x" encode-bytes
load-base (u.) encode-bytes 
encode+
type cr

dev /aliases
.properties
dev /
." enter the disk device path:" cr

\ stores the disk device path as a string, as well as its size
disk-device-path 100 accept
disk-device-path-size l!
cr

\ allocate memory, the mapping is to be replaced by page table loader
init-memory-map

\ TODO: load DOL 

\ TODO: store globals about the DOL for the page table loader

\ TODO: write PS instructions patcher and patch paired single instrs

\ TODO: write hardware handler. a call to it is going to be inserted at the place of the instruction that attempted once to access hwregs
\       note that it will also handle the case where that instruction might not access to an hwreg, if executed in another execution flow
\       prior to its execution, it's going to unset the "gc" flag and restore the original page tables.  

\ TODO: write hwreg access patcher (responsible for doing the patching mentioned above after each exception subsequent to a hwreg access)
\       and redirect memory faults to it 

\ TODO: patch the external interrupt handlers to emulate, if necessary, an input that is going to be handled by the gamecube's external
\       interrupt handler. this only if the game is actually running, will check a flag for that.

\ TODO: jump to page table loader
\ TODO: (PTL) set the "gc" flag to 1, load new page tables, jump to the game

go
." loop." cr
1 0 do 0 +loop
