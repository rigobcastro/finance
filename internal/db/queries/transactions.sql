-- queries/transactions.sql

-- name: ListTransactionsByAccount :many
SELECT * FROM transactions
WHERE account_id = $1
ORDER BY date DESC, created_at DESC;

-- name: GetTransaction :one
SELECT * FROM transactions
WHERE id = $1;

-- name: CreateTransaction :one
INSERT INTO transactions (
    account_id, category_id, type, currency, amount,
    exchange_rate, description, date, transfer_id
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
RETURNING *;

-- name: UpdateTransaction :one
UPDATE transactions
SET
    category_id = $2,
    type = $3,
    currency = $4,
    amount = $5,
    exchange_rate = $6,
    description = $7,
    date = $8,
    transfer_id = $9,
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteTransaction :exec
DELETE FROM transactions
WHERE id = $1;
