package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"github.com/fireflyneo/neo-backend/internal/database"
	"github.com/fireflyneo/neo-backend/internal/router"
)

var (
	version   = "1.0.0"
	buildTime = "unknown"
	gitCommit = "unknown"
)

func main() {
	// -------------------------------------------------------------------------
	// Flags
	// -------------------------------------------------------------------------
	port := flag.Int("port", 9090, "HTTP server port")
	dbPath := flag.String("db-path", defaultDBPath(), "Path to SQLite database file")
	showVersion := flag.Bool("version", false, "Show version and exit")
	flag.Parse()

	if *showVersion {
		fmt.Printf("neo-backend v%s (commit=%s, built=%s)\n", version, gitCommit, buildTime)
		os.Exit(0)
	}

	// -------------------------------------------------------------------------
	// Logging
	// -------------------------------------------------------------------------
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	log.Printf("neo-backend v%s starting...", version)
	log.Printf("Database path: %s", *dbPath)
	log.Printf("Server port: %d", *port)

	// -------------------------------------------------------------------------
	// Ensure DB directory exists
	// -------------------------------------------------------------------------
	if err := os.MkdirAll(filepath.Dir(*dbPath), 0755); err != nil {
		log.Fatalf("Failed to create database directory: %v", err)
	}

	// -------------------------------------------------------------------------
	// Database
	// -------------------------------------------------------------------------
	db, err := database.OpenDB(*dbPath)
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}

	if err := database.RunMigrations(db); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}
	log.Println("Database migrations completed successfully")

	// -------------------------------------------------------------------------
	// Router
	// -------------------------------------------------------------------------
	r := router.New(db)

	// -------------------------------------------------------------------------
	// HTTP Server
	// -------------------------------------------------------------------------
	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", *port),
		Handler:      r,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 60 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// Start server in a goroutine
	serverErrors := make(chan error, 1)
	go func() {
		log.Printf("neo-backend listening on http://0.0.0.0:%d", *port)
		serverErrors <- srv.ListenAndServe()
	}()

	// -------------------------------------------------------------------------
	// Graceful shutdown
	// -------------------------------------------------------------------------
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	select {
	case err := <-serverErrors:
		if err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server error: %v", err)
		}
	case sig := <-quit:
		log.Printf("Received signal %s, shutting down gracefully...", sig)

		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		if err := srv.Shutdown(ctx); err != nil {
			log.Printf("Server shutdown error: %v", err)
		}

		// Close database connection
		sqlDB, err := db.DB()
		if err == nil {
			if err := sqlDB.Close(); err != nil {
				log.Printf("Database close error: %v", err)
			}
		}

		log.Println("Server shut down successfully")
	}
}

// defaultDBPath returns the default database path based on OS user home directory.
func defaultDBPath() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return "./neo.db"
	}
	return filepath.Join(home, ".fireflyneo", "neo.db")
}
