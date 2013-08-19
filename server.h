/*
 * File: server.h
 * Author: Terese Haimberger
 *
 * Basic server.
 */

#ifndef SERVER_H
#define SERVER_H

#include <cstring>

class Server {
  protected:
    int listener;
    fd_set all_fds, read_fds;

    int accept_connection();
    int read_from_client(int fd);
    virtual void handle_msg(std::string msg);
    void disconnect(int fd);
    void fatal_error(std::string context);

  public:
    Server();
    void run();
};

#endif

