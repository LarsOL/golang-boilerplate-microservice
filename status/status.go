package status

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

// These will be injected in at build time
// Another way would be with ENV, but that would have to be propagated through
var GitCommitSha = "Unknown"
var Version = "Local (Unknown)"
var Description = "No description given"

func status(w http.ResponseWriter, r *http.Request) {
	resp := &Response{
		Myapplication: &ApplicationInfo{
			Version:       Version,
			Description:   Description,
			Lastcommitsha: GitCommitSha,
		},
	}

	if err := json.NewEncoder(w).Encode(resp); err != nil {
		e := fmt.Sprintf("could not encode response: %+v with err: %v", resp, err)
		log.Print(e)
		http.Error(w, e, http.StatusInternalServerError)
	}
}
