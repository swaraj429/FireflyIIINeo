package router

import (
	"net/http"
	"time"

	"github.com/fireflyneo/neo-backend/internal/handlers"
	"github.com/fireflyneo/neo-backend/internal/middleware"
	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"gorm.io/gorm"
)

// New builds and returns the fully configured chi router.
func New(db *gorm.DB) http.Handler {
	r := chi.NewRouter()

	// ── Global middleware ─────────────────────────────────────────────────────
	r.Use(chimiddleware.RequestID)
	r.Use(chimiddleware.RealIP)
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(chimiddleware.Timeout(60 * time.Second))
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"http://localhost:*", "http://127.0.0.1:*", "http://0.0.0.0:*", "*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		ExposedHeaders:   []string{"Link", "X-Total-Count"},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	// ── Handler instances ─────────────────────────────────────────────────────
	authH := &handlers.AuthHandler{DB: db}
	accountsH := &handlers.AccountsHandler{DB: db}
	txH := &handlers.TransactionsHandler{DB: db}
	catH := &handlers.CategoriesHandler{DB: db}
	budH := &handlers.BudgetsHandler{DB: db}
	tagBillH := &handlers.TagsBillsHandler{DB: db}
	rulesH := &handlers.RulesHandler{DB: db}
	smsH := &handlers.SMSHandler{DB: db}
	analyticsH := &handlers.AnalyticsHandler{DB: db}

	// ── Health check ──────────────────────────────────────────────────────────
	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok","service":"firefly-neo"}`))
	})

	// ── API routes ────────────────────────────────────────────────────────────
	r.Route("/api", func(r chi.Router) {

		// Public auth endpoints
		r.Post("/auth/register", authH.Register)
		r.Post("/auth/login", authH.Login)
		r.Post("/auth/pin-login", authH.PINLogin)

		// Protected endpoints
		r.Group(func(r chi.Router) {
			r.Use(middleware.AuthRequired)

			// Auth / profile
			r.Get("/auth/me", authH.GetMe)
			r.Put("/auth/me", authH.UpdateMe)
			r.Post("/auth/change-password", authH.ChangePassword)

			// Accounts
			r.Get("/accounts", accountsH.ListAccounts)
			r.Post("/accounts", accountsH.CreateAccount)
			r.Get("/accounts/{id}", accountsH.GetAccount)
			r.Put("/accounts/{id}", accountsH.UpdateAccount)
			r.Delete("/accounts/{id}", accountsH.DeleteAccount)
			r.Get("/accounts/{id}/transactions", accountsH.GetAccountTransactions)
			r.Get("/accounts/{id}/summary", accountsH.GetAccountSummary)

			// Transactions
			r.Get("/transactions", txH.ListTransactions)
			r.Post("/transactions", txH.CreateTransaction)
			r.Get("/transactions/search", txH.SearchTransactions)
			r.Get("/transactions/{id}", txH.GetTransaction)
			r.Put("/transactions/{id}", txH.UpdateTransaction)
			r.Delete("/transactions/{id}", txH.DeleteTransaction)
			r.Post("/transactions/bulk-delete", txH.BulkDelete)
			r.Post("/transactions/bulk-categorize", txH.BulkCategorize)

			// Categories
			r.Get("/categories", catH.ListCategories)
			r.Post("/categories", catH.CreateCategory)
			r.Get("/categories/summary", catH.GetSummary)
			r.Get("/categories/{id}", catH.GetCategory)
			r.Put("/categories/{id}", catH.UpdateCategory)
			r.Delete("/categories/{id}", catH.DeleteCategory)
			r.Get("/categories/{id}/transactions", catH.GetCategoryTransactions)

			// Budgets
			r.Get("/budgets", budH.ListBudgets)
			r.Post("/budgets", budH.CreateBudget)
			r.Get("/budgets/summary", budH.GetSummary)
			r.Get("/budgets/{id}", budH.GetBudget)
			r.Put("/budgets/{id}", budH.UpdateBudget)
			r.Delete("/budgets/{id}", budH.DeleteBudget)
			r.Get("/budgets/{id}/usage", budH.GetUsage)

			// Tags
			r.Get("/tags", tagBillH.ListTags)
			r.Post("/tags", tagBillH.CreateTag)
			r.Put("/tags/{id}", tagBillH.UpdateTag)
			r.Delete("/tags/{id}", tagBillH.DeleteTag)

			// Bills
			r.Get("/bills", tagBillH.ListBills)
			r.Post("/bills", tagBillH.CreateBill)
			r.Get("/bills/upcoming", tagBillH.GetUpcomingBills)
			r.Get("/bills/{id}", tagBillH.GetBill)
			r.Put("/bills/{id}", tagBillH.UpdateBill)
			r.Delete("/bills/{id}", tagBillH.DeleteBill)

			// Rules
			r.Get("/rules", rulesH.ListRules)
			r.Post("/rules", rulesH.CreateRule)
			r.Get("/rules/{id}", rulesH.GetRule)
			r.Put("/rules/{id}", rulesH.UpdateRule)
			r.Delete("/rules/{id}", rulesH.DeleteRule)
			r.Post("/rules/{id}/test", rulesH.TestRule)
			r.Post("/rules/apply-all", rulesH.ApplyAll)

			// SMS
			r.Post("/sms/ingest", smsH.IngestSMS)
			r.Get("/sms/messages", smsH.ListSMSMessages)
			r.Post("/sms/messages/{id}/approve", smsH.ApproveSMS)
			r.Post("/sms/messages/{id}/reject", smsH.RejectSMS)
			r.Delete("/sms/messages/{id}", smsH.DeleteSMSMessage)

			// Analytics
			r.Get("/analytics/dashboard", analyticsH.GetDashboard)
			r.Get("/analytics/cashflow", analyticsH.GetCashflow)
			r.Get("/analytics/category-breakdown", analyticsH.GetCategoryBreakdown)
			r.Get("/analytics/merchant-insights", analyticsH.GetMerchantInsights)
			r.Get("/analytics/budget-progress", analyticsH.GetBudgetProgress)
			r.Get("/analytics/income-vs-expenses", analyticsH.GetIncomeVsExpenses)
			r.Get("/analytics/spending-heatmap", analyticsH.GetSpendingHeatmap)
			r.Get("/analytics/net-worth-history", analyticsH.GetNetWorthHistory)
		})
	})

	return r
}
