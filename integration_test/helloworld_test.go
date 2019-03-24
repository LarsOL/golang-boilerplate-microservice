package integration_test

import (
	"net/http"
	"testing"
)

const defaultServer = "http://localhost:8080"

func Test_HellloWorldIsRunning(t *testing.T) {
	resp, err := http.Get(defaultServer + "/")
	if err != nil {
		t.Fatal(err)
	}

	if resp.StatusCode != http.StatusOK {
		t.Errorf("Received invalid status code: %v", resp.StatusCode)
	}
}
