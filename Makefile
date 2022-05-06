# dragino lora testing
# Single lora testing app

CC=g++
CFLAGS=-c -Wall
LIBS=-lwiringPi

all: txrx_schedule txrx_once

txrx_schedule: main.o
	$(CC) main.o  $(LIBS) -o txrx_schedule

txrx_once: once.o
	$(CC) once.o  $(LIBS) -o txrx_once

once.o: once.c
	$(CC) $(CFLAGS) once.c

main.o: main.c
	$(CC) $(CFLAGS) main.c

clean:
	rm *.o txrx_*
