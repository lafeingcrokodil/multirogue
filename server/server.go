package server

import (
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

// Server is a MultiRogue server.
type Server struct {
	clients   map[*websocket.Conn]bool
	broadcast chan Message
	upgrader  websocket.Upgrader
}

// Message is a chat message.
type Message struct {
	Username string `json:"username"`
	Message  string `json:"message"`
}

// New returns a new Server instance.
func New() *Server {
	return &Server{
		clients:   make(map[*websocket.Conn]bool), // connected clients
		broadcast: make(chan Message),             // broadcast channel
		upgrader:  websocket.Upgrader{},           // for upgrading HTTP requests to web sockets
	}
}

// Start starts the server on port 8000.
func (s *Server) Start() error {
	// Serve static assets.
	fs := http.FileServer(http.Dir("./public"))
	http.Handle("/", fs)

	// Configure websocket route.
	http.HandleFunc("/ws", s.handleConnection)

	// Start worker for handling incoming messages.
	go s.handleMessages()

	// Start listening for incoming connections and messages.
	log.Println("Starting server on port 8000...")
	return http.ListenAndServe(":8000", nil)
}

func (s *Server) handleConnection(w http.ResponseWriter, r *http.Request) {
	// Upgrade initial GET request to a websocket.
	ws, err := s.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("Warning: ", err)
		return
	}
	// Make sure we close the connection when the function returns.
	defer ws.Close()

	// Register the new client.
	s.clients[ws] = true

	for {
		var msg Message
		// Wait for a new message to come in and parse it.
		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Print("Warning: ", err)
			delete(s.clients, ws)
			break
		}
		// Send the newly received message to the broadcast channel.
		s.broadcast <- msg
	}
}

func (s *Server) handleMessages() {
	for {
		// Read the next message from the broadcast channel.
		msg := <-s.broadcast
		// Send it out to every client that is currently connected.
		for client := range s.clients {
			err := client.WriteJSON(msg)
			if err != nil {
				log.Print("Warning: ", err)
				client.Close()
				delete(s.clients, client)
			}
		}
	}
}
