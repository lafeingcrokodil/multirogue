package server

import (
	"fmt"
	"log"
	"net/http"
)

// Server is a MultiRogue server.
type Server struct {
	addr string
}

// New returns a new Server instance.
func New(port int) *Server {
	return &Server{
		addr: fmt.Sprintf(":%d", port), // TCP address to listen on
	}
}

// Start starts the server.
func (s *Server) Start() error {
	// Serve static assets.
	fs := http.FileServer(http.Dir("./public"))
	http.Handle("/", fs)

	// Start listening for incoming requests.
	log.Printf("Starting server on %s...\n", s.addr)
	return http.ListenAndServe(s.addr, nil)
}
