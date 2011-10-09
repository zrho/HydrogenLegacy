ASM := nasm
ASMFLAGS := -I./src/ -f elf64

BUILD_DIR := build
SRC_DIR   := src

MAIN_S 	  := $(SRC_DIR)/hydrogen.asm
MAIN_O	  := $(BUILD_DIR)/hydrogen.o

all:
	$(ASM) $(ASMFLAGS) $(MAIN_S) -o $(MAIN_O)
	
link: all
	ld -z max-page-size=4096 -T link.ld -o build/hydrogen.bin build/hydrogen.o
	objcopy -x build/hydrogen.bin build/hydrogen.bin
	
clean:
	rm $(MAIN_O)
	
iso: link
	cp build/hydrogen.bin iso/boot/hydrogen.bin
	mkisofs -R -b boot/stage2_eltorito -no-emul-boot -boot-load-size 4 \
	          -boot-info-table -o boot.iso iso
	          
run: iso
	bochs -q