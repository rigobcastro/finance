-- queries/debt_payments.sql

-- name: ListDebtPaymentsByDebt :many
SELECT * FROM debt_payments
WHERE debt_id = $1
ORDER BY date DESC, created_at DESC;

-- name: GetDebtPayment :one
SELECT * FROM debt_payments
WHERE id = $1;

-- name: CreateDebtPayment :one
INSERT INTO debt_payments (debt_id, account_id, amount, date, note)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- name: DeleteDebtPayment :exec
DELETE FROM debt_payments
WHERE id = $1;
