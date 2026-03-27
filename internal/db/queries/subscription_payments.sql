-- queries/subscription_payments.sql

-- name: ListSubscriptionPaymentsBySubscription :many
SELECT * FROM subscription_payments
WHERE subscription_id = $1
ORDER BY date DESC, created_at DESC;

-- name: GetSubscriptionPayment :one
SELECT * FROM subscription_payments
WHERE id = $1;

-- name: CreateSubscriptionPayment :one
INSERT INTO subscription_payments (subscription_id, transaction_id, amount, date)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: DeleteSubscriptionPayment :exec
DELETE FROM subscription_payments
WHERE id = $1;
