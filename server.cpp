/*
 * File: server.cpp
 * Author: Terese Haimberger
 *
 * Object oriented server implementation.
 *
 * Based on:
 *   http://www.gnu.org/software/libc/manual/html_node/Server-Example.html
 */

#include <cstdlib>
#include <iostream>
#include <cerrno>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "server.h"

#define PORT 13375

using namespace std;

/*
int listener;
fd_set all_fds, read_fds, client_fds;
int accept_connection();
int read_from_client(int fd);
void disconnect(int fd);
void fatal_error(string context);
*/

Server::Server(uint16_t port) {
  struct sockaddr_in addr;

  // create new socket
  cout << "Creating new socket...\n";
  listener = socket(PF_INET, SOCK_STREAM, 0);
  if (listener < 0)
    fatal_error("socket");

  // bind the socket
  cout << "Binding socket to port " << port << "...\n";
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  if (bind(listener, (struct sockaddr *) &addr, sizeof(addr)) < 0)
    fatal_error("bind");

  // start listening
  cout << "Listening...\n";
  if (listen(listener, 1) < 0)
    fatal_error("listen");

  FD_ZERO(&all_fds);          // clear file descriptor set
  FD_SET(listener, &all_fds); // add listener to set
}

void Server::run() {
  int i;

  cout << "Starting endless serving loop of joy...\n";
  while (true) {
    read_fds = all_fds;

    /* Wait for input to arrive on one or more active sockets. */
    if (select(FD_SETSIZE, &read_fds, NULL, NULL, NULL) < 0)
      fatal_error("select");

    /* Loop through sockets, handling input where applicable. */
    for (i = 0; i < FD_SETSIZE; i++)
      if (FD_ISSET(i, &read_fds)) { // input pending
        if (i == listener) { // connection requested
          if (accept_connection() < 0)
            fatal_error("accept");
        }
        else { //input pending on already-connected socket
          if (read_from_client(i) < 0) // has client disconnected?
            disconnect(i);
        }
      }
  }
}

fd_set Server::get_client_fds() {
  return client_fds;
}

int Server::accept_connection() {
  struct sockaddr_in client_addr;
  socklen_t addr_len = sizeof(client_addr);
  int new_fd;

  // accept the connection
  new_fd = accept(listener, (struct sockaddr *) &client_addr, &addr_len);
  if (new_fd < 0)
    return -1;

  cout << "NEW CONNECTION: " << new_fd
       << " (" << inet_ntoa(client_addr.sin_addr)
       << ":" << ntohs(client_addr.sin_port) << ")\n";

  // add new file descriptor to set
  FD_SET(new_fd, &all_fds);
  FD_SET(new_fd, &client_fds);

  return 0;
}

int Server::read_from_client(int fd) {
  char buffer[MSG_LEN];
  int num_bytes;

  num_bytes = read(fd, buffer, MSG_LEN);

  if (num_bytes < 0) // something went wrong
    fatal_error("read");
  else if (num_bytes == 0) // the client disconnected
    return -1;
  else { // a message arrived!
    string msg;
    buffer[num_bytes] = 0; // null-terminate the message
    msg = buffer;
    handle_msg(msg);
    return 0;
  }
}

void Server::handle_msg(string msg) {
  cout << "MESSAGE: " << msg << flush;
}

void Server::disconnect(int fd) {
  cout << "DISCONNECT: " << fd << "\n";
  close(fd);
  FD_CLR(fd, &all_fds);
}

void Server::fatal_error(string context) {
  cerr << context << ": " << strerror(errno);
  exit(EXIT_FAILURE);
}

int main() {
  Server server(PORT);
  server.run();
}

