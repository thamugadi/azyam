PPC = powerpc-linux-gnu
SOURCES_C = $(shell find page-table-loader -name "*.c")
SOURCES_S = $(shell find page-table-loader -name "*.s")
OBJECTS = $(addprefix build/, $(SOURCES_C:.c=.elf) $(SOURCES_S:.s=.elf))
DISK.APM: build/page-table-loader.elf build/bootinfo.txt kpartx/kpartx.sh
	mkdir -p ./mnt
	dd bs=1M count=1 if=/dev/zero of=$@
	parted $@ --script mklabel mac mkpart primary hfs+ 64s 100%
	sudo chmod +x ./kpartx/kpartx.sh
	sudo ./kpartx/kpartx.sh
	mkdir -p ./mnt/ppc ./mnt/boot
	rsync -c -h build/bootinfo.txt ./mnt/ppc/
	rsync -c -h build/page-table-loader.elf ./mnt/boot/
	sync
	sudo umount ./mnt/
	sudo kpartx -d $@ 
	rm -r ./mnt
	@if ! strings $@ | grep -q '</BOOT-SCRIPT></CHRP-BOOT>'; then \
		read -p "build of DISK.APM failed. run 'make clean && make'? [y/N]" ans; \
		if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then $(MAKE) clean && $(MAKE); fi; \
	fi
build/bootinfo.txt: src/init.fth src/lib.fth \
	      src/disk-loader.fth \
	      src/memory-map.fth \
	      src/ai.fth src/cp.fth src/di.fth src/dsp.fth src/exi.fth src/mi.fth src/pe.fth src/pi.fth src/si.fth src/vi.fth \
	      src/gx.fth \
	      src/paired-single.fth \
	      src/instr-handler.fth src/mem-handler.fth \
	      src/replace-handlers.fth src/restore-memory.fth \
	      src/main.fth
	@echo "<CHRP-BOOT><COMPATIBLE>MacRisc MacRisc3 MacRisc4</COMPATIBLE><BOOT-SCRIPT>" > $@ 
	@sed 's/>/\&gt;/g; s/</\&lt;/g; s/&/\&amp;/g;' $^ >> $@
	@echo "</BOOT-SCRIPT></CHRP-BOOT>" >> $@ #used for verification, let it in this format 
	@printf "\4" >> $@
build/page-table-loader.elf: page-table-loader/linker.ld $(OBJECTS)
	@mkdir -p $(@D)
	$(PPC)-ld -T $^ -o $@
build/%.elf: %.c
	@mkdir -p $(@D)
	$(PPC)-gcc -I include -c $< -o $@
build/%.elf: %.s
	@mkdir -p $(@D)
	$(PPC)-as -c $< -o $@
clean:
	rm -rf *.APM *txt *.elf ./mnt
	rm -rf build
