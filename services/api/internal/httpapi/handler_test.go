package httpapi_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/HieronymusF/mandarin-mission/services/api/internal/httpapi"
)

func TestHealth(t *testing.T) {
	recorder := request(t, httpapi.New("test"), "/healthz")

	if recorder.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusOK)
	}
	if contentType := recorder.Header().Get("Content-Type"); contentType != "application/json; charset=utf-8" {
		t.Fatalf("Content-Type = %q", contentType)
	}

	var response map[string]string
	decode(t, recorder, &response)
	if response["status"] != "ok" {
		t.Fatalf("status body = %q, want ok", response["status"])
	}
}

func TestMeta(t *testing.T) {
	recorder := request(t, httpapi.New("1.2.3"), "/v1/meta")

	if recorder.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusOK)
	}

	var response map[string]string
	decode(t, recorder, &response)
	if response["service"] != "mandarin-mission-api" {
		t.Fatalf("service = %q", response["service"])
	}
	if response["version"] != "1.2.3" {
		t.Fatalf("version = %q, want 1.2.3", response["version"])
	}
}

func request(t *testing.T, handler http.Handler, path string) *httptest.ResponseRecorder {
	t.Helper()
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, path, nil))
	return recorder
}

func decode(t *testing.T, recorder *httptest.ResponseRecorder, target any) {
	t.Helper()
	if err := json.NewDecoder(recorder.Body).Decode(target); err != nil {
		t.Fatalf("decode response: %v", err)
	}
}
