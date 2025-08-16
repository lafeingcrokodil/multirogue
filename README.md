multirogue
==========

A multiplayer version of Rogue.

For a list of available commands, run `make`.

[![GoDoc](https://godoc.org/github.com/lafeingcrokodil/multirogue?status.svg)](https://pkg.go.dev/github.com/lafeingcrokodil/multirogue?tab=doc)
[![CI](https://github.com/lafeingcrokodil/multirogue/actions/workflows/ci.yml/badge.svg)](https://github.com/lafeingcrokodil/multirogue/actions/workflows/ci.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/lafeingcrokodil/multirogue)](https://goreportcard.com/report/github.com/lafeingcrokodil/multirogue)

## Installation

Make sure that you have Docker installed. For example, you can find instructions for installing the community edition for Ubuntu [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/).

Start the server by running

    make web-docker

You should then be able to access the app at [localhost:8080](localhost:8080).

## Sources

- [Build a Realtime Chat Server With Go and WebSockets](https://scotch.io/bar-talk/build-a-realtime-chat-server-with-go-and-websockets)
- [Chat Example from gorilla/websocket](https://github.com/gorilla/websocket/tree/master/examples/chat)
- [The Rogue's Vade-Mecum](http://rogue.rogueforge.net/vade-mecum/)
- [Rogue 5.4.4 Source Code](http://rogue.rogueforge.net/rogue-5-4/)
