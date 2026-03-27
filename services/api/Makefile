include .env
export

build:
	go build -o dist/main main.go

run:
	./dist/main

migrate-up:
	goose -dir ../../db/migrations postgres "$(DB_URL)" up

migrate-down:
	goose -dir ../../db/migrations postgres "$(DB_URL)" down

migrate-status:
	goose -dir ../../db/migrations postgres "$(DB_URL)" status

generate-db:
	sqlc generate