package handlers

import (
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/fireflyneo/neo-backend/internal/middleware"
	"github.com/fireflyneo/neo-backend/internal/models"
	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// TransactionsHandler handles transaction CRUD endpoints.
type TransactionsHandler struct {
	db *gorm.DB
}

// NewTransactionsHandler creates a new TransactionsHandler.
func NewTransactionsHandler(db *gorm.DB) *TransactionsHandler {
	return &TransactionsHandler{db: db}
}

// createTransactionRequest is the payload for creating a transaction.
type createTransactionRequest struct {
	Type            string   `json:"type"`
	Description     string   `json:"description"`
	Date            string   `json:"date"`
	Amount          float64  `json:"amount"`
	CurrencyCode    string   `json:"currency_code"`
	ForeignAmount   *float64 `json:"foreign_amount"`
	ForeignCurrency *string  `json:"foreign_currency"`
	SourceAccountID string   `json:"source_account_id"`
	DestAccountID   *string  `json:"dest_account_id"`
	CategoryID      *string  `json:"category_id"`
	BudgetID        *string  `json:"budget_id"`
	MerchantName    string   `json:"merchant_name"`
	Notes           string   `json:"notes"`
	Tags            []string `json:"tags"`
	Reconciled      bool     `json:"reconciled"`
	InternalRef     string   `json:"internal_ref"`
	SMSSource       bool     `json:"sms_source"`
	SMSSender       string   `json:"sms_sender"`
}

// bulkDeleteRequest is the payload for bulk deletion.
type bulkDeleteRequest struct {
	IDs []string `json:"ids"`
}

// bulkCategorizeRequest is the payload for bulk categorization.
type bulkCategorizeRequest struct {
	IDs        []string `json:"ids"`
	CategoryID string   `json:"category_id"`
	BudgetID   *string  `json:"budget_id,omitempty"`
}

// List handles GET /api/transactions with full filtering, search, and pagination.
func (h *TransactionsHandler) List(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	pagination := parsePagination(r)
	offset := (pagination.Page - 1) * pagination.Limit

	query := h.db.Where("user_id = ?", userID)

	// Filters
	if t := r.URL.Query().Get("type"); t != "" {
		query = query.Where("type = ?", t)
	}
	if account := r.URL.Query().Get("account_id"); account != "" {
		query = query.Where("source_account_id = ? OR dest_account_id = ?", account, account)
	}
	if cat := r.URL.Query().Get("category_id"); cat != "" {
		if cat == "none" {
			query = query.Where("category_id IS NULL")
		} else {
			query = query.Where("category_id = ?", cat)
		}
	}
	if budget := r.URL.Query().Get("budget_id"); budget != "" {
		query = query.Where("budget_id = ?", budget)
	}
	if reconciled := r.URL.Query().Get("reconciled"); reconciled != "" {
		query = query.Where("reconciled = ?", reconciled == "true")
	}
	if smsOnly := r.URL.Query().Get("sms_source"); smsOnly == "true" {
		query = query.Where("sms_source = true")
	}
	if merchant := r.URL.Query().Get("merchant"); merchant != "" {
		query = query.Where("merchant_name LIKE ?", "%"+merchant+"%")
	}

	// Date range
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

	// Amount range
	if amtMin := r.URL.Query().Get("amount_min"); amtMin != "" {
		if v := parseFloat(amtMin); v > 0 {
			query = query.Where("amount >= ?", v)
		}
	}
	if amtMax := r.URL.Query().Get("amount_max"); amtMax != "" {
		if v := parseFloat(amtMax); v > 0 {
			query = query.Where("amount <= ?", v)
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

// Create handles POST /api/transactions.
func (h *TransactionsHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req createTransactionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validation
	validTypes := map[string]bool{"withdrawal": true, "deposit": true, "transfer": true}
	if !validTypes[req.Type] {
		writeError(w, http.StatusBadRequest, "type must be one of: withdrawal, deposit, transfer")
		return
	}
	if req.Amount <= 0 {
		writeError(w, http.StatusBadRequest, "amount must be positive")
		return
	}
	if req.SourceAccountID == "" {
		writeError(w, http.StatusBadRequest, "source_account_id is required")
		return
	}
	if req.Type == "transfer" && (req.DestAccountID == nil || *req.DestAccountID == "") {
		writeError(w, http.StatusBadRequest, "dest_account_id is required for transfers")
		return
	}

	// Parse date
	txDate := time.Now()
	if req.Date != "" {
		if t, err := time.Parse(time.RFC3339, req.Date); err == nil {
			txDate = t
		} else if t, err := time.Parse("2006-01-02", req.Date); err == nil {
			txDate = t
		}
	}

	if req.CurrencyCode == "" {
		req.CurrencyCode = "INR"
	}

	// Serialize tags
	tagsJSON := "[]"
	if len(req.Tags) > 0 {
		b, _ := json.Marshal(req.Tags)
		tagsJSON = string(b)
	}

	tx := models.Transaction{
		ID:              uuid.New().String(),
		UserID:          userID,
		Type:            req.Type,
		Description:     req.Description,
		Date:            txDate,
		Amount:          req.Amount,
		CurrencyCode:    req.CurrencyCode,
		ForeignAmount:   req.ForeignAmount,
		ForeignCurrency: req.ForeignCurrency,
		SourceAccountID: req.SourceAccountID,
		DestAccountID:   req.DestAccountID,
		CategoryID:      req.CategoryID,
		BudgetID:        req.BudgetID,
		MerchantName:    req.MerchantName,
		Notes:           req.Notes,
		Tags:            tagsJSON,
		Reconciled:      req.Reconciled,
		InternalRef:     req.InternalRef,
		SMSSource:       req.SMSSource,
		SMSSender:       req.SMSSender,
	}

	if err := h.db.Create(&tx).Error; err != nil {
		if strings.Contains(err.Error(), "UNIQUE") {
			writeError(w, http.StatusConflict, "Duplicate transaction detected")
			return
		}
		writeError(w, http.StatusInternalServerError, "Failed to create transaction")
		return
	}

	// Update account balance
	h.updateAccountBalance(userID, req.SourceAccountID)
	if req.DestAccountID != nil {
		h.updateAccountBalance(userID, *req.DestAccountID)
	}

	writeJSON(w, http.StatusCreated, tx)
}

// Get handles GET /api/transactions/{id}.
func (h *TransactionsHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var tx models.Transaction
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&tx).Error; err != nil {
		writeError(w, http.StatusNotFound, "Transaction not found")
		return
	}

	writeJSON(w, http.StatusOK, tx)
}

// Update handles PUT /api/transactions/{id}.
func (h *TransactionsHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var tx models.Transaction
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&tx).Error; err != nil {
		writeError(w, http.StatusNotFound, "Transaction not found")
		return
	}

	var req createTransactionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	oldSourceID := tx.SourceAccountID
	oldDestID := tx.DestAccountID

	updates := map[string]interface{}{}
	if req.Type != "" {
		updates["type"] = req.Type
	}
	if req.Description != "" {
		updates["description"] = req.Description
	}
	if req.Date != "" {
		if t, err := time.Parse(time.RFC3339, req.Date); err == nil {
			updates["date"] = t
		}
	}
	if req.Amount > 0 {
		updates["amount"] = req.Amount
	}
	if req.CurrencyCode != "" {
		updates["currency_code"] = req.CurrencyCode
	}
	if req.SourceAccountID != "" {
		updates["source_account_id"] = req.SourceAccountID
	}
	updates["dest_account_id"] = req.DestAccountID
	updates["category_id"] = req.CategoryID
	updates["budget_id"] = req.BudgetID
	updates["merchant_name"] = req.MerchantName
	updates["notes"] = req.Notes
	updates["reconciled"] = req.Reconciled
	if len(req.Tags) >= 0 {
		b, _ := json.Marshal(req.Tags)
		updates["tags"] = string(b)
	}

	if err := h.db.Model(&tx).Updates(updates).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update transaction")
		return
	}

	// Refresh account balances for affected accounts
	affectedAccounts := map[string]bool{
		oldSourceID: true,
	}
	if oldDestID != nil {
		affectedAccounts[*oldDestID] = true
	}
	if req.SourceAccountID != "" {
		affectedAccounts[req.SourceAccountID] = true
	}
	if req.DestAccountID != nil {
		affectedAccounts[*req.DestAccountID] = true
	}
	for accountID := range affectedAccounts {
		h.updateAccountBalance(userID, accountID)
	}

	writeJSON(w, http.StatusOK, tx)
}

// Delete handles DELETE /api/transactions/{id}.
func (h *TransactionsHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var tx models.Transaction
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&tx).Error; err != nil {
		writeError(w, http.StatusNotFound, "Transaction not found")
		return
	}

	sourceID := tx.SourceAccountID
	destID := tx.DestAccountID

	if err := h.db.Delete(&tx).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete transaction")
		return
	}

	// Update balances
	h.updateAccountBalance(userID, sourceID)
	if destID != nil {
		h.updateAccountBalance(userID, *destID)
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "Transaction deleted successfully"})
}

