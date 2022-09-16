

all:
	nasm -f elf64 -g -F dwarf server.s && ld -e main server.o -o server

sb:
	gcc sandbox.c -o sandbox && ./sandbox