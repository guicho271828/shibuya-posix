
CC = cc

headers = aio arpa/inet assert complex cpio ctype dirent dlfcn errno fcntl	\
        fenv float fmtmsg fnmatch ftw glob grp iconv inttypes iso646		\
        langinfo libgen limits locale math monetary mqueue ndbm net/if		\
        netdb netinet/in netinet/tcp nl_types poll pthread pwd regex sched	\
        search semaphore setjmp signal spawn stdarg stdbool stddef stdint	\
        stdio stdlib string strings stropts sys/ipc sys/mman sys/msg		\
        sys/resource sys/select sys/sem sys/shm sys/socket sys/stat		\
        sys/statvfs sys/time sys/times sys/types sys/uio sys/un			\
        sys/utsname sys/wait syslog tar termios tgmath time trace ulimit	\
        unistd utime utmpx wchar wctype wordexp

targets = $(foreach h,$(headers),$(h).$(1))

.PHONY: all clean xml tags i

xml:  $(call targets,xml)
tags: $(call targets,tags)
i:    $(call targets,i)


%.o: %.c
	-$(CC) $< -o $@

%.tags: %.i
	etags $<

%.i: %.c
	$(CC) -E -save-temps $< > $@

%.xml: %.c
	-gccxml $< -fxml=$@

posix.c: write-posix.sh
	./write-posix.sh

%.c: write-c.sh
	mkdir -p $(*D)
	./write-c.sh $* > $@

clean:
	git clean -dxf
