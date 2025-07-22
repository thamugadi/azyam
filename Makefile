PPC = powerpc-eabi
DISK.APM: build/bootinfo.txt kpartx/kpartx.sh
	mkdir -p ./mnt
	dd bs=1M count=1 if=/dev/zero of=$@
	parted $@ --script mklabel mac mkpart primary hfs+ 64s 100%
	sudo chmod +x ./kpartx/kpartx.sh
	sudo ./kpartx/kpartx.sh
	mkdir -p ./mnt/ppc ./mnt/boot
	rsync -c -h build/bootinfo.txt ./mnt/ppc/
	sync
	sudo umount ./mnt/
	sudo kpartx -d $@ 
	rm -r ./mnt
	@if ! strings $@ | grep -q '</BOOT-SCRIPT></CHRP-BOOT>'; then \
		read -p "build of DISK.APM failed. run 'make clean && make'? [y/N]" ans; \
		if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then $(MAKE) clean && $(MAKE); fi; \
	fi
build/bootinfo.txt: src/init.fth src/lib.fth \
	      src/disk.fth src/dol-loader.fth \
	      src/memory-map.fth \
	      src/ai.fth src/cp.fth src/di.fth src/dsp.fth src/exi.fth src/mi.fth src/pe.fth src/pi.fth src/si.fth src/vi.fth \
	      src/gx.fth \
	      src/ps-instr-patcher.fth \
	      src/hwreg-patcher.fth \
	      src/replace-handlers.fth src/restore-memory.fth \
              src/controller.fth src/interrupts.fth \
	      src/load-bat-jump.fth \
	      src/main.fth
	@mkdir -p build
	@echo "<CHRP-BOOT><COMPATIBLE>MacRisc MacRisc3 MacRisc4</COMPATIBLE><BOOT-SCRIPT>" > $@ 
	@sed 's/>/\&gt;/g; s/</\&lt;/g;' $^ >> $@
	@echo "</BOOT-SCRIPT></CHRP-BOOT>" >> $@ #used for verification, let it in this format 
	@printf "\4" >> $@
clean:
	rm -rf *.APM *.txt *.elf ./mnt
	rm -rf build
