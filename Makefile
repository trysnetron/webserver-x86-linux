

all:
	nasm -f elf64 server.asm && ld server.o -o server

sb:
	gcc sandbox.c -o sandbox && ./sandbox
