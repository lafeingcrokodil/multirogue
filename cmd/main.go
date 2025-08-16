// Package main contains code for starting a web server for a multiplayer Rogue game.
package main

import (
	"log"

	"github.com/lafeingcrokodil/multirogue/server"
	kingpin "gopkg.in/alecthomas/kingpin.v2"
)

// We set this value as part of the build process using `-ldflags "-X main.version=$VERSION"`.
var version = "unknown"

func main() {
	var port int

	kingpin.Version(version)
	kingpin.Flag("port", "Port to listen on.").
		Default("8080").Envar("PORT").IntVar(&port)
	kingpin.Parse()

	s := server.New(port)
	err := s.Start()
	if err != nil {
		log.Fatal(err)
	}
}
