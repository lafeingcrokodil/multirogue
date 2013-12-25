/*
 * File: client.cpp
 * Author: Terese Haimberger
 *
 * Object oriented client implementation.
 *
 * Based on:
 *   http://www.gnu.org/software/libc/manual/html_node/Byte-Stream-Example.html
 */

#include <cstdlib>
#include <iostream>
#include <cerrno>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "client.h"

#define IP   "127.0.0.1"
#define PORT 13375

using namespace std;

Client::Client(const char *ip, uint16_t port) {
  struct sockaddr_in server_addr;
  
  // create new socket
  cout << "Creating new socket...\n";
  fd = socket(PF_INET, SOCK_STREAM, 0);
  if (fd < 0)
    fatal_error("socket");

  // get server socket address
  server_addr.sin_family = AF_INET;
  server_addr.sin_port = htons(port);
  inet_pton(AF_INET, ip, &(server_addr.sin_addr));

  // connect to server
  cout << "Connecting to server at " << ip << ":" << port << "...\n";
  if (connect(fd, (struct sockaddr *) &server_addr, sizeof(server_addr)))
    fatal_error("connect");
}

int Client::get_socket_fd() {
  return fd;
}

void Client::run() {
  char msg[] = "Greetings!";
  int num_bytes;

  cout << "SENDING: " << msg << "\n";
  num_bytes = write(fd, msg, strlen(msg) + 1);
  if (num_bytes < 0)
    fatal_error("write");

  cout << "Number of bytes written: " << num_bytes << "\n";
}

void Client::fatal_error(string context) {
  cerr << context << ": " << strerror(errno) << "\n";
  exit(EXIT_FAILURE);
}

int main() {
  Client client(IP, PORT);
  client.run();
}


