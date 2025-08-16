package server

// Adapted from https://github.com/gorilla/websocket/tree/master/examples/chat

import (
	"log"

	"github.com/gorilla/websocket"
	"github.com/lafeingcrokodil/multirogue/creature"
	"github.com/lafeingcrokodil/multirogue/event"
)

// ClientEvent is an event fired by a client.
type ClientEvent struct {
	event.Event

	// Source is the client that fired the event.
	Source *Client
}

// Client is a middleman between the websocket connection and the hub.
type Client struct {
	rogue *creature.Rogue
	hub   *Hub
	conn  *websocket.Conn
	send  chan *event.Event // buffered channel of outbound events
}

// readPump pumps messages from the websocket connection to the hub.
//
// The application runs readPump in a per-connection goroutine. The application
// ensures that there is at most one reader on a connection by executing all
// reads from this goroutine.
func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close() //nolint:errcheck,gosec
	}()
	for {
		var e event.Event
		if err := c.conn.ReadJSON(&e); err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Print("ERROR:", err.Error())
			}
			break
		}
		switch e.Name {
		case "move":
			c.hub.move <- &ClientEvent{Event: e, Source: c}
		default:
			log.Printf("ERROR: unknown event %s\n", e.Name)
		}
	}
}

// writePump pumps messages from the hub to the websocket connection.
//
// A goroutine running writePump is started for each connection. The
// application ensures that there is at most one writer to a connection by
// executing all writes from this goroutine.
func (c *Client) writePump() {
	defer c.conn.Close() //nolint:errcheck
	for e := range c.send {
		es := []*event.Event{e}

		// Collect all queued events.
		for range len(c.send) {
			es = append(es, <-c.send)
		}

		if err := c.conn.WriteJSON(es); err != nil {
			return
		}
	}
}
