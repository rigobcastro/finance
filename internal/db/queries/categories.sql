-- queries/categories.sql

-- name: ListCategories :many
SELECT * FROM categories
ORDER BY name;

-- name: ListCategoriesByType :many
SELECT * FROM categories
WHERE type = $1
ORDER BY name;

-- name: GetCategory :one
SELECT * FROM categories
WHERE id = $1;

-- name: CreateCategory :one
INSERT INTO categories (name, type, parent_id, icon)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: UpdateCategory :one
UPDATE categories
SET name = $2, parent_id = $3, icon = $4
WHERE id = $1
RETURNING *;

-- name: DeleteCategory :exec
DELETE FROM categories
WHERE id = $1;
