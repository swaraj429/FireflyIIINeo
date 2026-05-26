package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/fireflyneo/neo-backend/internal/middleware"
	"github.com/fireflyneo/neo-backend/internal/models"
	"gorm.io/gorm"
)

// AnalyticsHandler holds the DB reference for analytics queries.
type AnalyticsHandler struct{ DB *gorm.DB }

// DashboardResponse is the response shape for GET /api/analytics/dashboard.
type DashboardResponse struct {
	NetWorth         float64 `json:"net_worth"`
	TotalAssets      float64 `json:"total_assets"`
	TotalLiabilities float64 `json:"total_liabilities"`
	MonthlyIncome    float64 `json:"monthly_income"`
	MonthlyExpenses  float64 `json:"monthly_expenses"`
	SavingsRate      float64 `json:"savings_rate"`
}

// GetDashboard handles GET /api/analytics/dashboard
func (h *AnalyticsHandler) GetDashboard(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	now := time.Now()
	startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())

	// Net worth = sum of asset accounts - sum of liability accounts
	var totalAssets, totalLiabilities float64
	h.DB.Model(&models.Account{}).
		Where("user_id = ? AND type IN ? AND active = ?", userID, []string{"asset", "cash"}, true).
		Select("COALESCE(SUM(current_balance),0)").Scan(&totalAssets)
	h.DB.Model(&models.Account{}).
		Where("user_id = ? AND type = ? AND active = ?", userID, "liability", true).
		Select("COALESCE(SUM(current_balance),0)").Scan(&totalLiabilities)

	// Monthly income / expenses
	var monthlyIncome, monthlyExpenses float64
	h.DB.Model(&models.Transaction{}).
		Where("user_id = ? AND type = ? AND date >= ?", userID, "deposit", startOfMonth).
		Select("COALESCE(SUM(amount),0)").Scan(&monthlyIncome)
	h.DB.Model(&models.Transaction{}).
		Where("user_id = ? AND type = ? AND date >= ?", userID, "withdrawal", startOfMonth).
		Select("COALESCE(SUM(amount),0)").Scan(&monthlyExpenses)

	savingsRate := 0.0
	if monthlyIncome > 0 {
		savingsRate = ((monthlyIncome - monthlyExpenses) / monthlyIncome) * 100
	}

	JSON(w, http.StatusOK, DashboardResponse{
		NetWorth:         totalAssets - totalLiabilities,
		TotalAssets:      totalAssets,
		TotalLiabilities: totalLiabilities,
		MonthlyIncome:    monthlyIncome,
		MonthlyExpenses:  monthlyExpenses,
		SavingsRate:      savingsRate,
	})
}

// CashflowEntry represents one month's cashflow.
type CashflowEntry struct {
	Month    string  `json:"month"`
	Income   float64 `json:"income"`
	Expenses float64 `json:"expenses"`
	Savings  float64 `json:"savings"`
}

// GetCashflow handles GET /api/analytics/cashflow?months=12
func (h *AnalyticsHandler) GetCashflow(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	months := 12
	if m, err := strconv.Atoi(r.URL.Query().Get("months")); err == nil && m > 0 && m <= 60 {
		months = m
	}

	entries := make([]CashflowEntry, 0, months)
	now := time.Now()
	for i := months - 1; i >= 0; i-- {
		t := now.AddDate(0, -i, 0)
		start := time.Date(t.Year(), t.Month(), 1, 0, 0, 0, 0, t.Location())
		end := start.AddDate(0, 1, 0)

		var income, expenses float64
		h.DB.Model(&models.Transaction{}).
			Where("user_id=? AND type=? AND date>=? AND date<?", userID, "deposit", start, end).
			Select("COALESCE(SUM(amount),0)").Scan(&income)
		h.DB.Model(&models.Transaction{}).
			Where("user_id=? AND type=? AND date>=? AND date<?", userID, "withdrawal", start, end).
			Select("COALESCE(SUM(amount),0)").Scan(&expenses)

		entries = append(entries, CashflowEntry{
			Month:    start.Format("Jan 2006"),
			Income:   income,
			Expenses: expenses,
			Savings:  income - expenses,
		})
	}
	JSON(w, http.StatusOK, entries)
}

// CategorySpending is one category's total spend.
type CategorySpending struct {
	CategoryID   string  `json:"category_id"`
	CategoryName string  `json:"category_name"`
	Color        string  `json:"color"`
	Amount       float64 `json:"amount"`
	Percentage   float64 `json:"percentage"`
}

