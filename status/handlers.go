package status

import "github.com/gorilla/mux"

func Route(r *mux.Router) {
	r.HandleFunc("/status", status)
}
