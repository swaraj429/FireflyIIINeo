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

// BudgetsHandler handles budget endpoints.
type BudgetsHandler struct {
	db *gorm.DB
}

// NewBudgetsHandler creates a new BudgetsHandler.
func NewBudgetsHandler(db *gorm.DB) *BudgetsHandler {
	return &BudgetsHandler{db: db}
}

// createBudgetRequest is the payload for creating a budget.
type createBudgetRequest struct {
	Name       string     `json:"name"`
	Amount     float64    `json:"amount"`
	Period     string     `json:"period"`
	StartDate  string     `json:"start_date"`
	EndDate    *string    `json:"end_date"`
	CategoryID *string    `json:"category_id"`
	Active     *bool      `json:"active"`
}

// budgetUsageResponse is the response for GET /api/budgets/{id}/usage.
type budgetUsageResponse struct {
	BudgetID   string    `json:"budget_id"`
	Name       string    `json:"name"`
	Amount     float64   `json:"amount"`
	Spent      float64   `json:"spent"`
	Remaining  float64   `json:"remaining"`
	Percentage float64   `json:"percentage"`
	Period     string    `json:"period"`
	StartDate  time.Time `json:"start_date"`
	EndDate    *time.Time `json:"end_date,omitempty"`
}

// List handles GET /api/budgets.
func (h *BudgetsHandler) List(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	query := h.db.Where("user_id = ?", userID)
	if a := r.URL.Query().Get("active"); a != "" {
		query = query.Where("active = ?", a == "true")
	}

	var budgets []models.Budget
	if err := query.Order("name ASC").Find(&budgets).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch budgets")
		return
	}

	writeJSON(w, http.StatusOK, budgets)
}

// Create handles POST /api/budgets.
func (h *BudgetsHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req createBudgetRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.Name == "" || req.Amount <= 0 {
		writeError(w, http.StatusBadRequest, "name and positive amount are required")
		return
	}

	validPeriods := map[string]bool{"weekly": true, "monthly": true, "quarterly": true, "yearly": true}
	if !validPeriods[req.Period] {
		writeError(w, http.StatusBadRequest, "period must be: weekly, monthly, quarterly, yearly")
		return
	}

	startDate := time.Now()
	if req.StartDate != "" {
		if t, err := time.Parse("2006-01-02", req.StartDate); err == nil {
			startDate = t
		}
	}

	var endDate *time.Time
	if req.EndDate != nil {
		if t, err := time.Parse("2006-01-02", *req.EndDate); err == nil {
			endDate = &t
		}
	}

	active := true
	if req.Active != nil {
		active = *req.Active
	}

	budget := models.Budget{
		ID:         uuid.New().String(),
		UserID:     userID,
		Name:       req.Name,
		Amount:     req.Amount,
		Period:     req.Period,
		StartDate:  startDate,
		EndDate:    endDate,
		CategoryID: req.CategoryID,
		Active:     active,
	}

	if err := h.db.Create(&budget).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to create budget")
		return
	}

	writeJSON(w, http.StatusCreated, budget)
}

// Get handles GET /api/budgets/{id}.
func (h *BudgetsHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var budget models.Budget
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&budget).Error; err != nil {
		writeError(w, http.StatusNotFound, "Budget not found")
		return
	}

	writeJSON(w, http.StatusOK, budget)
}

// Update handles PUT /api/budgets/{id}.
func (h *BudgetsHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var budget models.Budget
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&budget).Error; err != nil {
		writeError(w, http.StatusNotFound, "Budget not found")
		return
	}

	var req createBudgetRequest
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
	if req.Period != "" {
		updates["period"] = req.Period
	}
	if req.StartDate != "" {
		if t, err := time.Parse("2006-01-02", req.StartDate); err == nil {
			updates["start_date"] = t
		}
	}
	if req.EndDate != nil {
		if t, err := time.Parse("2006-01-02", *req.EndDate); err == nil {
			updates["end_date"] = t
		}
	}
	updates["category_id"] = req.CategoryID
	if req.Active != nil {
		updates["active"] = *req.Active
	}

	if err := h.db.Model(&budget).Updates(updates).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update budget")
		return
	}

	writeJSON(w, http.StatusOK, budget)
}

// Delete handles DELETE /api/budgets/{id}.
func (h *BudgetsHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var budget models.Budget
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&budget).Error; err != nil {
		writeError(w, http.StatusNotFound, "Budget not found")
		return
	}

	if err := h.db.Delete(&budget).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete budget")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "Budget deleted successfully"})
}