// GetCategoryBreakdown handles GET /api/analytics/category-breakdown?start=&end=
func (h *AnalyticsHandler) GetCategoryBreakdown(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	q := r.URL.Query()
	start, end := parseDateRange(q.Get("start"), q.Get("end"))

	type row struct {
		CategoryID   string
		CategoryName string
		Color        string
		Total        float64
	}
	var rows []row
	h.DB.Raw(`
		SELECT t.category_id, COALESCE(c.name,'Uncategorized') AS category_name,
		       COALESCE(c.color,'#6C63FF') AS color, SUM(t.amount) AS total
		FROM transactions t
		LEFT JOIN categories c ON c.id = t.category_id
		WHERE t.user_id = ? AND t.type = 'withdrawal'
		  AND t.date >= ? AND t.date <= ? AND t.deleted_at IS NULL
		GROUP BY t.category_id
		ORDER BY total DESC
	`, userID, start, end).Scan(&rows)

	var grandTotal float64
	for _, r := range rows {
		grandTotal += r.Total
	}
	result := make([]CategorySpending, 0, len(rows))
	for _, r := range rows {
		pct := 0.0
		if grandTotal > 0 {
			pct = (r.Total / grandTotal) * 100
		}
		result = append(result, CategorySpending{
			CategoryID:   r.CategoryID,
			CategoryName: r.CategoryName,
			Color:        r.Color,
			Amount:       r.Total,
			Percentage:   pct,
		})
	}
	JSON(w, http.StatusOK, result)
}

// MerchantInsight is one merchant's analytics.
type MerchantInsight struct {
	MerchantName     string    `json:"merchant_name"`
	TotalSpend       float64   `json:"total_spend"`
	TransactionCount int       `json:"transaction_count"`
	LastSeen         time.Time `json:"last_seen"`
}

// GetMerchantInsights handles GET /api/analytics/merchant-insights?limit=20
func (h *AnalyticsHandler) GetMerchantInsights(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	limit := 20
	if l, err := strconv.Atoi(r.URL.Query().Get("limit")); err == nil && l > 0 {
		limit = l
	}
	var rows []MerchantInsight
	h.DB.Raw(`
		SELECT merchant_name, SUM(amount) AS total_spend,
		       COUNT(*) AS transaction_count, MAX(date) AS last_seen
		FROM transactions
		WHERE user_id=? AND type='withdrawal' AND merchant_name != '' AND deleted_at IS NULL
		GROUP BY merchant_name ORDER BY total_spend DESC LIMIT ?
	`, userID, limit).Scan(&rows)
	JSON(w, http.StatusOK, rows)
}

// BudgetProgress is one budget's progress.
type BudgetProgress struct {
	BudgetID   string  `json:"budget_id"`
	Name       string  `json:"name"`
	Limit      float64 `json:"limit"`
	Spent      float64 `json:"spent"`
	Remaining  float64 `json:"remaining"`
	Percentage float64 `json:"percentage"`
}

// GetBudgetProgress handles GET /api/analytics/budget-progress
func (h *AnalyticsHandler) GetBudgetProgress(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	now := time.Now()
	startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())

	var budgets []models.Budget
	h.DB.Where("user_id=? AND active=?", userID, true).Find(&budgets)

	result := make([]BudgetProgress, 0, len(budgets))
	for _, b := range budgets {
		var spent float64
		query := h.DB.Model(&models.Transaction{}).
			Where("user_id=? AND type='withdrawal' AND date>=?", userID, startOfMonth)
		if b.CategoryID != nil {
			query = query.Where("category_id=?", *b.CategoryID)
		}
		query.Select("COALESCE(SUM(amount),0)").Scan(&spent)

		pct := 0.0
		if b.Amount > 0 {
			pct = (spent / b.Amount) * 100
		}
		result = append(result, BudgetProgress{
			BudgetID:   b.ID,
			Name:       b.Name,
			Limit:      b.Amount,
			Spent:      spent,
			Remaining:  b.Amount - spent,
			Percentage: pct,
		})
	}
	JSON(w, http.StatusOK, result)
}

// IncomeVsExpense is one month's income vs expense summary.
type IncomeVsExpense struct {
	Month    string  `json:"month"`
	Income   float64 `json:"income"`
	Expenses float64 `json:"expenses"`
}

