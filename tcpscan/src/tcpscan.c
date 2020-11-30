#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdlib.h>
#include <errno.h>

int scanPort(struct hostent *hostaddr,int port){
	struct timeval timeo = {3, 0};
	socklen_t len = sizeof(timeo);
    char responce[1024];
    char *message="checking port";
    struct sockaddr_in server_address;
    int socket_d;
    int rval;
    socket_d = socket(PF_INET,SOCK_STREAM,IPPROTO_TCP);
    if(socket_d == -1)
    {
        perror("Socket()\n");
        return errno;
    }
    memset(&server_address,0,sizeof(server_address));
	setsockopt(socket_d, SOL_SOCKET, SO_SNDTIMEO, &timeo, len);
    server_address.sin_family=AF_INET;
    server_address.sin_port=htons(port);

    memcpy(&server_address.sin_addr,hostaddr->h_addr,hostaddr->h_length);

    rval = connect(socket_d,(struct sockaddr *) &server_address, sizeof(server_address));

    if(rval == -1)
    {
        close(socket_d);    
        return 0;
    }else{
        close(socket_d);
        return 1;
    }

}


int main(int argc, char **argv)
{
    if(argc < 3){
        printf("Exemplu: ./portscanner <adresa_ip> <port_pornire>\n");
        return (EINVAL);
    }

    int port;
    struct hostent *host_address;

    host_address = gethostbyname( argv[1] );
    port = atoi(argv[2]);

    if(scanPort(host_address,port)==1){
    	printf("Port %d is open\n",port);
		return 0;
    }else{
		return 1;
	}
}
