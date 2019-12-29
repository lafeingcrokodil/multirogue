package main

import (
	"log"

	"github.com/lafeingcrokodil/multirogue/server"
)

func main() {
	s := server.New()
	if err := s.Start(); err != nil {
		log.Fatal("Error: ", err)
	}
}
