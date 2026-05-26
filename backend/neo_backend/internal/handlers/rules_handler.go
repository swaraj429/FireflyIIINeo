package handlers

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/fireflyneo/neo-backend/internal/middleware"
	"github.com/fireflyneo/neo-backend/internal/models"
	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// RulesHandler handles rule endpoints.
type RulesHandler struct {
	db *gorm.DB
}

// NewRulesHandler creates a new RulesHandler.
func NewRulesHandler(db *gorm.DB) *RulesHandler {
	return &RulesHandler{db: db}
}

// createRuleRequest is the payload for creating a rule.
type createRuleRequest struct {
	Name        string                `json:"name"`
	Description string                `json:"description"`
	Active      *bool                 `json:"active"`
	StopOnMatch bool                  `json:"stop_on_match"`
	Order       int                   `json:"order"`
	Triggers    []models.RuleTrigger  `json:"triggers"`
	Actions     []models.RuleAction   `json:"actions"`
}

// ruleTestRequest is the payload for testing a rule.
type ruleTestRequest struct {
	TransactionID string `json:"transaction_id"`
}

// ruleTestResponse shows if a rule would match a transaction.
type ruleTestResponse struct {
	Matched  bool     `json:"matched"`
	RuleID   string   `json:"rule_id"`
	RuleName string   `json:"rule_name"`
	Triggers []string `json:"triggers_matched"`
	Actions  []string `json:"actions_would_apply"`
}

// List handles GET /api/rules.
func (h *RulesHandler) List(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var rules []models.Rule
	if err := h.db.Where("user_id = ?", userID).Order("`order` ASC, name ASC").Find(&rules).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch rules")
		return
	}

	writeJSON(w, http.StatusOK, rules)
}

// Create handles POST /api/rules.
func (h *RulesHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req createRuleRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "name is required")
		return
	}

	triggersJSON, err := json.Marshal(req.Triggers)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid triggers")
		return
	}
	actionsJSON, err := json.Marshal(req.Actions)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid actions")
		return
	}

	active := true
	if req.Active != nil {
		active = *req.Active
	}

	rule := models.Rule{
		ID:          uuid.New().String(),
		UserID:      userID,
		Name:        req.Name,
		Description: req.Description,
		Active:      active,
		StopOnMatch: req.StopOnMatch,
		Order:       req.Order,
		Triggers:    string(triggersJSON),
		Actions:     string(actionsJSON),
	}

	if err := h.db.Create(&rule).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to create rule")
		return
	}

	writeJSON(w, http.StatusCreated, rule)
}

// Get handles GET /api/rules/{id}.
func (h *RulesHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var rule models.Rule
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&rule).Error; err != nil {
		writeError(w, http.StatusNotFound, "Rule not found")
		return
	}

	writeJSON(w, http.StatusOK, rule)
}

// Update handles PUT /api/rules/{id}.
func (h *RulesHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var rule models.Rule
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&rule).Error; err != nil {
		writeError(w, http.StatusNotFound, "Rule not found")
		return
	}

	var req createRuleRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	updates := map[string]interface{}{}
	if req.Name != "" {
		updates["name"] = req.Name
	}
	updates["description"] = req.Description
	updates["stop_on_match"] = req.StopOnMatch
	updates["order"] = req.Order
	if req.Active != nil {
		updates["active"] = *req.Active
	}
	if req.Triggers != nil {
		b, _ := json.Marshal(req.Triggers)
		updates["triggers"] = string(b)
	}
	if req.Actions != nil {
		b, _ := json.Marshal(req.Actions)
		updates["actions"] = string(b)
	}

	if err := h.db.Model(&rule).Updates(updates).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update rule")
		return
	}

	writeJSON(w, http.StatusOK, rule)
}

// Delete handles DELETE /api/rules/{id}.
func (h *RulesHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var rule models.Rule
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&rule).Error; err != nil {
		writeError(w, http.StatusNotFound, "Rule not found")
		return
	}

	if err := h.db.Delete(&rule).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete rule")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "Rule deleted successfully"})
}

