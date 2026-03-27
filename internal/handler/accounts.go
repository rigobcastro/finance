package handler

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/rigobcastro/finance/internal/db"
	"github.com/rigobcastro/finance/internal/service"
)

type AccountHandler struct {
	s *service.AccountService
}

func NewAccountHandler(s *service.AccountService) *AccountHandler {
	return &AccountHandler{s: s}
}

func (h *AccountHandler) List(w http.ResponseWriter, r *http.Request) {
	accounts, err := h.s.ListAccounts(r.Context())
	if err != nil {
		respondError(w, http.StatusInternalServerError, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, accounts)
}

func (h *AccountHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id, err := parseUUIDParam(chi.URLParam(r, "id"))
	if err != nil {
		respondError(w, http.StatusBadRequest, "invalid id")
		return
	}
	account, err := h.s.GetAccount(r.Context(), id)
	if err != nil {
		if errors.Is(err, service.ErrAccountNotFound) {
			respondError(w, http.StatusNotFound, "account not found")
			return
		}
		respondError(w, http.StatusInternalServerError, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, account)
}

func (h *AccountHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req db.CreateAccountParams
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid body")
		return
	}
	account, err := h.s.CreateAccount(r.Context(), req)
	if err != nil {
		if errors.Is(err, service.ErrInvalidAccount) {
			respondError(w, http.StatusBadRequest, "invalid account")
			return
		}
		respondError(w, http.StatusInternalServerError, err.Error())
		return
	}
	respondJSON(w, http.StatusCreated, account)
}
