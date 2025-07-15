PPC = powerpc-linux-gnu
SOURCES_C = $(shell find page-loader -name "*.c")
SOURCES_S = $(shell find page-loader -name "*.s")
OBJECTS = $(SOURCES_C:.c=.elf) $(SOURCES_S:.s=.elf)

DISK.APM: page-loader.elf bootinfo.txt kpartx/kpartx.sh
	mkdir -p ./mnt
	dd bs=1M count=1 if=/dev/zero of=DISK.APM
	parted DISK.APM --script mklabel mac mkpart primary hfs+ 64s 100%
	sudo chmod +x ./kpartx/kpartx.sh
	sudo ./kpartx/kpartx.sh
	mkdir -p ./mnt/ppc ./mnt/boot
	rsync -c -h bootinfo.txt ./mnt/ppc/
	rsync -c -h page-loader.elf ./mnt/boot/
	sync
	sudo umount ./mnt/
	sudo kpartx -d DISK.APM
	rm -r ./mnt
	@if ! strings DISK.APM | grep -q '</BOOT-SCRIPT></CHRP-BOOT>'; then \
		read -p "build of DISK.APM failed. run 'make clean && make'? [y/N]" ans; \
		if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then $(MAKE) clean && $(MAKE); fi; \
	fi
bootinfo.txt: src/globals.fth src/lib.fth \
	      src/memory-map.fth \
	      src/main.fth
	@echo "<CHRP-BOOT><COMPATIBLE>MacRisc MacRisc3 MacRisc4</COMPATIBLE><BOOT-SCRIPT>" > $@ 
	@sed 's/>/\&gt;/g; s/</\&lt;/g' $^ >> $@
	@echo "</BOOT-SCRIPT></CHRP-BOOT>" >> $@ #used for verification, let it in this format 
	@printf "\4" >> $@
page-loader.elf: linker.ld $(OBJECTS)
	$(PPC)-ld -T $^ -o $@
%.elf: %.c
	$(PPC)-gcc -I include -c $< -o $@
%.elf: %.s
	$(PPC)-as -c $< -o $@
clean:
	rm -rf *.APM *txt *.elf ./mnt
	find page-loader -name "*.elf" -type f -delete
