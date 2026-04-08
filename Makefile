
all:
	nasm -f elf64 server.asm && ld server.o -o server.out

sb:
	gcc sandbox.c -o sandbox && ./sandbox

presentation:
	typst compile webserver-x86-linux.typst
