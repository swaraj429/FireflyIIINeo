package models

import (
	"time"

	"gorm.io/gorm"
)

// User represents an authenticated local user account.
type User struct {
	ID           uint      `gorm:"primarykey" json:"id"`
	Email        string    `gorm:"uniqueIndex;not null" json:"email"`
	PasswordHash string    `gorm:"->;type:text;not null" json:"-"`
	PINHash      string    `json:"-"`
	DisplayName  string    `json:"display_name"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// Account represents a financial account (bank, wallet, credit card, etc.).
type Account struct {
	ID             string         `gorm:"primarykey;type:varchar(36)" json:"id"`
	UserID         uint           `gorm:"not null;index" json:"user_id"`
	Name           string         `gorm:"not null" json:"name"`
	Type           string         `gorm:"not null" json:"type"` // asset, expense, revenue, liability
	CurrencyCode   string         `gorm:"default:'INR'" json:"currency_code"`
	CurrentBalance float64        `json:"current_balance"`
	IBAN           string         `json:"iban,omitempty"`
	AccountNumber  string         `json:"account_number,omitempty"`
	BankName       string         `json:"bank_name,omitempty"`
	Notes          string         `json:"notes,omitempty"`
	Active         bool           `gorm:"default:true" json:"active"`
	Order          int            `gorm:"default:0" json:"order"`
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"-"`
}

