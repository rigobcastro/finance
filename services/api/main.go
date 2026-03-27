package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"

	"github.com/rigobcastro/finance/internal/db"
	"github.com/rigobcastro/finance/internal/handler"
	"github.com/rigobcastro/finance/internal/service"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "3005"
	}

	pool, err := pgxpool.New(context.Background(), os.Getenv("DB_URL"))
	if err != nil {
		log.Fatalf("Failed to create database pool: %v", err)
	}
	defer pool.Close()

	queries := db.New(pool)
	accountSvc := service.NewAccountService(queries)

	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{"status":"ok"}`))
	})

	accountHandler := handler.NewAccountHandler(accountSvc)
	r.Route("/accounts", func(r chi.Router) {
		r.Get("/", accountHandler.List)
		r.Get("/{id}", accountHandler.GetByID)
		r.Post("/", accountHandler.Create)
	})

	log.Printf("🚀 http://localhost:%s", port)
	http.ListenAndServe(fmt.Sprintf(":%s", port), r)
}
