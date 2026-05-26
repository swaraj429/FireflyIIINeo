package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/fireflyneo/neo-backend/internal/middleware"
	"github.com/fireflyneo/neo-backend/internal/models"
	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// SMSHandler handles SMS ingest and management.
type SMSHandler struct{ DB *gorm.DB }

// IngestSMSRequest is the body for POST /api/sms/ingest.
type IngestSMSRequest struct {
	Sender         string   `json:"sender"`
	Body           string   `json:"body"`
	ReceivedAt     string   `json:"received_at"`
	ParsedAmount   *float64 `json:"parsed_amount"`
	ParsedMerchant string   `json:"parsed_merchant"`
	ParsedType     string   `json:"parsed_type"` // debit | credit
	DuplicateHash  string   `json:"duplicate_hash"`
}

// IngestSMS handles POST /api/sms/ingest
func (h *SMSHandler) IngestSMS(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	var req IngestSMSRequest
	if err := DecodeJSON(r, &req); err != nil {
		Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// Duplicate check by internal_ref
	if req.DuplicateHash != "" {
		var count int64
		h.DB.Model(&models.SMSMessage{}).Where("user_id=? AND duplicate_of=?", userID, req.DuplicateHash).Count(&count)
		if count > 0 {
			JSON(w, http.StatusOK, map[string]string{"status": "duplicate"})
			return
		}
	}

	receivedAt := time.Now()
	if t, err := time.Parse(time.RFC3339, req.ReceivedAt); err == nil {
		receivedAt = t
	}

	msg := models.SMSMessage{
		ID:             uuid.NewString(),
		UserID:         userID,
		Sender:         req.Sender,
		Body:           req.Body,
		ReceivedAt:     receivedAt,
		ParsedAmount:   req.ParsedAmount,
		ParsedMerchant: req.ParsedMerchant,
		ParsedType:     req.ParsedType,
		DuplicateOf:    &req.DuplicateHash,
		CreatedAt:      time.Now(),
	}
	if err := h.DB.Create(&msg).Error; err != nil {
		Error(w, http.StatusInternalServerError, err.Error())
		return
	}
	JSON(w, http.StatusCreated, msg)
}

// ListSMSMessages handles GET /api/sms/messages?page=1&limit=50&pending=true
func (h *SMSHandler) ListSMSMessages(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	if page < 1 {
		page = 1
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit < 1 || limit > 100 {
		limit = 50
	}
	offset := (page - 1) * limit
	pending := r.URL.Query().Get("pending") == "true"

	query := h.DB.Where("user_id=?", userID)
	if pending {
		query = query.Where("parsed=? AND transaction_id IS NULL", false)
	}

	var total int64
	query.Model(&models.SMSMessage{}).Count(&total)

	var messages []models.SMSMessage
	query.Order("received_at DESC").Offset(offset).Limit(limit).Find(&messages)

	JSON(w, http.StatusOK, map[string]interface{}{
		"data":       messages,
		"total":      total,
		"page":       page,
		"limit":      limit,
		"total_pages": (total + int64(limit) - 1) / int64(limit),
	})
}

// ApproveApproveRequest is the body for approving an SMS as a transaction.
type ApproveRequest struct {
	Description     string  `json:"description"`
	CategoryID      *string `json:"category_id"`
	SourceAccountID string  `json:"source_account_id"`
}

// ApproveSMS handles POST /api/sms/messages/{id}/approve
func (h *SMSHandler) ApproveSMS(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var msg models.SMSMessage
	if err := h.DB.Where("id=? AND user_id=?", id, userID).First(&msg).Error; err != nil {
		Error(w, http.StatusNotFound, "SMS message not found")
		return
	}

	var req ApproveRequest
	if err := DecodeJSON(r, &req); err != nil {
		Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// Create transaction from SMS
	txType := "withdrawal"
	if msg.ParsedType == "credit" {
		txType = "deposit"
	}
	amount := 0.0
	if msg.ParsedAmount != nil {
		amount = *msg.ParsedAmount
	}
	sourceAccountID := req.SourceAccountID
	if sourceAccountID == "" {
		// Use first active asset account
		var acc models.Account
		h.DB.Where("user_id=? AND type IN ? AND active=?", userID, []string{"asset", "cash"}, true).First(&acc)
		sourceAccountID = acc.ID
	}

	description := req.Description
	if description == "" {
		description = msg.ParsedMerchant
	}
	if description == "" {
		description = "SMS Import: " + msg.Sender
	}

	txID := uuid.NewString()
	tx := models.Transaction{
		ID:              txID,
		UserID:          userID,
		Type:            txType,
		Description:     description,
		Date:            msg.ReceivedAt,
		Amount:          amount,
		CurrencyCode:    "INR",
		SourceAccountID: sourceAccountID,
		CategoryID:      req.CategoryID,
		MerchantName:    msg.ParsedMerchant,
		SMSSource:       true,
		SMSSender:       msg.Sender,
		InternalRef:     id,
		CreatedAt:       time.Now(),
		UpdatedAt:       time.Now(),
	}
	if err := h.DB.Create(&tx).Error; err != nil {
		Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	// Update account balance
	if txType == "withdrawal" {
		h.DB.Model(&models.Account{}).Where("id=?", sourceAccountID).Update("current_balance", gorm.Expr("current_balance - ?", amount))
	} else {
		h.DB.Model(&models.Account{}).Where("id=?", sourceAccountID).Update("current_balance", gorm.Expr("current_balance + ?", amount))
	}

	// Mark SMS as parsed
	h.DB.Model(&msg).Updates(map[string]interface{}{"parsed": true, "transaction_id": txID})

	JSON(w, http.StatusOK, tx)
}

// RejectSMS handles POST /api/sms/messages/{id}/reject
func (h *SMSHandler) RejectSMS(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.DB.Where("id=? AND user_id=?", id, userID).Updates(&models.SMSMessage{Parsed: true}).Error; err != nil {
		Error(w, http.StatusNotFound, "SMS message not found")
		return
	}
	JSON(w, http.StatusOK, map[string]string{"status": "rejected"})
}

// DeleteSMSMessage handles DELETE /api/sms/messages/{id}
func (h *SMSHandler) DeleteSMSMessage(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.DB.Where("id=? AND user_id=?", id, userID).Delete(&models.SMSMessage{}).Error; err != nil {
		Error(w, http.StatusNotFound, "Not found")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
