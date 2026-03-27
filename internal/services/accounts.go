package service

import (
	"context"
	"errors"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/rigobcastro/finance/internal/db"
)

var (
	ErrAccountNotFound = errors.New("account not found")
	ErrInvalidAccount  = errors.New("invalid account")
)

type AccountService struct {
	q *db.Queries
}

func NewAccountService(q *db.Queries) *AccountService {
	return &AccountService{q: q}
}

func (s *AccountService) ListAccounts(ctx context.Context) ([]db.Account, error) {
	return s.q.ListAccounts(ctx)
}

func (s *AccountService) GetAccount(ctx context.Context, id pgtype.UUID) (db.Account, error) {
	acc, err := s.q.GetAccount(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return db.Account{}, ErrAccountNotFound
		}
		return db.Account{}, err
	}
	return acc, nil
}

func (s *AccountService) CreateAccount(ctx context.Context, params db.CreateAccountParams) (db.Account, error) {
	if strings.TrimSpace(params.Name) == "" {
		return db.Account{}, ErrInvalidAccount
	}
	return s.q.CreateAccount(ctx, params)
}
