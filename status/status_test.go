package status

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func Test_Sanity(t *testing.T) {
	// Arrange
	expectedVersion := "1.0"
	expectedDescription := "Example Microservice"
	expectedSha := "124asdfas"

	Version = expectedVersion
	Description = expectedDescription
	GitCommitSha = expectedSha

	req, err := http.NewRequest(http.MethodGet, "/status", nil)
	if err != nil {
		t.Fatalf("could not generate request %v", err)
	}

	w := httptest.NewRecorder()

	// Act
	status(w, req)

	// Assert
	res := w.Result()
	if res.StatusCode != http.StatusOK {
		t.Fatalf("expected statusCode is StatusOK (200) but got %v", res.StatusCode)
	}

	resp := &Response{}
	if err := json.NewDecoder(res.Body).Decode(resp); err != nil {
		t.Fatalf("could not decode response %v", err)
	}

	if resp.Myapplication == nil {
		t.Fatalf("expected myapplication to be populated in response")
	}

	if resp.Myapplication.Description != expectedDescription {
		t.Fatalf("did not get expected description %v, instead got: %v", expectedDescription, resp.Myapplication.Description)
	}

	if resp.Myapplication.Version != expectedVersion {
		t.Fatalf("did not get expected version %v, instead got: %v", expectedVersion, resp.Myapplication.Version)
	}

	if resp.Myapplication.Lastcommitsha != expectedSha {
		t.Fatalf("did not get expected lastcommitsha %v, instead got: %v", expectedSha, resp.Myapplication.Lastcommitsha)
	}
}
