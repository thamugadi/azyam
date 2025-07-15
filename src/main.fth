true to use-console?
false to ignore-output?
stdout @ 0= if
" screen" output
install-console
then

" load &device;" encode-bytes
page-loader-location encode-bytes
encode+
evaluate

" loaded the page-loader at 0x" encode-bytes
load-base (u.) encode-bytes 
encode+
type cr

dev /aliases .properties
." enter the disk device path:" cr
\ stores the disk device path as a string, as well as its size
disk-device-path 100 accept disk-device-path-size l!

1 0 do 0 +loop
