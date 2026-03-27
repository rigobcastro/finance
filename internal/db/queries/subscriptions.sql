-- queries/subscriptions.sql

-- name: ListSubscriptions :many
SELECT * FROM subscriptions
WHERE is_active = true
ORDER BY next_billing_date, name;

-- name: GetSubscription :one
SELECT * FROM subscriptions
WHERE id = $1;

-- name: CreateSubscription :one
INSERT INTO subscriptions (
    account_id, category_id, name, amount, currency,
    billing_cycle, next_billing_date
)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: UpdateSubscription :one
UPDATE subscriptions
SET
    account_id = $2,
    category_id = $3,
    name = $4,
    amount = $5,
    currency = $6,
    billing_cycle = $7,
    next_billing_date = $8,
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeactivateSubscription :exec
UPDATE subscriptions
SET is_active = false, updated_at = NOW()
WHERE id = $1;