// Test handles POST /api/rules/{id}/test.
func (h *RulesHandler) Test(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var rule models.Rule
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&rule).Error; err != nil {
		writeError(w, http.StatusNotFound, "Rule not found")
		return
	}

	var req ruleTestRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.TransactionID == "" {
		writeError(w, http.StatusBadRequest, "transaction_id is required")
		return
	}

	var tx models.Transaction
	if err := h.db.Where("id = ? AND user_id = ?", req.TransactionID, userID).First(&tx).Error; err != nil {
		writeError(w, http.StatusNotFound, "Transaction not found")
		return
	}

	// Parse rule triggers
	var triggers []models.RuleTrigger
	json.Unmarshal([]byte(rule.Triggers), &triggers)

	var actions []models.RuleAction
	json.Unmarshal([]byte(rule.Actions), &actions)

	// Evaluate each trigger
	matchedTriggers := []string{}
	allMatch := true

	for _, trigger := range triggers {
		matched := evaluateTrigger(trigger, tx)
		if matched {
			matchedTriggers = append(matchedTriggers, trigger.Type+":"+trigger.Value)
		} else {
			allMatch = false
		}
	}

	actionDescs := []string{}
	for _, action := range actions {
		actionDescs = append(actionDescs, action.Type+":"+action.Value)
	}

	writeJSON(w, http.StatusOK, ruleTestResponse{
		Matched:  allMatch && len(triggers) > 0,
		RuleID:   rule.ID,
		RuleName: rule.Name,
		Triggers: matchedTriggers,
		Actions:  actionDescs,
	})
}

// ApplyAll handles POST /api/rules/apply-all.
func (h *RulesHandler) ApplyAll(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	// Fetch all active rules ordered
	var rules []models.Rule
	h.db.Where("user_id = ? AND active = true", userID).Order("`order` ASC").Find(&rules)

	// Fetch all uncategorized transactions
	var txs []models.Transaction
	h.db.Where("user_id = ? AND category_id IS NULL", userID).Find(&txs)

	applied := 0

	for _, tx := range txs {
		for _, rule := range rules {
			var triggers []models.RuleTrigger
			json.Unmarshal([]byte(rule.Triggers), &triggers)

			var actions []models.RuleAction
			json.Unmarshal([]byte(rule.Actions), &actions)

			// Check all triggers
			allMatch := true
			for _, trigger := range triggers {
				if !evaluateTrigger(trigger, tx) {
					allMatch = false
					break
				}
			}

			if allMatch && len(triggers) > 0 {
				// Apply actions
				updates := map[string]interface{}{}
				for _, action := range actions {
					switch action.Type {
					case "set_category":
						updates["category_id"] = action.Value
					case "set_budget":
						updates["budget_id"] = action.Value
					case "set_merchant":
						updates["merchant_name"] = action.Value
					case "set_description":
						updates["description"] = action.Value
					case "set_reconciled":
						updates["reconciled"] = action.Value == "true"
					}
				}
				if len(updates) > 0 {
					h.db.Model(&tx).Updates(updates)
					applied++
				}

				if rule.StopOnMatch {
					break
				}
			}
		}
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"message":              "Rules applied successfully",
		"transactions_updated": applied,
	})
}

// evaluateTrigger checks if a transaction matches a rule trigger.
func evaluateTrigger(trigger models.RuleTrigger, tx models.Transaction) bool {
	switch trigger.Type {
	case "description_contains":
		return strings.Contains(strings.ToLower(tx.Description), strings.ToLower(trigger.Value))
	case "merchant_is":
		return strings.EqualFold(tx.MerchantName, trigger.Value)
	case "merchant_contains":
		return strings.Contains(strings.ToLower(tx.MerchantName), strings.ToLower(trigger.Value))
	case "sender_is":
		return strings.EqualFold(tx.SMSSender, trigger.Value)
	case "amount_gt":
		v := parseFloat(trigger.Value)
		return tx.Amount > v
	case "amount_lt":
		v := parseFloat(trigger.Value)
		return tx.Amount < v
	case "amount_gte":
		v := parseFloat(trigger.Value)
		return tx.Amount >= v
	case "amount_lte":
		v := parseFloat(trigger.Value)
		return tx.Amount <= v
	case "type_is":
		return strings.EqualFold(tx.Type, trigger.Value)
	case "notes_contains":
		return strings.Contains(strings.ToLower(tx.Notes), strings.ToLower(trigger.Value))
	default:
		return false
	}
}
