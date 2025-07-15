: loader-location " :2,\boot\loader.elf" ;

true to use-console?
false to ignore-output?
stdout @ 0= if
" screen" output
install-console
then

" load &device;" encode-bytes
loader-location encode-bytes
encode+
evaluate

" loaded the DOL loader at 0x" encode-bytes
load-base (u.) encode-bytes 
encode+
type
cr

create disk-device-path 100 allot
dev /aliases .properties
." enter the disk device path:" cr 
100 accept

variable run
0 run !
run @ 0 = if 1 0 do 0 +loop then 
