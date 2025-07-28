: replace-main-handler-stub
  7c1042a6 1e0 l! \ mfspr r0, 0x110
  4c000064 1e0 l! \ rfi
  \ this is probably wrong and not the right way to return from an exception into supervisor-level code. though it restores r0 from the spr it seems to copy it to as i can see in most exception handlers entry points. TODO: fix this.
;
