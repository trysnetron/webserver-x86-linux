

all:
	nasm -f elf64 -g -F dwarf server.asm && ld -e main server.o -o server

sb:
	gcc sandbox.c -o sandbox && ./sandbox