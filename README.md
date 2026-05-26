# FireflyIII Neo 🦋

> **A production-grade, offline-first, self-hosted personal finance tracker built with Flutter + embedded Go backend.**

[![CI](https://github.com/your-org/fireflyneo/actions/workflows/ci.yml/badge.svg)](https://github.com/your-org/fireflyneo/actions/workflows/ci.yml)
[![Release](https://github.com/your-org/fireflyneo/actions/workflows/release.yml/badge.svg)](https://github.com/your-org/fireflyneo/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter)](https://flutter.dev)
[![Go](https://img.shields.io/badge/Go-1.22+-00ADD8?logo=go)](https://golang.org)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

---

## ✨ Features

- 📱 **Offline-First** – Full local SQLite via Drift, syncs to Go backend
- 🤖 **SMS Auto-Parsing** – Native Android foreground service reads bank SMS, parses transactions automatically
- 📊 **Rich Analytics** – Cashflow, net worth history, category breakdowns, merchant insights, spending heatmaps
- 💰 **Budgets & Bills** – Track budgets by period, upcoming bills calendar
- 🏷️ **Tags & Categories** – Flexible tagging and hierarchical categories
- 🔒 **PIN + JWT Auth** – Local biometric/PIN + JWT-secured API
- 🌐 **Self-Hosted** – Embedded Go backend, no cloud dependency
- 🎨 **Dark-First Material 3** – Glassmorphism accents, system-adaptive theme
- 🔄 **Rule Engine** – Auto-categorize transactions with trigger/action rules
- 🐳 **Docker Ready** – Full dev stack via Docker Compose

---

## 📸 Screenshots

> _Screenshots placeholder – add actual screenshots to `docs/screenshots/`_

| Dashboard | Transactions | Analytics |
|-----------|-------------|-----------|
| _TBD_ | _TBD_ | _TBD_ |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  FireflyIII Neo App                      │
│                                                         │
│  ┌────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │  Flutter   │  │ Riverpod 2.x │  │   GoRouter 14   │  │
│  │ Material 3 │  │  State Mgmt  │  │   Navigation    │  │
│  └────────────┘  └──────────────┘  └─────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────────┐ │
│  │                  Package Layer                       │ │
│  │  shared │ ui │ core │ database │ analytics          │ │
│  │  sms_engine │ parser_engine │ sync_engine           │ │
│  │  firefly_adapter                                    │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                         │
│  ┌──────────────┐          ┌──────────────────────────┐  │
│  │  Drift/SQLite│◄────────►│   Sync Engine            │  │
│  │  (Offline)   │          │   (Conflict resolution)  │  │
│  └──────────────┘          └──────────┬───────────────┘  │
│                                       │                  │
│  ┌────────────────────────────────────▼────────────────┐ │
│  │              SMS Engine (Android Only)               │ │
│  │  KotlinForegroundService → parser_engine → ingest   │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────┬──────────────────────────┘
                               │ HTTP/REST :9090
                               ▼
┌─────────────────────────────────────────────────────────┐
│              Embedded Go Backend (neo_backend)           │
│                                                         │
│  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐  │
│  │  Chi    │  │  GORM    │  │  JWT     │  │  CORS   │  │
│  │ Router  │  │  ORM     │  │  Auth    │  │  Mdlwr  │  │
│  └─────────┘  └──────────┘  └──────────┘  └─────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────────┐ │
│  │                  SQLite (modernc/sqlite)              │ │
│  │              ~/.fireflyneo/neo.db                    │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Monorepo Structure

```
FireflyIIINeo/
├── apps/
│   └── mobile/                   # Main Flutter application
├── packages/
│   ├── shared/                   # Shared models, constants, utilities
│   ├── ui/                       # Design system (widgets, themes, tokens)
│   ├── database/                 # Drift schema & DAOs
│   ├── core/                     # Business logic, use cases
│   ├── sms_engine/               # Android SMS foreground service (Kotlin)
│   ├── parser_engine/            # SMS/text parsing logic (pure Dart)
│   ├── sync_engine/              # Sync orchestration & conflict resolution
│   ├── analytics/                # Data aggregation & computation
│   └── firefly_adapter/          # HTTP client for neo_backend
├── backend/
│   └── neo_backend/              # Embedded Go REST backend
│       ├── internal/
│       │   ├── auth/             # JWT + bcrypt auth
│       │   ├── database/         # GORM + SQLite setup
│       │   ├── handlers/         # HTTP handlers per domain
│       │   ├── middleware/       # Auth, logging, rate-limit middleware
│       │   ├── models/           # GORM models
│       │   └── router/           # Chi router setup
│       ├── main.go
│       └── go.mod
├── docker/
│   ├── docker-compose.dev.yml
│   └── Dockerfile.backend
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── release.yml
├── melos.yaml
├── pubspec.yaml
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter | ≥ 3.22.0 | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart | ≥ 3.4.0 | (bundled with Flutter) |
| Go | ≥ 1.22 | [go.dev](https://go.dev/doc/install) |
| Melos | ≥ 6.0.0 | `dart pub global activate melos` |
| Docker | ≥ 24 | [docker.com](https://docs.docker.com/get-docker/) |

### 1. Clone & Bootstrap

```bash
git clone https://github.com/your-org/fireflyneo.git
cd fireflyneo

# Install Melos globally
dart pub global activate melos

# Bootstrap all Flutter packages
melos bootstrap

# Generate all Dart code (Riverpod, Drift, Freezed)
melos gen
```

### 2. Start Go Backend (Dev)

```bash
# Option A: Docker (recommended)
cd docker
docker compose -f docker-compose.dev.yml up --build

# Option B: Local Go
cd backend/neo_backend
go mod tidy
go run main.go --port 9090 --db-path ~/.fireflyneo/neo.db
```

### 3. Run Flutter App

```bash
cd apps/mobile
flutter run
```

---

## 🔌 API Reference

Base URL: `http://localhost:9090`

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login with email + password |
| POST | `/api/auth/pin-login` | Login with PIN |
| GET | `/api/auth/me` | Get current user |
| PUT | `/api/auth/me` | Update profile |
| POST | `/api/auth/change-password` | Change password |

### Accounts
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/accounts` | List all accounts |
| POST | `/api/accounts` | Create account |
| GET | `/api/accounts/{id}` | Get account |
| PUT | `/api/accounts/{id}` | Update account |
| DELETE | `/api/accounts/{id}` | Delete account |
| GET | `/api/accounts/{id}/transactions` | Account transactions |
| GET | `/api/accounts/{id}/summary` | Account summary |

### Transactions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/transactions` | List (paginated, filterable) |
| POST | `/api/transactions` | Create transaction |
| GET | `/api/transactions/{id}` | Get transaction |
| PUT | `/api/transactions/{id}` | Update transaction |
| DELETE | `/api/transactions/{id}` | Delete transaction |
| GET | `/api/transactions/search?q=` | Full-text search |
| POST | `/api/transactions/bulk-delete` | Bulk delete |
| POST | `/api/transactions/bulk-categorize` | Bulk categorize |

### Analytics
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/analytics/dashboard` | Dashboard summary |
| GET | `/api/analytics/cashflow?months=12` | Monthly cashflow |
| GET | `/api/analytics/category-breakdown` | Category spending |
| GET | `/api/analytics/merchant-insights?limit=20` | Top merchants |
| GET | `/api/analytics/budget-progress` | Budget usage |
| GET | `/api/analytics/income-vs-expenses?months=6` | Income vs expenses |
| GET | `/api/analytics/spending-heatmap?year=` | Daily heatmap |
| GET | `/api/analytics/net-worth-history?months=12` | Net worth over time |

---

## 🧪 Testing

```bash
# Run all tests
melos test

# Run with coverage
melos test:coverage

# Backend tests
cd backend/neo_backend && go test ./... -v

# Single package
cd packages/parser_engine && flutter test
```

---

## 🐳 Docker

```bash
# Development (with hot reload via air)
docker compose -f docker/docker-compose.dev.yml up --build

# Check backend health
curl http://localhost:9090/health
```

---

## 📦 Package Overview

| Package | Description |
|---------|-------------|
| `shared` | Models (Freezed), constants, utilities, extensions |
| `ui` | Design system: tokens, themes, widgets, glassmorphism |
| `database` | Drift schema, tables, DAOs, migrations |
| `core` | Business logic, use cases, domain services |
| `sms_engine` | Android Kotlin plugin: ForegroundService, SMS permissions |
| `parser_engine` | Regex/ML SMS parser → structured transactions |
| `sync_engine` | Offline-sync orchestration, conflict resolution |
| `analytics` | Aggregation logic: cashflow, net worth, heatmaps |
| `firefly_adapter` | Typed Dio HTTP client for neo_backend API |

---

## 🤝 Contributing

1. Fork the repo
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit: `git commit -m 'feat: add amazing feature'`
4. Push: `git push origin feature/amazing-feature`
5. Open a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) and ensure all tests pass.

---

## 📄 License

This project is licensed under the **AGPL-3.0 License** – see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [Firefly III](https://www.firefly-iii.org/) – The original inspiration
- [Flutter](https://flutter.dev) – Cross-platform UI framework
- [Chi](https://github.com/go-chi/chi) – Lightweight Go HTTP router
- [GORM](https://gorm.io) – Go ORM
- [Drift](https://drift.simonbinder.eu) – Reactive SQLite for Flutter

---

_Built with ❤️ as a production-grade personal finance solution_
