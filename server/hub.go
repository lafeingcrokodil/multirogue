package server

// Adapted from https://github.com/gorilla/websocket/tree/master/examples/chat

import (
	"encoding/json"
	"log"

	"github.com/lafeingcrokodil/multirogue/dungeon"
	"github.com/lafeingcrokodil/multirogue/event"
)

// Hub maintains the set of active clients.
type Hub struct {
	dungeon    *dungeon.Dungeon
	clients    map[*Client]bool  // registered clients
	register   chan *Client      // register requests from clients
	unregister chan *Client      // unregister requests from clients
	move       chan *ClientEvent // incoming move events from clients
}

func newHub() *Hub {
	return &Hub{
		dungeon:    dungeon.New(),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]bool),
		move:       make(chan *ClientEvent),
	}
}

func (h *Hub) run() {
	for {
		select {
		case c := <-h.register:
			log.Printf("INFO: Registering new client %s...", c.rogue.Name)
			h.clients[c] = true
			send, broadcast := h.dungeon.Add(c.rogue)
			h.handleEvents(c, send, broadcast)
		case c := <-h.unregister:
			log.Printf("INFO: Unregistering client %s...", c.rogue.Name)
			if _, ok := h.clients[c]; ok {
				delete(h.clients, c)
				close(c.send)
			}
			send, broadcast := h.dungeon.Remove(c.rogue)
			h.handleEvents(c, send, broadcast)
		case e := <-h.move:
			var d event.MoveData
			err := json.Unmarshal([]byte(e.Data), &d)
			if err != nil {
				log.Print("ERROR:", err.Error())
				continue
			}
			send, broadcast := h.dungeon.Move(e.Source.rogue, d)
			h.handleEvents(e.Source, send, broadcast)
		}
	}
}

func (h *Hub) handleEvents(c *Client, send, broadcast []*event.Event) {
	for _, e := range send {
		c.send <- e
	}
	for _, e := range broadcast {
		h.broadcast(e)
	}
}

func (h *Hub) broadcast(e *event.Event) {
	for c := range h.clients {
		// Check if the event is relevant for the client.
		if e.Level != nil && c.rogue.Pos.Level != *e.Level {
			continue // if not, don't send it
		}
		select {
		case c.send <- e:
		default:
			close(c.send)
			delete(h.clients, c)
		}
	}
}
