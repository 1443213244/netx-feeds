# build a Makefile for tcpscan.c
tcpscan: tcpscan.o   
	$(CC) $(LDFLAGS) tcpscan.o -o tcpscan
tcpscan.o: tcpscan.c        
	$(CC) $(CFLAGS) -c tcpscan.c 
clean: 
	rm *.o tcpscan