// Search handles GET /api/transactions/search?q=.
func (h *TransactionsHandler) Search(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	q := r.URL.Query().Get("q")

	if q == "" {
		writeError(w, http.StatusBadRequest, "q (search query) is required")
		return
	}

	pagination := parsePagination(r)
	offset := (pagination.Page - 1) * pagination.Limit
	pattern := "%" + q + "%"

	query := h.db.Where(
		"user_id = ? AND (description LIKE ? OR merchant_name LIKE ? OR notes LIKE ?)",
		userID, pattern, pattern, pattern,
	)

	var total int64
	query.Model(&models.Transaction{}).Count(&total)

	var txs []models.Transaction
	if err := query.Order("date DESC").Limit(pagination.Limit).Offset(offset).Find(&txs).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to search transactions")
		return
	}

	writeJSON(w, http.StatusOK, newPaginatedResponse(txs, pagination.Page, pagination.Limit, total))
}

// BulkDelete handles POST /api/transactions/bulk-delete.
func (h *TransactionsHandler) BulkDelete(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req bulkDeleteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}
	if len(req.IDs) == 0 {
		writeError(w, http.StatusBadRequest, "ids array is required")
		return
	}

	// Fetch affected account IDs before deletion
	var txs []models.Transaction
	h.db.Where("id IN ? AND user_id = ?", req.IDs, userID).Find(&txs)

	affectedAccounts := map[string]bool{}
	for _, tx := range txs {
		affectedAccounts[tx.SourceAccountID] = true
		if tx.DestAccountID != nil {
			affectedAccounts[*tx.DestAccountID] = true
		}
	}

	result := h.db.Where("id IN ? AND user_id = ?", req.IDs, userID).Delete(&models.Transaction{})
	if result.Error != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete transactions")
		return
	}

	// Update all affected account balances
	for accountID := range affectedAccounts {
		h.updateAccountBalance(userID, accountID)
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"message": "Transactions deleted successfully",
		"deleted": result.RowsAffected,
	})
}

