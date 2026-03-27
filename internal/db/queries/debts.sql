-- queries/debts.sql

-- name: ListDebts :many
SELECT * FROM debts
WHERE is_active = true
ORDER BY name;

-- name: GetDebt :one
SELECT * FROM debts
WHERE id = $1;

-- name: CreateDebt :one
INSERT INTO debts (
    account_id, name, type, original_amount, current_balance,
    interest_rate, currency, minimum_payment, due_date
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
RETURNING *;

-- name: UpdateDebt :one
UPDATE debts
SET
    account_id = $2,
    name = $3,
    type = $4,
    original_amount = $5,
    current_balance = $6,
    interest_rate = $7,
    currency = $8,
    minimum_payment = $9,
    due_date = $10,
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeactivateDebt :exec
UPDATE debts
SET is_active = false, updated_at = NOW()
WHERE id = $1;
