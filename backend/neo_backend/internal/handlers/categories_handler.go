package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/fireflyneo/neo-backend/internal/middleware"
	"github.com/fireflyneo/neo-backend/internal/models"
	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// CategoriesHandler handles category endpoints.
type CategoriesHandler struct {
	db *gorm.DB
}

// NewCategoriesHandler creates a new CategoriesHandler.
func NewCategoriesHandler(db *gorm.DB) *CategoriesHandler {
	return &CategoriesHandler{db: db}
}

// createCategoryRequest is the payload for creating a category.
type createCategoryRequest struct {
	Name     string  `json:"name"`
	Color    string  `json:"color"`
	Icon     string  `json:"icon"`
	ParentID *string `json:"parent_id"`
}

// categorySummaryItem is a single category's spending summary.
type categorySummaryItem struct {
	CategoryID   string  `json:"category_id"`
	CategoryName string  `json:"category_name"`
	Color        string  `json:"color"`
	Icon         string  `json:"icon"`
	TotalSpent   float64 `json:"total_spent"`
	TxCount      int64   `json:"tx_count"`
	Percentage   float64 `json:"percentage"`
}

// List handles GET /api/categories.
func (h *CategoriesHandler) List(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var categories []models.Category
	if err := h.db.Where("user_id = ?", userID).Order("name ASC").Find(&categories).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch categories")
		return
	}

	writeJSON(w, http.StatusOK, categories)
}

// Create handles POST /api/categories.
func (h *CategoriesHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req createCategoryRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "name is required")
		return
	}

	if req.Color == "" {
		req.Color = "#6366F1"
	}
	if req.Icon == "" {
		req.Icon = "category"
	}

	cat := models.Category{
		ID:       uuid.New().String(),
		UserID:   userID,
		Name:     req.Name,
		Color:    req.Color,
		Icon:     req.Icon,
		ParentID: req.ParentID,
	}

	if err := h.db.Create(&cat).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to create category")
		return
	}

	writeJSON(w, http.StatusCreated, cat)
}

// Get handles GET /api/categories/{id}.
func (h *CategoriesHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var cat models.Category
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&cat).Error; err != nil {
		writeError(w, http.StatusNotFound, "Category not found")
		return
	}

	writeJSON(w, http.StatusOK, cat)
}

// Update handles PUT /api/categories/{id}.
func (h *CategoriesHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var cat models.Category
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&cat).Error; err != nil {
		writeError(w, http.StatusNotFound, "Category not found")
		return
	}

	var req createCategoryRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	updates := map[string]interface{}{}
	if req.Name != "" {
		updates["name"] = req.Name
	}
	if req.Color != "" {
		updates["color"] = req.Color
	}
	if req.Icon != "" {
		updates["icon"] = req.Icon
	}
	updates["parent_id"] = req.ParentID

	if err := h.db.Model(&cat).Updates(updates).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update category")
		return
	}

	writeJSON(w, http.StatusOK, cat)
}

// Delete handles DELETE /api/categories/{id}.
func (h *CategoriesHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var cat models.Category
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&cat).Error; err != nil {
		writeError(w, http.StatusNotFound, "Category not found")
		return
	}

	// Null out transactions referencing this category
	h.db.Model(&models.Transaction{}).Where("user_id = ? AND category_id = ?", userID, id).
		Update("category_id", nil)

	if err := h.db.Delete(&cat).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete category")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "Category deleted successfully"})
}

// GetTransactions handles GET /api/categories/{id}/transactions.
func (h *CategoriesHandler) GetTransactions(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	// Verify ownership
	var cat models.Category
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&cat).Error; err != nil {
		writeError(w, http.StatusNotFound, "Category not found")
		return
	}

	pagination := parsePagination(r)
	offset := (pagination.Page - 1) * pagination.Limit
	query := h.db.Where("user_id = ? AND category_id = ?", userID, id)

	if start := r.URL.Query().Get("start"); start != "" {
		if t, err := time.Parse("2006-01-02", start); err == nil {
			query = query.Where("date >= ?", t)
		}
	}
	if end := r.URL.Query().Get("end"); end != "" {
		if t, err := time.Parse("2006-01-02", end); err == nil {
			query = query.Where("date <= ?", t.Add(24*time.Hour-time.Second))
		}
	}

	var total int64
	query.Model(&models.Transaction{}).Count(&total)

	var txs []models.Transaction
	if err := query.Order("date DESC").Limit(pagination.Limit).Offset(offset).Find(&txs).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch transactions")
		return
	}

	writeJSON(w, http.StatusOK, newPaginatedResponse(txs, pagination.Page, pagination.Limit, total))
}

// GetSummary handles GET /api/categories/summary.
func (h *CategoriesHandler) GetSummary(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	// Date range defaults to current month
	now := time.Now()
	startDefault := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
	endDefault := startDefault.AddDate(0, 1, 0).Add(-time.Second)

	start := startDefault
	end := endDefault

	if s := r.URL.Query().Get("start"); s != "" {
		if t, err := time.Parse("2006-01-02", s); err == nil {
			start = t
		}
	}
	if e := r.URL.Query().Get("end"); e != "" {
		if t, err := time.Parse("2006-01-02", e); err == nil {
			end = t.Add(24*time.Hour - time.Second)
		}
	}

	type rawResult struct {
		CategoryID string
		Total      float64
		TxCount    int64
	}

	var results []rawResult
	h.db.Raw(`
		SELECT category_id, COALESCE(SUM(amount), 0) AS total, COUNT(*) AS tx_count
		FROM transactions
		WHERE deleted_at IS NULL AND user_id = ? AND type = 'withdrawal'
		  AND category_id IS NOT NULL AND date BETWEEN ? AND ?
		GROUP BY category_id
		ORDER BY total DESC
	`, userID, start, end).Scan(&results)

	// Calculate overall total for percentages
	var overallTotal float64
	for _, r := range results {
		overallTotal += r.Total
	}

	// Load category names
	var categories []models.Category
	h.db.Where("user_id = ?", userID).Find(&categories)
	catMap := map[string]models.Category{}
	for _, c := range categories {
		catMap[c.ID] = c
	}

	summaries := make([]categorySummaryItem, 0, len(results))
	for _, res := range results {
		cat := catMap[res.CategoryID]
		pct := 0.0
		if overallTotal > 0 {
			pct = (res.Total / overallTotal) * 100
		}
		summaries = append(summaries, categorySummaryItem{
			CategoryID:   res.CategoryID,
			CategoryName: cat.Name,
			Color:        cat.Color,
			Icon:         cat.Icon,
			TotalSpent:   res.Total,
			TxCount:      res.TxCount,
			Percentage:   pct,
		})
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"start":       start,
		"end":         end,
		"total_spent": overallTotal,
		"categories":  summaries,
	})
}
