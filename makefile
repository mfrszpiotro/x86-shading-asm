prog: main.o proj.o
	@echo "Link: "
	gcc -g -m32 main.o proj.o -o prog
	@echo "OK\n"

main.o: main.c
	@echo "\nCompile C driver: "
	gcc -g -m32 -c main.c -o main.o
	@echo "OK\n"
	
proj.o: proj.asm
	@echo "Compile ASM function: "
	nasm -g -f elf32 proj.asm -o proj.o
	@echo "OK\n"
