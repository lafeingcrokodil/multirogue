package server

// Sources:
// https://github.com/gorilla/websocket/tree/master/examples/chat
// https://scotch.io/bar-talk/build-a-realtime-chat-server-with-go-and-websockets

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

// Event is something that happens in the game, like a player moving.
type Event struct {
	// Name is the name of the event, e.g. "move".
	Name string `json:"name"`
	// Data contains additional information like the direction of movement.
	Data string `json:"data"`
}

// Server is a MultiRogue server.
type Server struct {
	addr     string // TCP address to listen on
	hub      *Hub
	upgrader websocket.Upgrader
}

// New returns a new Server instance.
func New(port int) *Server {
	return &Server{
		addr: fmt.Sprintf(":%d", port),
		hub:  newHub(),
	}
}

// Start starts the server.
func (s *Server) Start() error {
	go s.hub.run()

	// Serve static assets.
	fs := http.FileServer(http.Dir("./public"))
	http.Handle("/", fs)

	// Configure websocket route.
	http.HandleFunc("/ws", s.handleConnection)

	// Start listening for incoming requests.
	log.Printf("INFO: Starting server on %s...\n", s.addr)
	return http.ListenAndServe(s.addr, nil)
}

func (s *Server) handleConnection(w http.ResponseWriter, r *http.Request) {
	log.Print("INFO: Incoming connection.")

	// Upgrade initial HTTP server connection to the WebSocket protocol.
	conn, err := s.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("ERROR:", err)
		return
	}

	c := &Client{
		name: r.URL.Query().Get("name"),
		hub:  s.hub,
		conn: conn,
		send: make(chan *Event, 256),
	}
	c.hub.register <- c

	// Allow collection of memory referenced by the caller by doing all work in
	// new goroutines.
	go c.writePump()
	go c.readPump()
}
