-- queries/accounts.sql

-- name: ListAccounts :many
SELECT * FROM accounts
WHERE is_active = true
ORDER BY name;

-- name: GetAccount :one
SELECT * FROM accounts
WHERE id = $1;

-- name: CreateAccount :one
INSERT INTO accounts (name, type, currency, balance)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: UpdateAccountBalance :one
UPDATE accounts
SET balance = $2, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeactivateAccount :exec
UPDATE accounts
SET is_active = false, updated_at = NOW()
WHERE id = $1;