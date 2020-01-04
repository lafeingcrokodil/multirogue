package server

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

// Server is a MultiRogue server.
type Server struct {
	addr     string                     // TCP address to listen on
	players  map[string]*websocket.Conn // players that are currently connected
	upgrader websocket.Upgrader         // for upgrading HTTP requests to websockets
}

// Event is something that happens in the game, like a player moving.
type Event struct {
	// Name is the name of the event, e.g. "move".
	Name string `json:"name"`
	// Data contains additional information like the direction of movement.
	Data string `json:"data"`
}

// New returns a new Server instance.
func New(port int) *Server {
	return &Server{
		addr:    fmt.Sprintf(":%d", port),
		players: make(map[string]*websocket.Conn),
	}
}

// Start starts the server.
func (s *Server) Start() error {
	// Serve static assets.
	fs := http.FileServer(http.Dir("./public"))
	http.Handle("/", fs)

	// Configure websocket route.
	http.HandleFunc("/ws", s.handleConnection)

	// Start listening for incoming requests.
	log.Printf("Starting server on %s...\n", s.addr)
	return http.ListenAndServe(s.addr, nil)
}

func (s *Server) handleConnection(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")

	// Upgrade initial GET request to a websocket.
	ws, err := s.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("Warning: ", err)
		return
	}
	defer ws.Close()

	// Register the new player.
	log.Printf("%s joined.", name)
	s.players[name] = ws

	// Display "@" character at top left of screen.
	if err := ws.WriteJSON(Event{
		Name: "display",
		Data: `{"c": "@", "x": 0, "y": 0}`,
	}); err != nil {
		log.Print("Warning: ", err)
		log.Printf("%s left.", name)
		delete(s.players, name)
		return
	}

	for {
		var e Event
		// Wait for a new event to come in and parse it.
		if err := ws.ReadJSON(&e); err != nil {
			log.Print("Warning: ", err)
			log.Printf("%s left.", name)
			delete(s.players, name)
			break
		}
		// Just print the event for now.
		log.Print(e)
	}
}
