# ⴰⵣⵢⴰⵎ azyam
This repository is currently a mere set of ideas for making an OpenFirmware bootinfo.txt file that would turn a PowerPC-based Macintosh into a fake GameCube / Wii. Nothing is really implemented yet, except [memory mapping](src/load-bat-jump.fth) and [DOL loading](src/dol-loader.fth).

[main.fth](src/main.fth)'s comments describe an outline for such a project. Globally, the idea is:

- rewrite all exception handlers for them to handle any access to the hardware registers, that is going to result in a patch of the caller instruction. it's going to be replaced by a call to an "emulator", that will handle both the case where the patched instruction may access a regular memory address, and the one where it must interact with gamecube's hw.
- rewrite interrupt handlers to emulate real gamecube's interrupt sources (controller input)
- allocate enough memory for MEM1, EFB and L2 cache ([physical-memory.fth](src/physical-memory.fth))
- load the DOL executable file ([dol-loader.fth](src/dol-loader.fth))
- patch every paired single instruction to a call to a handler (possibly making use of AltiVec? if relevant, yet to figure out)
- patch the early code dedicated to loading BAT registers (possibly also handle a few [corner cases](https://dolphin-emu.org/blog/2016/09/06/booting-the-final-gc-game/) but it's a bit early to think about it)
- map the allocated memory in the same way the gamecube memory map maps it. it is necessary to do it through BAT registers-based virtual mapping, as we will need to temporarily override the ``mac-io`` mapping at ``0x80000000``, and rollback to the original mapping as our general hardware handler is called. OpenFirmware will unpredictably crash if it doesn't find ``mac-io`` at that region. also, it's maybe a good idea to replicate the cached/uncached regions mapped to the same physical memory. after that, jump to the entry point. ([load-bat-jump.fth](src/load-bat-jump.fth)) 

notes :

- i've also thought of including the hardware registers emulator directly in exception handlers, and doing the same for the paired single emulator. this would probably be way too slow (would fault on more than half the instructions) and cost significantly more cycles than having a "normal" handler getting called

- i'm not sure using BAT registers is more efficient than page tables here. this is going to require me to invalidate them each time i go through a handler, as those are probably going to make use of OpenFirmware primitives.

- it would be VERY useful to add powerpc mnemonics to the Forth environment, in order to avoid massively hardcode instructions like in [load-bat-jump.fth](src/load-bat-jump.fth)

- a trick is used for ``load-bat-jump-to-entry`` to allow for delayed compilation of a ``code`` / ``end-code`` block: space is allocated for that block, and a colon definition is responsible for setting the dictionary pointer at the beginning of it and filling it with instructions. as it's probable there will be the need to dynamically assemble blocks of instructions, it might be good to simplify the process with wrappers (that would automatically get the size to allocate)

- add a ``test`` folder at the root of the repo to include it in the APM image. useful for testing

- at this point it is still blurry in my head to figure how the graphics would possibly be handled in the future. OpenFirmware does not abstract any interface with graphic cards, so that would probably require to find official documents for the integrated GPUs.

for now, the program will patch the loaded DOL to contain a very small snippet of code at its entry point, meant to alter the (powermac-mapped) framebuffer, running in fake gamecube mode. this is only to test that it's able to jump to 0x80000000 after ``mac-io`` has been unmapped and the new BAT registers have been loaded.

this framebuffer demo works well with OpenFirmware 4.7.1, on a PowerBook G4. it failed to run on two iBook G3s though.

# 28/07/2025

at this moment, this repository is just a prototypical skeleton for many ideas i've thought about this month. i have tried to make a demonstration of the most elementary OpenFirmware primitives that would be relevant for the implementation. it also made me realize that Forth is really suited to be used as a low-level language in this context (it would be neater with powerpc mnemonics installed!).

i won't have the time to resume this project during the incoming academic year, so i'm letting it on hold in this state to maybe continue it in the future, or for anyone who wants to copy it in order to spare themselves a few OpenFirmware-specific stuff (OFW is going to require intensive trial and error for pretty anything)