// BulkCategorize handles POST /api/transactions/bulk-categorize.
func (h *TransactionsHandler) BulkCategorize(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req bulkCategorizeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}
	if len(req.IDs) == 0 || req.CategoryID == "" {
		writeError(w, http.StatusBadRequest, "ids and category_id are required")
		return
	}

	updates := map[string]interface{}{"category_id": req.CategoryID}
	if req.BudgetID != nil {
		updates["budget_id"] = *req.BudgetID
	}

	result := h.db.Model(&models.Transaction{}).
		Where("id IN ? AND user_id = ?", req.IDs, userID).
		Updates(updates)
	if result.Error != nil {
		writeError(w, http.StatusInternalServerError, "Failed to categorize transactions")
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"message": "Transactions categorized successfully",
		"updated": result.RowsAffected,
	})
}

// updateAccountBalance recalculates and updates the current_balance for an account.
func (h *TransactionsHandler) updateAccountBalance(userID uint, accountID string) {
	type balanceResult struct {
		Balance float64
	}
	var res balanceResult

	h.db.Raw(`
		SELECT
			COALESCE(SUM(
				CASE
					WHEN type = 'deposit' AND source_account_id = ? THEN amount
					WHEN type = 'transfer' AND dest_account_id = ? THEN amount
					WHEN type = 'withdrawal' AND source_account_id = ? THEN -amount
					WHEN type = 'transfer' AND source_account_id = ? THEN -amount
					ELSE 0
				END
			), 0) AS balance
		FROM transactions
		WHERE deleted_at IS NULL AND user_id = ? AND (source_account_id = ? OR dest_account_id = ?)
	`, accountID, accountID, accountID, accountID, userID, accountID, accountID).Scan(&res)

	h.db.Model(&models.Account{}).
		Where("id = ? AND user_id = ?", accountID, userID).
		Update("current_balance", res.Balance)
}

// parseFloat safely parses a string to float64.
func parseFloat(s string) float64 {
	var v float64
	negative := false
	decimal := false
	var decimalFactor float64 = 10

	for i, c := range s {
		if i == 0 && c == '-' {
			negative = true
			continue
		}
		if c == '.' && !decimal {
			decimal = true
			continue
		}
		if c < '0' || c > '9' {
			return 0
		}
		if decimal {
			v += float64(c-'0') / decimalFactor
			decimalFactor *= 10
		} else {
			v = v*10 + float64(c-'0')
		}
	}
	if negative {
		v = -v
	}
	return v
}