// Transaction represents a financial transaction.
type Transaction struct {
	ID              string         `gorm:"primarykey;type:varchar(36)" json:"id"`
	UserID          uint           `gorm:"not null;index" json:"user_id"`
	Type            string         `gorm:"not null" json:"type"` // withdrawal, deposit, transfer
	Description     string         `json:"description"`
	Date            time.Time      `gorm:"index" json:"date"`
	Amount          float64        `gorm:"not null" json:"amount"`
	CurrencyCode    string         `gorm:"default:'INR'" json:"currency_code"`
	ForeignAmount   *float64       `json:"foreign_amount,omitempty"`
	ForeignCurrency *string        `json:"foreign_currency,omitempty"`
	SourceAccountID string         `gorm:"not null;index" json:"source_account_id"`
	DestAccountID   *string        `gorm:"index" json:"dest_account_id,omitempty"`
	CategoryID      *string        `gorm:"index" json:"category_id,omitempty"`
	BudgetID        *string        `gorm:"index" json:"budget_id,omitempty"`
	MerchantName    string         `json:"merchant_name,omitempty"`
	Notes           string         `json:"notes,omitempty"`
	Tags            string         `gorm:"type:text;default:'[]'" json:"tags"` // JSON array of tag IDs
	Reconciled      bool           `gorm:"default:false" json:"reconciled"`
	InternalRef     string         `gorm:"uniqueIndex:idx_internal_ref_user" json:"internal_ref,omitempty"`
	SMSSource       bool           `gorm:"default:false" json:"sms_source"`
	SMSSender       string         `json:"sms_sender,omitempty"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
}

// Category represents a spending/income category.
type Category struct {
	ID        string         `gorm:"primarykey;type:varchar(36)" json:"id"`
	UserID    uint           `gorm:"not null;index" json:"user_id"`
	Name      string         `gorm:"not null" json:"name"`
	Color     string         `gorm:"default:'#6366F1'" json:"color"`
	Icon      string         `gorm:"default:'category'" json:"icon"`
	ParentID  *string        `gorm:"index" json:"parent_id,omitempty"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// Budget represents a spending budget for a category/period.
type Budget struct {
	ID         string         `gorm:"primarykey;type:varchar(36)" json:"id"`
	UserID     uint           `gorm:"not null;index" json:"user_id"`
	Name       string         `gorm:"not null" json:"name"`
	Amount     float64        `gorm:"not null" json:"amount"`
	Period     string         `gorm:"not null" json:"period"` // monthly, weekly, yearly, quarterly
	StartDate  time.Time      `json:"start_date"`
	EndDate    *time.Time     `json:"end_date,omitempty"`
	CategoryID *string        `gorm:"index" json:"category_id,omitempty"`
	Active     bool           `gorm:"default:true" json:"active"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

// Tag represents a label that can be applied to transactions.
type Tag struct {
	ID        string    `gorm:"primarykey;type:varchar(36)" json:"id"`
	UserID    uint      `gorm:"not null;index" json:"user_id"`
	Name      string    `gorm:"not null" json:"name"`
	Color     string    `gorm:"default:'#8B5CF6'" json:"color"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Bill represents a recurring bill/subscription.
type Bill struct {
	ID           string         `gorm:"primarykey;type:varchar(36)" json:"id"`
	UserID       uint           `gorm:"not null;index" json:"user_id"`
	Name         string         `gorm:"not null" json:"name"`
	Amount       float64        `gorm:"not null" json:"amount"`
	CurrencyCode string         `gorm:"default:'INR'" json:"currency_code"`
	Period       string         `gorm:"not null" json:"period"` // weekly, monthly, quarterly, yearly
	NextDueDate  time.Time      `gorm:"index" json:"next_due_date"`
	AccountID    string         `gorm:"not null" json:"account_id"`
	CategoryID   *string        `json:"category_id,omitempty"`
	Notes        string         `json:"notes,omitempty"`
	Active       bool           `gorm:"default:true" json:"active"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

// Rule represents an auto-categorization rule.
type Rule struct {
	ID          string    `gorm:"primarykey;type:varchar(36)" json:"id"`
	UserID      uint      `gorm:"not null;index" json:"user_id"`
	Name        string    `gorm:"not null" json:"name"`
	Description string    `json:"description,omitempty"`
	Active      bool      `gorm:"default:true" json:"active"`
	StopOnMatch bool      `gorm:"default:false" json:"stop_on_match"`
	Order       int       `gorm:"default:0" json:"order"`
	Triggers    string    `gorm:"type:text;default:'[]'" json:"triggers"` // JSON array of RuleTrigger
	Actions     string    `gorm:"type:text;default:'[]'" json:"actions"`  // JSON array of RuleAction
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// RuleTrigger defines a condition for a rule.
type RuleTrigger struct {
	Type     string `json:"type"`  // description_contains, amount_gt, amount_lt, sender_is, merchant_is
	Value    string `json:"value"` // the value to match against
	Operator string `json:"operator,omitempty"` // eq, contains, regex, gt, lt, gte, lte
}

// RuleAction defines an action to take when a rule matches.
type RuleAction struct {
	Type  string `json:"type"`  // set_category, set_budget, set_tag, set_description, set_merchant, set_reconciled
	Value string `json:"value"` // the value to set
}

// SMSMessage represents a raw SMS received from the Android service.
type SMSMessage struct {
	ID             string     `gorm:"primarykey;type:varchar(36)" json:"id"`
	UserID         uint       `gorm:"not null;index" json:"user_id"`
	Sender         string     `gorm:"not null" json:"sender"`
	Body           string     `gorm:"type:text;not null" json:"body"`
	ReceivedAt     time.Time  `gorm:"index" json:"received_at"`
	Parsed         bool       `gorm:"default:false" json:"parsed"`
	TransactionID  *string    `json:"transaction_id,omitempty"`
	ParsedAmount   *float64   `json:"parsed_amount,omitempty"`
	ParsedMerchant string     `json:"parsed_merchant,omitempty"`
	ParsedType     string     `json:"parsed_type,omitempty"` // withdrawal, deposit
	DuplicateOf    *string    `json:"duplicate_of,omitempty"`
	CreatedAt      time.Time  `json:"created_at"`
}

// SyncMeta tracks sync state for each entity type.
type SyncMeta struct {
	ID           uint      `gorm:"primarykey"`
	UserID       uint      `gorm:"not null;index"`
	EntityType   string    `gorm:"not null"` // accounts, transactions, categories, etc.
	LastSyncedAt time.Time `json:"last_synced_at"`
	Cursor       string    `json:"cursor,omitempty"` // for cursor-based pagination sync
	UpdatedAt    time.Time `json:"updated_at"`
}
