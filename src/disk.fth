create disk-device-path 100 allot
create disk-device-path-size 4 allot

\ for now, we'll assume the disk is mounted
\ maybe later: parse the disk format and manage to mount it instead of relying on wfuse?

\ TODO: make an optimized version of it making use of "seek"

create bytes-read-total 4 allot
create tmp-4kib-chunk-addr 4 allot

: get-file-size \ UNOPTIMIZED VERSION!! ( file-path -- size )
  0 bytes-read-total l!
  1000 alloc-mem tmp-4kib-chunk-addr l!
  open-dev
  begin  
    dup >r tmp-4kib-chunk-addr l@ 1000 " read" r> $call-method
    dup bytes-read-total l@ + bytes-read-total l!
    1000 <>
  until
  close-dev
  tmp-4kib-chunk-addr l@ 1000 free-mem
  bytes-read-total l@
;
