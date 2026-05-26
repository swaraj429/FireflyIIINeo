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
	authH := handlers.NewAuthHandler(db)
	accountsH := handlers.NewAccountsHandler(db)
	txH := handlers.NewTransactionsHandler(db)
	catH := handlers.NewCategoriesHandler(db)
	budH := handlers.NewBudgetsHandler(db)
	tagsH := handlers.NewTagsHandler(db)
	billsH := handlers.NewBillsHandler(db)
	rulesH := handlers.NewRulesHandler(db)
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
			r.Get("/auth/me", authH.Me)
			r.Put("/auth/me", authH.UpdateMe)
			r.Post("/auth/change-password", authH.ChangePassword)

			// Accounts
			r.Get("/accounts", accountsH.List)
			r.Post("/accounts", accountsH.Create)
			r.Get("/accounts/{id}", accountsH.Get)
			r.Put("/accounts/{id}", accountsH.Update)
			r.Delete("/accounts/{id}", accountsH.Delete)
			r.Get("/accounts/{id}/transactions", accountsH.GetTransactions)
			r.Get("/accounts/{id}/summary", accountsH.GetSummary)

			// Transactions
			r.Get("/transactions", txH.List)
			r.Post("/transactions", txH.Create)
			r.Get("/transactions/search", txH.Search)
			r.Get("/transactions/{id}", txH.Get)
			r.Put("/transactions/{id}", txH.Update)
			r.Delete("/transactions/{id}", txH.Delete)
			r.Post("/transactions/bulk-delete", txH.BulkDelete)
			r.Post("/transactions/bulk-categorize", txH.BulkCategorize)

			// Categories
			r.Get("/categories", catH.List)
			r.Post("/categories", catH.Create)
			r.Get("/categories/summary", catH.GetSummary)
			r.Get("/categories/{id}", catH.Get)
			r.Put("/categories/{id}", catH.Update)
			r.Delete("/categories/{id}", catH.Delete)
			r.Get("/categories/{id}/transactions", catH.GetTransactions)

			// Budgets
			r.Get("/budgets", budH.List)
			r.Post("/budgets", budH.Create)
			r.Get("/budgets/summary", budH.GetSummary)
			r.Get("/budgets/{id}", budH.Get)
			r.Put("/budgets/{id}", budH.Update)
			r.Delete("/budgets/{id}", budH.Delete)
			r.Get("/budgets/{id}/usage", budH.GetUsage)

			// Tags
			r.Get("/tags", tagsH.List)
			r.Post("/tags", tagsH.Create)
			r.Put("/tags/{id}", tagsH.Update)
			r.Delete("/tags/{id}", tagsH.Delete)

			// Bills
			r.Get("/bills", billsH.List)
			r.Post("/bills", billsH.Create)
			r.Get("/bills/upcoming", billsH.GetUpcoming)
			r.Get("/bills/{id}", billsH.Get)
			r.Put("/bills/{id}", billsH.Update)
			r.Delete("/bills/{id}", billsH.Delete)

			// Rules
			r.Get("/rules", rulesH.List)
			r.Post("/rules", rulesH.Create)
			r.Get("/rules/{id}", rulesH.Get)
			r.Put("/rules/{id}", rulesH.Update)
			r.Delete("/rules/{id}", rulesH.Delete)
			r.Post("/rules/{id}/test", rulesH.Test)
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
