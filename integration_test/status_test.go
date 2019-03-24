package integration_test

import (
	"net/http"
	"testing"
)

func Test_StatusIsRunning(t *testing.T) {
	resp, err := http.Get(defaultServer + "/status")
	if err != nil {
		t.Fatal(err)
	}

	if resp.StatusCode != http.StatusOK {
		t.Errorf("Received invalid status code: %v", resp.StatusCode)
	}
}
