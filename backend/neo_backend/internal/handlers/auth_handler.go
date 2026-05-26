package handlers

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/fireflyneo/neo-backend/internal/auth"
	"github.com/fireflyneo/neo-backend/internal/middleware"
	"github.com/fireflyneo/neo-backend/internal/models"
	"gorm.io/gorm"
)

// AuthHandler handles authentication endpoints.
type AuthHandler struct {
	db *gorm.DB
}

// NewAuthHandler creates a new AuthHandler.
func NewAuthHandler(db *gorm.DB) *AuthHandler {
	return &AuthHandler{db: db}
}

// registerRequest is the payload for POST /api/auth/register.
type registerRequest struct {
	Email       string `json:"email"`
	Password    string `json:"password"`
	DisplayName string `json:"display_name"`
	PIN         string `json:"pin,omitempty"`
}

// loginRequest is the payload for POST /api/auth/login.
type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// pinLoginRequest is the payload for POST /api/auth/pin-login.
type pinLoginRequest struct {
	Email string `json:"email"`
	PIN   string `json:"pin"`
}

// authResponse is the response for successful auth operations.
type authResponse struct {
	Token string      `json:"token"`
	User  models.User `json:"user"`
}

// changePasswordRequest is the payload for POST /api/auth/change-password.
type changePasswordRequest struct {
	CurrentPassword string `json:"current_password"`
	NewPassword     string `json:"new_password"`
}

// updateMeRequest is the payload for PUT /api/auth/me.
type updateMeRequest struct {
	DisplayName string `json:"display_name,omitempty"`
	PIN         string `json:"pin,omitempty"`
}

// Register handles POST /api/auth/register.
func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req registerRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	if req.Email == "" || req.Password == "" {
		writeError(w, http.StatusBadRequest, "Email and password are required")
		return
	}
	if len(req.Password) < 8 {
		writeError(w, http.StatusBadRequest, "Password must be at least 8 characters")
		return
	}

	// Check if user already exists
	var existing models.User
	if err := h.db.Where("email = ?", req.Email).First(&existing).Error; err == nil {
		writeError(w, http.StatusConflict, "User with this email already exists")
		return
	}

	// Hash password
	hash, err := auth.HashPassword(req.Password)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to process password")
		return
	}

	user := models.User{
		Email:        req.Email,
		PasswordHash: hash,
		DisplayName:  req.DisplayName,
	}

	// Hash PIN if provided
	if req.PIN != "" {
		if len(req.PIN) < 4 {
			writeError(w, http.StatusBadRequest, "PIN must be at least 4 digits")
			return
		}
		pinHash, err := auth.HashPIN(req.PIN)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Failed to process PIN")
			return
		}
		user.PINHash = pinHash
	}

	if err := h.db.Create(&user).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to create user")
		return
	}

	// Generate token
	token, err := auth.GenerateToken(user.ID, user.Email)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to generate token")
		return
	}

	writeJSON(w, http.StatusCreated, authResponse{Token: token, User: user})
}

// Login handles POST /api/auth/login.
func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	if req.Email == "" || req.Password == "" {
		writeError(w, http.StatusBadRequest, "Email and password are required")
		return
	}

	var user models.User
	if err := h.db.Where("email = ?", req.Email).First(&user).Error; err != nil {
		writeError(w, http.StatusUnauthorized, "Invalid email or password")
		return
	}

	if !auth.CheckPassword(user.PasswordHash, req.Password) {
		writeError(w, http.StatusUnauthorized, "Invalid email or password")
		return
	}

	token, err := auth.GenerateToken(user.ID, user.Email)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to generate token")
		return
	}

	writeJSON(w, http.StatusOK, authResponse{Token: token, User: user})
}

// PINLogin handles POST /api/auth/pin-login.
func (h *AuthHandler) PINLogin(w http.ResponseWriter, r *http.Request) {
	var req pinLoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	if req.Email == "" || req.PIN == "" {
		writeError(w, http.StatusBadRequest, "Email and PIN are required")
		return
	}

	var user models.User
	if err := h.db.Where("email = ?", req.Email).First(&user).Error; err != nil {
		writeError(w, http.StatusUnauthorized, "Invalid credentials")
		return
	}

	if user.PINHash == "" {
		writeError(w, http.StatusBadRequest, "PIN is not configured for this account")
		return
	}

	if !auth.CheckPIN(user.PINHash, req.PIN) {
		writeError(w, http.StatusUnauthorized, "Invalid PIN")
		return
	}

	token, err := auth.GeneratePINToken(user.ID, user.Email)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to generate token")
		return
	}

	writeJSON(w, http.StatusOK, authResponse{Token: token, User: user})
}

// Me handles GET /api/auth/me.
func (h *AuthHandler) Me(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var user models.User
	if err := h.db.First(&user, userID).Error; err != nil {
		writeError(w, http.StatusNotFound, "User not found")
		return
	}

	writeJSON(w, http.StatusOK, user)
}

// UpdateMe handles PUT /api/auth/me.
func (h *AuthHandler) UpdateMe(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req updateMeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	var user models.User
	if err := h.db.First(&user, userID).Error; err != nil {
		writeError(w, http.StatusNotFound, "User not found")
		return
	}

	updates := map[string]interface{}{}

	if req.DisplayName != "" {
		updates["display_name"] = req.DisplayName
	}

	if req.PIN != "" {
		if len(req.PIN) < 4 {
			writeError(w, http.StatusBadRequest, "PIN must be at least 4 digits")
			return
		}
		pinHash, err := auth.HashPIN(req.PIN)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Failed to process PIN")
			return
		}
		updates["pin_hash"] = pinHash
	}

	if len(updates) == 0 {
		writeJSON(w, http.StatusOK, user)
		return
	}

	if err := h.db.Model(&user).Updates(updates).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update user")
		return
	}

	writeJSON(w, http.StatusOK, user)
}

// ChangePassword handles POST /api/auth/change-password.
func (h *AuthHandler) ChangePassword(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var req changePasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.CurrentPassword == "" || req.NewPassword == "" {
		writeError(w, http.StatusBadRequest, "current_password and new_password are required")
		return
	}
	if len(req.NewPassword) < 8 {
		writeError(w, http.StatusBadRequest, "New password must be at least 8 characters")
		return
	}

	var user models.User
	if err := h.db.First(&user, userID).Error; err != nil {
		writeError(w, http.StatusNotFound, "User not found")
		return
	}

	if !auth.CheckPassword(user.PasswordHash, req.CurrentPassword) {
		writeError(w, http.StatusUnauthorized, "Current password is incorrect")
		return
	}

	newHash, err := auth.HashPassword(req.NewPassword)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to process password")
		return
	}

	if err := h.db.Model(&user).Update("password_hash", newHash).Error; err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update password")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "Password changed successfully"})
}
