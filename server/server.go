// Package server implements a server for a multiplayer Rogue game.
package server

// Sources:
// https://github.com/gorilla/websocket/tree/master/examples/chat
// https://scotch.io/bar-talk/build-a-realtime-chat-server-with-go-and-websockets

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
	"github.com/lafeingcrokodil/multirogue/creature"
	"github.com/lafeingcrokodil/multirogue/event"
)

const (
	readTimeout  = 5 * time.Second
	writeTimeout = 10 * time.Second
	idleTimeout  = 120 * time.Second

	eventBufferSize = 256
)

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

	mux := http.NewServeMux()

	// Serve static assets.
	fs := http.FileServer(http.Dir("./public"))
	mux.Handle("/", fs)

	// Configure websocket route.
	mux.HandleFunc("/ws", s.handleConnection)

	srv := &http.Server{
		Addr:         s.addr,
		Handler:      mux,
		ReadTimeout:  readTimeout,
		WriteTimeout: writeTimeout,
		IdleTimeout:  idleTimeout,
	}

	// Start listening for incoming requests.
	log.Printf("INFO: Starting server on %s...\n", s.addr)
	return srv.ListenAndServe()
}

func (s *Server) handleConnection(w http.ResponseWriter, r *http.Request) {
	// Upgrade initial HTTP server connection to the WebSocket protocol.
	conn, err := s.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("ERROR:", err.Error())
		return
	}

	c := &Client{
		rogue: creature.NewRogue(r.URL.Query().Get("name")),
		hub:   s.hub,
		conn:  conn,
		send:  make(chan *event.Event, eventBufferSize),
	}
	c.hub.register <- c

	// Allow collection of memory referenced by the caller by doing all work in
	// new goroutines.
	go c.writePump()
	go c.readPump()
}
