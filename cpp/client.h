/*
 * File: client.h
 * Author: Terese Haimberger
 *
 * Basic client.
 */

#ifndef CLIENT_H
#define CLIENT_H

#include <cstring>

class Client {
  private:
    int fd;
    void fatal_error(std::string context);

  protected:
    int get_socket_fd();

  public:
    Client(const char *ip, uint16_t port);
    virtual void run();
};

#endif

