package server

// Adapted from https://github.com/gorilla/websocket/tree/master/examples/chat

import (
	"fmt"
	"log"

	"github.com/lafeingcrokodil/multirogue/dungeon"
)

// Hub maintains the set of active clients.
type Hub struct {
	dungeon    *dungeon.Dungeon
	clients    map[*Client]bool // registered clients
	broadcast  chan *Event      // events to be sent to all clients
	register   chan *Client     // register requests from clients
	unregister chan *Client     // unregister requests from clients
}

func newHub() *Hub {
	return &Hub{
		dungeon:    dungeon.New(),
		broadcast:  make(chan *Event),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]bool),
	}
}

func (h *Hub) run() {
	for {
		select {
		case c := <-h.register:
			log.Printf("INFO: Registering new client %s...", c.name)
			h.clients[c] = true
			c.send <- &Event{
				Name: "level",
				Data: fmt.Sprintf(`{"map":"%s"}`, h.dungeon.Levels[0].Map()),
			}
		case c := <-h.unregister:
			log.Printf("INFO: Unregistering client %s...", c.name)
			if _, ok := h.clients[c]; ok {
				delete(h.clients, c)
				close(c.send)
			}
		case e := <-h.broadcast:
			log.Printf("INFO: Broadcasting %v...", e)
			for c := range h.clients {
				select {
				case c.send <- e:
				default:
					close(c.send)
					delete(h.clients, c)
				}
			}
		}
	}
}
