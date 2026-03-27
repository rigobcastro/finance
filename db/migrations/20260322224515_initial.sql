-- +goose Up
-- UUID v7: use core uuidv7() (PostgreSQL 18+). pg_uuidv7 is not shipped in postgres:*-alpine images.

CREATE TABLE accounts (
    id         UUID PRIMARY KEY DEFAULT uuidv7(),
    name       TEXT NOT NULL,
    type       TEXT NOT NULL CHECK (type IN ('bank', 'cash', 'credit', 'investment')),
    currency   TEXT NOT NULL DEFAULT 'MXN',
    balance    NUMERIC(15,2) NOT NULL DEFAULT 0,
    is_active  BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE categories (
    id        UUID PRIMARY KEY DEFAULT uuidv7(),
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name      TEXT NOT NULL,
    type      TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    icon      TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE transactions (
    id                      UUID PRIMARY KEY DEFAULT uuidv7(),
    account_id              UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    category_id             UUID REFERENCES categories(id) ON DELETE SET NULL,
    type                    TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
    currency                TEXT NOT NULL DEFAULT 'MXN',
    amount                  NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    exchange_rate           NUMERIC(15,6) NOT NULL DEFAULT 1,
    description             TEXT,
    date                    DATE NOT NULL DEFAULT CURRENT_DATE,
    transfer_id             UUID,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE debts (
    id               UUID PRIMARY KEY DEFAULT uuidv7(),
    account_id       UUID REFERENCES accounts(id) ON DELETE SET NULL,
    name             TEXT NOT NULL,
    type             TEXT NOT NULL CHECK (type IN ('credit_card', 'loan', 'personal')),
    original_amount  NUMERIC(15,2) NOT NULL,
    current_balance  NUMERIC(15,2) NOT NULL,
    interest_rate    NUMERIC(6,4) NOT NULL DEFAULT 0,
    currency         TEXT NOT NULL DEFAULT 'MXN',
    minimum_payment  NUMERIC(15,2),
    due_date         DATE,
    is_active        BOOLEAN NOT NULL DEFAULT true,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE debt_payments (
    id         UUID PRIMARY KEY DEFAULT uuidv7(),
    debt_id    UUID NOT NULL REFERENCES debts(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    amount     NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    date       DATE NOT NULL DEFAULT CURRENT_DATE,
    note       TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE subscriptions (
    id                UUID PRIMARY KEY DEFAULT uuidv7(),
    account_id        UUID REFERENCES accounts(id) ON DELETE SET NULL,
    category_id       UUID REFERENCES categories(id) ON DELETE SET NULL,
    name              TEXT NOT NULL,
    amount            NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    currency          TEXT NOT NULL DEFAULT 'MXN',
    billing_cycle     TEXT NOT NULL CHECK (billing_cycle IN ('weekly', 'monthly', 'yearly')),
    next_billing_date DATE NOT NULL,
    is_active         BOOLEAN NOT NULL DEFAULT true,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE subscription_payments (
    id              UUID PRIMARY KEY DEFAULT uuidv7(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    transaction_id  UUID REFERENCES transactions(id) ON DELETE SET NULL,
    amount          NUMERIC(15,2) NOT NULL,
    date            DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE investments (
    id             UUID PRIMARY KEY DEFAULT uuidv7(),
    account_id     UUID REFERENCES accounts(id) ON DELETE SET NULL,
    name           TEXT NOT NULL,
    ticker         TEXT,
    type           TEXT NOT NULL CHECK (type IN ('stock', 'etf', 'crypto', 'bond', 'fund')),
    currency       TEXT NOT NULL DEFAULT 'MXN',
    quantity       NUMERIC(18,8) NOT NULL DEFAULT 0,
    avg_buy_price  NUMERIC(15,6) NOT NULL DEFAULT 0,
    current_price  NUMERIC(15,6) NOT NULL DEFAULT 0,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_transactions_account   ON transactions(account_id, date DESC);
CREATE INDEX idx_transactions_category  ON transactions(category_id);
CREATE INDEX idx_transactions_date      ON transactions(date DESC);
CREATE INDEX idx_debt_payments_debt     ON debt_payments(debt_id);
CREATE INDEX idx_sub_payments_sub       ON subscription_payments(subscription_id);
CREATE INDEX idx_subscriptions_billing  ON subscriptions(next_billing_date) WHERE is_active = true;
CREATE INDEX idx_debts_active           ON debts(is_active, due_date);

-- Default categories
INSERT INTO categories (name, type, icon) VALUES
  ('Salary',            'income',  '💼'),
  ('Freelance',         'income',  '💻'),
  ('Investments',       'income',  '📈'),
  ('Other Income',      'income',  '💰'),
  ('Food',              'expense', '🍽️'),
  ('Transport',         'expense', '🚗'),
  ('Utilities',         'expense', '💡'),
  ('Entertainment',     'expense', '🎬'),
  ('Health',            'expense', '🏥'),
  ('Education',         'expense', '📚'),
  ('Clothing',          'expense', '👕'),
  ('Home',              'expense', '🏠'),
  ('Subscriptions',     'expense', '🔄'),
  ('Debts',             'expense', '💳'),
  ('Other Expenses',    'expense', '📦');

-- +goose Down

DROP TABLE IF EXISTS investments;
DROP TABLE IF EXISTS subscription_payments;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS debt_payments;
DROP TABLE IF EXISTS debts;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS accounts;