// GetIncomeVsExpenses handles GET /api/analytics/income-vs-expenses?months=6
func (h *AnalyticsHandler) GetIncomeVsExpenses(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	months := 6
	if m, err := strconv.Atoi(r.URL.Query().Get("months")); err == nil && m > 0 {
		months = m
	}
	entries := make([]IncomeVsExpense, 0, months)
	now := time.Now()
	for i := months - 1; i >= 0; i-- {
		t := now.AddDate(0, -i, 0)
		start := time.Date(t.Year(), t.Month(), 1, 0, 0, 0, 0, t.Location())
		end := start.AddDate(0, 1, 0)
		var income, expenses float64
		h.DB.Model(&models.Transaction{}).Where("user_id=? AND type=? AND date>=? AND date<?", userID, "deposit", start, end).Select("COALESCE(SUM(amount),0)").Scan(&income)
		h.DB.Model(&models.Transaction{}).Where("user_id=? AND type=? AND date>=? AND date<?", userID, "withdrawal", start, end).Select("COALESCE(SUM(amount),0)").Scan(&expenses)
		entries = append(entries, IncomeVsExpense{Month: start.Format("Jan 2006"), Income: income, Expenses: expenses})
	}
	JSON(w, http.StatusOK, entries)
}

// SpendingHeatmapEntry is one day's spending.
type SpendingHeatmapEntry struct {
	Date   string  `json:"date"`
	Amount float64 `json:"amount"`
}

// GetSpendingHeatmap handles GET /api/analytics/spending-heatmap?year=2026
func (h *AnalyticsHandler) GetSpendingHeatmap(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	year := time.Now().Year()
	if y, err := strconv.Atoi(r.URL.Query().Get("year")); err == nil && y > 2000 {
		year = y
	}
	start := time.Date(year, 1, 1, 0, 0, 0, 0, time.UTC)
	end := time.Date(year+1, 1, 1, 0, 0, 0, 0, time.UTC)

	type row struct {
		Date  string
		Total float64
	}
	var rows []row
	h.DB.Raw(`
		SELECT DATE(date) AS date, SUM(amount) AS total
		FROM transactions
		WHERE user_id=? AND type='withdrawal' AND date>=? AND date<? AND deleted_at IS NULL
		GROUP BY DATE(date)
	`, userID, start, end).Scan(&rows)

	result := make([]SpendingHeatmapEntry, 0, len(rows))
	for _, r := range rows {
		result = append(result, SpendingHeatmapEntry{Date: r.Date, Amount: r.Total})
	}
	JSON(w, http.StatusOK, result)
}

// NetWorthEntry is one month's net worth snapshot.
type NetWorthEntry struct {
	Month       string  `json:"month"`
	NetWorth    float64 `json:"net_worth"`
	Assets      float64 `json:"assets"`
	Liabilities float64 `json:"liabilities"`
}

// GetNetWorthHistory handles GET /api/analytics/net-worth-history?months=12
// Note: we approximate by summing cumulative transactions per month.
func (h *AnalyticsHandler) GetNetWorthHistory(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	months := 12
	if m, err := strconv.Atoi(r.URL.Query().Get("months")); err == nil && m > 0 {
		months = m
	}

	// Get current balances
	var currentAssets, currentLiabilities float64
	h.DB.Model(&models.Account{}).Where("user_id=? AND type IN ?", userID, []string{"asset", "cash"}).Select("COALESCE(SUM(current_balance),0)").Scan(&currentAssets)
	h.DB.Model(&models.Account{}).Where("user_id=? AND type=?", userID, "liability").Select("COALESCE(SUM(current_balance),0)").Scan(&currentLiabilities)

	now := time.Now()
	entries := make([]NetWorthEntry, 0, months)
	runningAssets := currentAssets
	runningLiabilities := currentLiabilities

	for i := 0; i < months; i++ {
		t := now.AddDate(0, -i, 0)
		start := time.Date(t.Year(), t.Month(), 1, 0, 0, 0, 0, t.Location())
		end := start.AddDate(0, 1, 0)

		var netIncome float64
		h.DB.Raw(`
			SELECT COALESCE(SUM(CASE WHEN type='deposit' THEN amount WHEN type='withdrawal' THEN -amount ELSE 0 END),0)
			FROM transactions WHERE user_id=? AND date>=? AND date<? AND deleted_at IS NULL
		`, userID, start, end).Scan(&netIncome)

		entries = append([]NetWorthEntry{{
			Month:       start.Format("Jan 2006"),
			NetWorth:    runningAssets - runningLiabilities,
			Assets:      runningAssets,
			Liabilities: runningLiabilities,
		}}, entries...)
		runningAssets -= netIncome
	}
	JSON(w, http.StatusOK, entries)
}

// parseDateRange parses start/end query params, defaulting to current month.
func parseDateRange(startStr, endStr string) (time.Time, time.Time) {
	now := time.Now()
	start := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	end := now
	if t, err := time.Parse("2006-01-02", startStr); err == nil {
		start = t
	}
	if t, err := time.Parse("2006-01-02", endStr); err == nil {
		end = t
	}
	return start, end
}
