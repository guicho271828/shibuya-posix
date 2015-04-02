
headers="
aio arpa/inet assert complex cpio ctype dirent dlfcn errno fcntl	
fenv float fmtmsg fnmatch ftw glob grp iconv inttypes iso646		
langinfo libgen limits locale math monetary mqueue ndbm net/if		
netdb netinet/in netinet/tcp nl_types poll pthread pwd regex sched	
search semaphore setjmp signal spawn stdarg stdbool stddef stdint	
stdio stdlib string strings stropts sys/ipc sys/mman sys/msg		
sys/resource sys/select sys/sem sys/shm sys/socket sys/stat		
sys/statvfs sys/time sys/times sys/types sys/uio sys/un			
sys/utsname sys/wait syslog tar termios tgmath time trace ulimit	
unistd utime utmpx wchar wctype wordexp
"

main (){
    for h in $headers
    do
        echo "#include <$h.h>"
    done
}

main > posix.c

