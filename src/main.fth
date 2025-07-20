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
." enter the mounted disk device path (sys/ and files/ at its root):" cr
\ dol is at sys/main.dol

\ stores the disk device path as a string, as well as its size.
\ if in the future, ISOs can be directly loaded, ask for their location and automatically set disk-device-path at their mounting point

disk-device-path 100 accept
disk-device-path-size l!
cr

\ allocate memory, the mapping is to be replaced by page table loader
init-memory-map

\ TODO: load DOL 

\ TODO: write PS instructions patcher and patch paired single instrs

\ TODO: patch the BAT-related instructions with NOPs



\ TODO: write hardware handler. a call to it is going to be inserted at the place of the instruction that attempted once to access hwregs
\       note that it will also handle the case where that instruction might not access to an hwreg, if executed in another execution flow
\       prior to its execution, it's going to unset the "gc" flag and restore the original page tables.  

\ TODO: write hwreg access patcher (responsible for doing the patching mentioned above after each exception subsequent to a hwreg access)
\       and redirect memory faults to it 

\ TODO: patch the external interrupt handlers to emulate an input that is going to be handled by the GC's external interrupt handler.
\       verify first if OF has no problem getting those interrupt handlers rewritten.

\ TODO: save vaddr mapping

\ jumps to page table loader
go
\ (game-loader) load BATs, jump to the game
." loop." cr
1 0 do 0 +loop
