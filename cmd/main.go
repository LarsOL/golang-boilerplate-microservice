package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/LarsOL/golang-boilerplate-microservice/helloworld"
	"github.com/LarsOL/golang-boilerplate-microservice/status"
	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()

	status.Route(r)
	helloworld.Route(r)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("Defaulting to port %s", port)
	}

	log.Printf("Listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), r))
}
