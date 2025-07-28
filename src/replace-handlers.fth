\ just a stub for now
: replace-main-handler-stub
  7c1042a6 1e0 l! \ mfspr r0, 0x110
  4c000064 1e0 l! \ rfi
  \ i don't know if it is the right way to return from an exception into supervisor-level code. it restores r0 from the spr it seems to copy it to as i can see in most exception handlers entry points. TODO: figure this out.
;

\ TODO: real general exception/interrupt handler
