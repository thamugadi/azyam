create dol-entry-point 4 allot

\ 80003140 dol-entry-point l! \ temporary

create tmp-mem1-addr 4 allot
create tmp-dol-loc-paddr 4 allot
create tmp-dol-loc-vaddr 4 allot

: get-dol-size
  disk-device-path disk-device-path-size l@ encode-bytes
  " sys\main.dol" encode-bytes
  encode+
  get-file-size
;

: load-dol
  disk-device-path disk-device-path-size l@ encode-bytes
  " sys\main.dol" encode-bytes
  encode+

  01000000 20000 claim-physical tmp-dol-loc-paddr l!
  01000000 20000 claim-virtual tmp-dol-loc-vaddr l!
  tmp-dol-loc-paddr l@ tmp-dol-loc-vaddr l@ 01000000 2 mmu-map
  \ allocated 16MiB for the DOL file, which is exaggerated
  open-dev
  dup >r tmp-dol-loc-vaddr l@ 01000000 " read" r> $call-method
  drop
  close-dev

  main-memory-paddr l@
  01800000 20000 claim-virtual dup
  01800000 2 mmu-map

  tmp-mem1-addr l! 
  
  tmp-dol-loc-vaddr l@ >r
  r@ E0 + l@ dol-entry-point l!

  48 00 do
    r@ i + l@ r@ + \ ( dol-pos )
    r@ i 48 + + l@ 3fffffff and tmp-mem1-addr l@ + \ ( dol-pos load-vaddr )
    r@ i 90 + + l@ \ ( dol-pos load-vaddr size )
    move
  4 +loop

  r@ D8 + l@ 3fffffff and tmp-mem1-addr l@ + \ ( bss-vaddr )
  r@ DC + l@ \ ( bss-vaddr bss-size )
  erase

  r> drop
  tmp-dol-loc-vaddr l@ 01000000 mmu-unmap
  tmp-dol-loc-paddr l@ 01000000 release-physical
  tmp-dol-loc-vaddr l@ 01000000 release-virtual
  
  tmp-mem1-addr l@ 01800000 mmu-unmap
  tmp-mem1-addr l@ 01800000 release-virtual
;
