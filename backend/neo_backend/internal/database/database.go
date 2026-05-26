package database

import (
	"fmt"
	"log"

	"github.com/fireflyneo/neo-backend/internal/models"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	// Use modernc/sqlite (pure Go, no CGO required)
	_ "modernc.org/sqlite"
)

// OpenDB opens a GORM database connection using modernc/sqlite (CGO-free).
// The DSN supports pragmas for WAL mode and foreign key enforcement.
func OpenDB(dbPath string) (*gorm.DB, error) {
	// Build DSN with pragmas
	dsn := fmt.Sprintf(
		"file:%s?cache=shared&_pragma=journal_mode(WAL)&_pragma=foreign_keys(ON)&_pragma=synchronous(NORMAL)&_pragma=busy_timeout(5000)",
		dbPath,
	)

	db, err := gorm.Open(sqlite.Dialector{
		DriverName: "sqlite", // use modernc driver registered as "sqlite"
		DSN:        dsn,
	}, &gorm.Config{
		Logger: logger.Default.LogMode(logger.Warn),
		NowFunc: func() interface{} {
			// Return consistent UTC time
			return nil
		},
	})
	if err != nil {
		return nil, fmt.Errorf("failed to open database at %s: %w", dbPath, err)
	}

	// Configure connection pool
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get sql.DB: %w", err)
	}
	sqlDB.SetMaxOpenConns(1)    // SQLite allows only one writer at a time
	sqlDB.SetMaxIdleConns(1)
	sqlDB.SetConnMaxLifetime(0) // Don't close idle connections

	log.Printf("Database opened successfully: %s", dbPath)
	return db, nil
}

// RunMigrations auto-migrates all models and creates any missing tables/columns.
func RunMigrations(db *gorm.DB) error {
	err := db.AutoMigrate(
		&models.User{},
		&models.Account{},
		&models.Transaction{},
		&models.Category{},
		&models.Budget{},
		&models.Tag{},
		&models.Bill{},
		&models.Rule{},
		&models.SMSMessage{},
		&models.SyncMeta{},
	)
	if err != nil {
		return fmt.Errorf("auto-migrate failed: %w", err)
	}
	return nil
}
