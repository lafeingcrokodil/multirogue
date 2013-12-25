/*
 * File: server.h
 * Author: Terese Haimberger
 *
 * Basic server.
 */

#ifndef SERVER_H
#define SERVER_H

#include <cstring>
#include <sys/select.h>

#define MSG_LEN 512

class Server {
  private:
    int listener;
    fd_set all_fds, read_fds, client_fds;

    int accept_connection();
    int read_from_client(int fd);
    void disconnect(int fd);
    void fatal_error(std::string context);

  protected:
    fd_set get_client_fds();
    virtual void handle_msg(std::string msg);

  public:
    Server(uint16_t port);
    void run();
};

#endif

