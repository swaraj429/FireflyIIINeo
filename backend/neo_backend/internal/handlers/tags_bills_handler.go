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

// TagsHandler handles tag endpoints.
type TagsHandler struct {
	db *gorm.DB
}

// NewTagsHandler creates a new TagsHandler.
func NewTagsHandler(db *gorm.DB) *TagsHandler {
	return &TagsHandler{db: db}
}

// createTagRequest is the payload for creating a tag.
type createTagRequest struct {
	Name  string `json:"name"`
	Color string `json:"color"`
}

// ListTags handles GET /api/tags.
func (h *TagsHandler) List(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var tags []models.Tag
	if err := h.db.Where("user_id = ?", userID).Order("name ASC").Find(&tags).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch tags")
		return
	}

	writeJSON(w, http.StatusOK, tags)
}

// CreateTag handles POST /api/tags.
func (h *TagsHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req createTagRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "name is required")
		return
	}
	if req.Color == "" {
		req.Color = "#8B5CF6"
	}

	tag := models.Tag{
		ID:     uuid.New().String(),
		UserID: userID,
		Name:   req.Name,
		Color:  req.Color,
	}

	if err := h.db.Create(&tag).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to create tag")
		return
	}

	writeJSON(w, http.StatusCreated, tag)
}

// GetTag handles GET /api/tags/{id}.
func (h *TagsHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var tag models.Tag
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&tag).Error; err != nil {
		writeError(w, http.StatusNotFound, "Tag not found")
		return
	}

	writeJSON(w, http.StatusOK, tag)
}

// UpdateTag handles PUT /api/tags/{id}.
func (h *TagsHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var tag models.Tag
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&tag).Error; err != nil {
		writeError(w, http.StatusNotFound, "Tag not found")
		return
	}

	var req createTagRequest
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

	if err := h.db.Model(&tag).Updates(updates).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update tag")
		return
	}

	writeJSON(w, http.StatusOK, tag)
}

// DeleteTag handles DELETE /api/tags/{id}.
func (h *TagsHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var tag models.Tag
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&tag).Error; err != nil {
		writeError(w, http.StatusNotFound, "Tag not found")
		return
	}

	if err := h.db.Delete(&tag).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete tag")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "Tag deleted successfully"})
}

// =============================================================================
// BillsHandler
// =============================================================================

// BillsHandler handles bill endpoints.
type BillsHandler struct {
	db *gorm.DB
}

// NewBillsHandler creates a new BillsHandler.
func NewBillsHandler(db *gorm.DB) *BillsHandler {
	return &BillsHandler{db: db}
}

// createBillRequest is the payload for creating a bill.
type createBillRequest struct {
	Name         string  `json:"name"`
	Amount       float64 `json:"amount"`
	CurrencyCode string  `json:"currency_code"`
	Period       string  `json:"period"`
	NextDueDate  string  `json:"next_due_date"`
	AccountID    string  `json:"account_id"`
	CategoryID   *string `json:"category_id"`
	Notes        string  `json:"notes"`
	Active       *bool   `json:"active"`
}

// ListBills handles GET /api/bills.
func (h *BillsHandler) List(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	query := h.db.Where("user_id = ?", userID)
	if a := r.URL.Query().Get("active"); a != "" {
		query = query.Where("active = ?", a == "true")
	}

	var bills []models.Bill
	if err := query.Order("next_due_date ASC").Find(&bills).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch bills")
		return
	}

	writeJSON(w, http.StatusOK, bills)
}

// CreateBill handles POST /api/bills.
func (h *BillsHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req createBillRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.Name == "" || req.Amount <= 0 || req.AccountID == "" || req.NextDueDate == "" {
		writeError(w, http.StatusBadRequest, "name, amount, account_id, and next_due_date are required")
		return
	}

	validPeriods := map[string]bool{"weekly": true, "monthly": true, "quarterly": true, "yearly": true}
	if !validPeriods[req.Period] {
		writeError(w, http.StatusBadRequest, "period must be: weekly, monthly, quarterly, yearly")
		return
	}

	dueDate, err := time.Parse("2006-01-02", req.NextDueDate)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid next_due_date format, use YYYY-MM-DD")
		return
	}

	if req.CurrencyCode == "" {
		req.CurrencyCode = "INR"
	}

	active := true
	if req.Active != nil {
		active = *req.Active
	}

	bill := models.Bill{
		ID:           uuid.New().String(),
		UserID:       userID,
		Name:         req.Name,
		Amount:       req.Amount,
		CurrencyCode: req.CurrencyCode,
		Period:       req.Period,
		NextDueDate:  dueDate,
		AccountID:    req.AccountID,
		CategoryID:   req.CategoryID,
		Notes:        req.Notes,
		Active:       active,
	}

	if err := h.db.Create(&bill).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to create bill")
		return
	}

	writeJSON(w, http.StatusCreated, bill)
}

// GetBill handles GET /api/bills/{id}.
func (h *BillsHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var bill models.Bill
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&bill).Error; err != nil {
		writeError(w, http.StatusNotFound, "Bill not found")
		return
	}

	writeJSON(w, http.StatusOK, bill)
}

// UpdateBill handles PUT /api/bills/{id}.
func (h *BillsHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var bill models.Bill
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&bill).Error; err != nil {
		writeError(w, http.StatusNotFound, "Bill not found")
		return
	}

	var req createBillRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	updates := map[string]interface{}{}
	if req.Name != "" {
		updates["name"] = req.Name
	}
	if req.Amount > 0 {
		updates["amount"] = req.Amount
	}
	if req.CurrencyCode != "" {
		updates["currency_code"] = req.CurrencyCode
	}
	if req.Period != "" {
		updates["period"] = req.Period
	}
	if req.NextDueDate != "" {
		if t, err := time.Parse("2006-01-02", req.NextDueDate); err == nil {
			updates["next_due_date"] = t
		}
	}
	if req.AccountID != "" {
		updates["account_id"] = req.AccountID
	}
	updates["category_id"] = req.CategoryID
	updates["notes"] = req.Notes
	if req.Active != nil {
		updates["active"] = *req.Active
	}

	if err := h.db.Model(&bill).Updates(updates).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update bill")
		return
	}

	writeJSON(w, http.StatusOK, bill)
}

// DeleteBill handles DELETE /api/bills/{id}.
func (h *BillsHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var bill models.Bill
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&bill).Error; err != nil {
		writeError(w, http.StatusNotFound, "Bill not found")
		return
	}

	if err := h.db.Delete(&bill).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete bill")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "Bill deleted successfully"})
}

// GetUpcoming handles GET /api/bills/upcoming.
func (h *BillsHandler) GetUpcoming(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	days := 30
	if d := r.URL.Query().Get("days"); d != "" {
		if v := parseInt(d); v > 0 && v <= 365 {
			days = v
		}
	}

	now := time.Now().UTC()
	future := now.AddDate(0, 0, days)

	var bills []models.Bill
	if err := h.db.Where("user_id = ? AND active = true AND next_due_date BETWEEN ? AND ?",
		userID, now, future).Order("next_due_date ASC").Find(&bills).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch upcoming bills")
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"bills": bills,
		"from":  now,
		"to":    future,
		"days":  days,
	})
}

// timeNow returns current UTC time (testable helper).
func timeNow() time.Time {
	return time.Now().UTC()
}
