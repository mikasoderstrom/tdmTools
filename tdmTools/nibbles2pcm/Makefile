CC=gcc
CFLAGS=-I.
DEPS = #hellomake.h
OBJ = nibbles2pcm.o

%.o: %.c $(DEPS)
	$(CC) -g -c -o $@ $< $(CFLAGS)

nibbles2pcm: $(OBJ)
	$(CC) -g -o $@ $^ $(CFLAGS)

all: nibbles2pcm 
	./nibbles2pcm ~/440-4400-0405-2.bin 440-2.txt

clean:
	rm $(OBJ) nibbles2pcm
