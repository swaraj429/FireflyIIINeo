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

// AccountsHandler handles account CRUD endpoints.
type AccountsHandler struct {
	db *gorm.DB
}

// NewAccountsHandler creates a new AccountsHandler.
func NewAccountsHandler(db *gorm.DB) *AccountsHandler {
	return &AccountsHandler{db: db}
}

// createAccountRequest is the payload for creating an account.
type createAccountRequest struct {
	Name           string  `json:"name"`
	Type           string  `json:"type"`
	CurrencyCode   string  `json:"currency_code"`
	CurrentBalance float64 `json:"current_balance"`
	IBAN           string  `json:"iban"`
	AccountNumber  string  `json:"account_number"`
	BankName       string  `json:"bank_name"`
	Notes          string  `json:"notes"`
	Active         *bool   `json:"active"`
	Order          int     `json:"order"`
}

// accountSummaryResponse is the response for GET /api/accounts/{id}/summary.
type accountSummaryResponse struct {
	AccountID      string    `json:"account_id"`
	Name           string    `json:"name"`
	CurrentBalance float64   `json:"current_balance"`
	TotalIn        float64   `json:"total_in"`
	TotalOut       float64   `json:"total_out"`
	TxCount        int64     `json:"tx_count"`
	LastActivity   time.Time `json:"last_activity"`
}

// List handles GET /api/accounts.
func (h *AccountsHandler) List(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	query := h.db.Where("user_id = ?", userID)

	// Optional filter: type
	if t := r.URL.Query().Get("type"); t != "" {
		query = query.Where("type = ?", t)
	}
	// Optional filter: active
	if a := r.URL.Query().Get("active"); a != "" {
		active := a == "true"
		query = query.Where("active = ?", active)
	}

	var accounts []models.Account
	if err := query.Order("`order` ASC, name ASC").Find(&accounts).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch accounts")
		return
	}

	writeJSON(w, http.StatusOK, accounts)
}

// Create handles POST /api/accounts.
func (h *AccountsHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req createAccountRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.Name == "" || req.Type == "" {
		writeError(w, http.StatusBadRequest, "name and type are required")
		return
	}

	validTypes := map[string]bool{"asset": true, "expense": true, "revenue": true, "liability": true}
	if !validTypes[req.Type] {
		writeError(w, http.StatusBadRequest, "type must be one of: asset, expense, revenue, liability")
		return
	}

	if req.CurrencyCode == "" {
		req.CurrencyCode = "INR"
	}

	active := true
	if req.Active != nil {
		active = *req.Active
	}

	account := models.Account{
		ID:             uuid.New().String(),
		UserID:         userID,
		Name:           req.Name,
		Type:           req.Type,
		CurrencyCode:   req.CurrencyCode,
		CurrentBalance: req.CurrentBalance,
		IBAN:           req.IBAN,
		AccountNumber:  req.AccountNumber,
		BankName:       req.BankName,
		Notes:          req.Notes,
		Active:         active,
		Order:          req.Order,
	}

	if err := h.db.Create(&account).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to create account")
		return
	}

	writeJSON(w, http.StatusCreated, account)
}

// Get handles GET /api/accounts/{id}.
func (h *AccountsHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var account models.Account
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&account).Error; err != nil {
		writeError(w, http.StatusNotFound, "Account not found")
		return
	}

	writeJSON(w, http.StatusOK, account)
}

// Update handles PUT /api/accounts/{id}.
func (h *AccountsHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var account models.Account
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&account).Error; err != nil {
		writeError(w, http.StatusNotFound, "Account not found")
		return
	}

	var req createAccountRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	updates := map[string]interface{}{}
	if req.Name != "" {
		updates["name"] = req.Name
	}
	if req.Type != "" {
		validTypes := map[string]bool{"asset": true, "expense": true, "revenue": true, "liability": true}
		if !validTypes[req.Type] {
			writeError(w, http.StatusBadRequest, "Invalid account type")
			return
		}
		updates["type"] = req.Type
	}
	if req.CurrencyCode != "" {
		updates["currency_code"] = req.CurrencyCode
	}
	updates["current_balance"] = req.CurrentBalance
	if req.IBAN != "" {
		updates["iban"] = req.IBAN
	}
	if req.AccountNumber != "" {
		updates["account_number"] = req.AccountNumber
	}
	if req.BankName != "" {
		updates["bank_name"] = req.BankName
	}
	updates["notes"] = req.Notes
	if req.Active != nil {
		updates["active"] = *req.Active
	}
	updates["order"] = req.Order

	if err := h.db.Model(&account).Updates(updates).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update account")
		return
	}

	writeJSON(w, http.StatusOK, account)
}

// Delete handles DELETE /api/accounts/{id}.
func (h *AccountsHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var account models.Account
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&account).Error; err != nil {
		writeError(w, http.StatusNotFound, "Account not found")
		return
	}

	if err := h.db.Delete(&account).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete account")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "Account deleted successfully"})
}

// GetTransactions handles GET /api/accounts/{id}/transactions.
func (h *AccountsHandler) GetTransactions(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	// Verify account ownership
	var account models.Account
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&account).Error; err != nil {
		writeError(w, http.StatusNotFound, "Account not found")
		return
	}

	pagination := parsePagination(r)
	offset := (pagination.Page - 1) * pagination.Limit

	query := h.db.Where("user_id = ? AND (source_account_id = ? OR dest_account_id = ?)", userID, id, id)

	// Date filters
	if start := r.URL.Query().Get("start"); start != "" {
		if t, err := time.Parse(time.RFC3339, start); err == nil {
			query = query.Where("date >= ?", t)
		}
	}
	if end := r.URL.Query().Get("end"); end != "" {
		if t, err := time.Parse(time.RFC3339, end); err == nil {
			query = query.Where("date <= ?", t)
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

// GetSummary handles GET /api/accounts/{id}/summary.
func (h *AccountsHandler) GetSummary(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var account models.Account
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&account).Error; err != nil {
		writeError(w, http.StatusNotFound, "Account not found")
		return
	}

	// Calculate totals from transactions
	type result struct {
		TotalIn  float64
		TotalOut float64
		TxCount  int64
	}

	var res result

	h.db.Raw(`
		SELECT
			COALESCE(SUM(CASE WHEN dest_account_id = ? OR (type = 'deposit' AND source_account_id = ?) THEN amount ELSE 0 END), 0) AS total_in,
			COALESCE(SUM(CASE WHEN source_account_id = ? AND type = 'withdrawal' THEN amount ELSE 0 END), 0) AS total_out,
			COUNT(*) AS tx_count
		FROM transactions
		WHERE deleted_at IS NULL AND user_id = ? AND (source_account_id = ? OR dest_account_id = ?)
	`, id, id, id, userID, id, id).Scan(&res)

	var lastTx models.Transaction
	var lastActivity time.Time
	if err := h.db.Where("user_id = ? AND (source_account_id = ? OR dest_account_id = ?)", userID, id, id).
		Order("date DESC").First(&lastTx).Error; err == nil {
		lastActivity = lastTx.Date
	}

	writeJSON(w, http.StatusOK, accountSummaryResponse{
		AccountID:      account.ID,
		Name:           account.Name,
		CurrentBalance: account.CurrentBalance,
		TotalIn:        res.TotalIn,
		TotalOut:       res.TotalOut,
		TxCount:        res.TxCount,
		LastActivity:   lastActivity,
	})
}
