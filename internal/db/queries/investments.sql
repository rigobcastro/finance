-- queries/investments.sql

-- name: ListInvestments :many
SELECT * FROM investments
ORDER BY name;

-- name: ListInvestmentsByAccount :many
SELECT * FROM investments
WHERE account_id = $1
ORDER BY name;

-- name: GetInvestment :one
SELECT * FROM investments
WHERE id = $1;

-- name: CreateInvestment :one
INSERT INTO investments (
    account_id, name, ticker, type, currency,
    quantity, avg_buy_price, current_price
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING *;

-- name: UpdateInvestment :one
UPDATE investments
SET
    account_id = $2,
    name = $3,
    ticker = $4,
    type = $5,
    currency = $6,
    quantity = $7,
    avg_buy_price = $8,
    current_price = $9,
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteInvestment :exec
DELETE FROM investments
WHERE id = $1;
