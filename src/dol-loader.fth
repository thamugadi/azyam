create dol-entry-point 4 allot
create text-offsets 7 4 * allot
create data-offsets 11 4 * allot
create text-load-addrs 7 4 * allot
create data-load-addrs 11 4 * allot
create text-load-sizes 7 4 * allot
create data-load-sizes 11 4 * allot
create bss-addr 4 allot
create bss-size 4 allot

80003140 dol-entry-point l! \ temporary

: map-tmp-vmem ; \ TODO: use a temporary virtual mapping for MEM1
: load-dol ; \ TODO: load main.dol from disk-device-path

: unmap-tmp-vmem ; \ TODO