// GetUsage handles GET /api/budgets/{id}/usage.
func (h *BudgetsHandler) GetUsage(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")

	var budget models.Budget
	if err := h.db.Where("id = ? AND user_id = ?", id, userID).First(&budget).Error; err != nil {
		writeError(w, http.StatusNotFound, "Budget not found")
		return
	}

	// Determine current period window
	start, end := currentPeriodWindow(budget.Period, budget.StartDate)

	type spentResult struct {
		Total float64
	}
	var spent spentResult

	query := h.db.Raw(`
		SELECT COALESCE(SUM(amount), 0) AS total
		FROM transactions
		WHERE deleted_at IS NULL AND user_id = ? AND type = 'withdrawal'
		  AND budget_id = ? AND date BETWEEN ? AND ?
	`, userID, id, start, end)

	// If budget has a category, filter by category too
	if budget.CategoryID != nil {
		query = h.db.Raw(`
			SELECT COALESCE(SUM(amount), 0) AS total
			FROM transactions
			WHERE deleted_at IS NULL AND user_id = ? AND type = 'withdrawal'
			  AND (budget_id = ? OR category_id = ?) AND date BETWEEN ? AND ?
		`, userID, id, *budget.CategoryID, start, end)
	}

	query.Scan(&spent)

	remaining := budget.Amount - spent.Total
	pct := 0.0
	if budget.Amount > 0 {
		pct = (spent.Total / budget.Amount) * 100
	}

	writeJSON(w, http.StatusOK, budgetUsageResponse{
		BudgetID:   budget.ID,
		Name:       budget.Name,
		Amount:     budget.Amount,
		Spent:      spent.Total,
		Remaining:  remaining,
		Percentage: pct,
		Period:     budget.Period,
		StartDate:  start,
		EndDate:    budget.EndDate,
	})
}

// GetSummary handles GET /api/budgets/summary.
func (h *BudgetsHandler) GetSummary(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var budgets []models.Budget
	if err := h.db.Where("user_id = ? AND active = true", userID).Find(&budgets).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch budgets")
		return
	}

	summaries := make([]budgetUsageResponse, 0, len(budgets))
	for _, budget := range budgets {
		start, end := currentPeriodWindow(budget.Period, budget.StartDate)

		type spentResult struct {
			Total float64
		}
		var spent spentResult

		h.db.Raw(`
			SELECT COALESCE(SUM(amount), 0) AS total
			FROM transactions
			WHERE deleted_at IS NULL AND user_id = ? AND type = 'withdrawal'
			  AND budget_id = ? AND date BETWEEN ? AND ?
		`, userID, budget.ID, start, end).Scan(&spent)

		remaining := budget.Amount - spent.Total
		pct := 0.0
		if budget.Amount > 0 {
			pct = (spent.Total / budget.Amount) * 100
		}

		summaries = append(summaries, budgetUsageResponse{
			BudgetID:   budget.ID,
			Name:       budget.Name,
			Amount:     budget.Amount,
			Spent:      spent.Total,
			Remaining:  remaining,
			Percentage: pct,
			Period:     budget.Period,
			StartDate:  start,
			EndDate:    budget.EndDate,
		})
	}

	writeJSON(w, http.StatusOK, summaries)
}

// currentPeriodWindow returns the start and end of the current budget period.
func currentPeriodWindow(period string, startDate time.Time) (time.Time, time.Time) {
	now := time.Now()
	switch period {
	case "weekly":
		// Start of current week
		weekday := int(now.Weekday())
		if weekday == 0 {
			weekday = 7
		}
		start := now.AddDate(0, 0, -(weekday - 1))
		start = time.Date(start.Year(), start.Month(), start.Day(), 0, 0, 0, 0, time.UTC)
		end := start.AddDate(0, 0, 7).Add(-time.Second)
		return start, end
	case "monthly":
		start := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
		end := start.AddDate(0, 1, 0).Add(-time.Second)
		return start, end
	case "quarterly":
		quarter := (int(now.Month()) - 1) / 3
		startMonth := time.Month(quarter*3 + 1)
		start := time.Date(now.Year(), startMonth, 1, 0, 0, 0, 0, time.UTC)
		end := start.AddDate(0, 3, 0).Add(-time.Second)
		return start, end
	case "yearly":
		start := time.Date(now.Year(), 1, 1, 0, 0, 0, 0, time.UTC)
		end := start.AddDate(1, 0, 0).Add(-time.Second)
		return start, end
	default:
		// Custom: use the budget's start date and end of that month
		start := time.Date(startDate.Year(), startDate.Month(), 1, 0, 0, 0, 0, time.UTC)
		end := start.AddDate(0, 1, 0).Add(-time.Second)
		return start, end
	}
}
