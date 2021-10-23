#install-pkg qemu # RUN ON STARTUP

# clean up terminal
clear
echo

# assembles bootloader
nasm -f bin src/boot.asm -o boot.bin
nasm -f bin src/kernel.asm -o kernel.bin

cat boot.bin kernel.bin > os.bin

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.  qemu-img create myOS.img 16384 # creates virtual disk image with 16 KB of storage
dd if=os.bin of=myOS.img bs=2048 count=1 # copies OS  to disk image

# caches files
mv myOS.img cache # caches disk image
mv os.bin cache # caches os code

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.  qemu-system-i386 -drive format=raw,file=cache/myOS.img
