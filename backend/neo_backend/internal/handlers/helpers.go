package handlers

import (
	"encoding/json"
	"net/http"
)

// writeJSON writes a JSON response with the given status code and data.
func writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
	}
}

// writeError writes a JSON error response.
func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}

// JSON is a wrapper around writeJSON.
func JSON(w http.ResponseWriter, status int, data interface{}) {
	writeJSON(w, status, data)
}

// Error is a wrapper around writeError.
func Error(w http.ResponseWriter, status int, message string) {
	writeError(w, status, message)
}

// DecodeJSON decodes request JSON body into a target struct.
func DecodeJSON(r *http.Request, target interface{}) error {
	return json.NewDecoder(r.Body).Decode(target)
}

// paginationParams extracts page/limit from query params.
type paginationParams struct {
	Page  int
	Limit int
}

// parsePagination extracts pagination from query string, with defaults.
func parsePagination(r *http.Request) paginationParams {
	page := 1
	limit := 50

	if p := r.URL.Query().Get("page"); p != "" {
		if v := parseInt(p); v > 0 {
			page = v
		}
	}
	if l := r.URL.Query().Get("limit"); l != "" {
		if v := parseInt(l); v > 0 && v <= 500 {
			limit = v
		}
	}

	return paginationParams{Page: page, Limit: limit}
}

// parseInt safely parses a string to int.
func parseInt(s string) int {
	var v int
	for _, c := range s {
		if c < '0' || c > '9' {
			return 0
		}
		v = v*10 + int(c-'0')
	}
	return v
}

// paginatedResponse is the standard paginated list response.
type paginatedResponse struct {
	Data       interface{} `json:"data"`
	Page       int         `json:"page"`
	Limit      int         `json:"limit"`
	Total      int64       `json:"total"`
	TotalPages int         `json:"total_pages"`
}

// newPaginatedResponse builds a paginated response.
func newPaginatedResponse(data interface{}, page, limit int, total int64) paginatedResponse {
	totalPages := int(total) / limit
	if int(total)%limit != 0 {
		totalPages++
	}
	return paginatedResponse{
		Data:       data,
		Page:       page,
		Limit:      limit,
		Total:      total,
		TotalPages: totalPages,
	}
}
