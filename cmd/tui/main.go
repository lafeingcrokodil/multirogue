package main

// Adapted from https://github.com/gorilla/websocket/tree/master/examples/echo

import (
	"log"
	"net/url"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/websocket"
	"gopkg.in/alecthomas/kingpin.v2"
)

// We set this value as part of the build process using `-ldflags "-X main.version=$VERSION"`.
var version = "unknown" // nolint:gochecknoglobals

func main() {
	var addr string

	kingpin.Version(version)
	kingpin.Flag("addr", "HTTP service address.").
		Default("localhost:8080").Envar("ADDR").StringVar(&addr)
	kingpin.Parse()

	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	u := url.URL{Scheme: "ws", Host: addr, Path: "/ws", RawQuery: "name=Foo"}
	log.Printf("Connecting to %s...", u.String())

	c, _, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatal("Dial:", err)
	}
	defer c.Close()

	done := make(chan struct{})

	go func() {
		defer close(done)
		for {
			_, message, err := c.ReadMessage()
			if err != nil {
				log.Println("Read:", err)
				return
			}
			log.Printf("Received: %s", message)
		}
	}()

	for {
		select {
		case <-done:
			return
		case <-interrupt:
			log.Println("Handling interrupt...")

			// Cleanly close the connection by sending a close message and then
			// waiting (with timeout) for the server to close the connection.
			err := c.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Println("Write close:", err)
				return
			}
			select {
			case <-done:
			case <-time.After(time.Second):
			}
			return
		}
	}
}
