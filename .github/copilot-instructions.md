# ParseIt Project Instructions

## Project Overview
This represents a distributed system with a Go backend API and a Rust background worker, communicating via Redis PubSub.
- **Backend**: Go (Gin, GORM) - Handles REST API and Job management.
- **Worker**: Rust (Tokio, SQLx) - Handles NLP processing and heavy lifting.
- **Database**: PostgreSQL (Shared).
- **Queue**: Redis PubSub (Channel: `job_created`).

## Architecture & Data Flow
1. **Job Creation**:
   - Client POSTs to `/api/v1/jobs`.
   - Backend saves `Job` to Postgres.
   - Backend publishes JSON event `{id, description}` to Redis channel `job_created`.
2. **Job Processing**:
   - Worker subscribes to `job_created`.
   - Worker deserializes event.
   - Worker performs NLP keyword extraction (`worker/src/nlp.rs`).
   - Worker updates database (likely creating "Cards").

## Tech Stack & Conventions

### Backend (Go)
- **Structure**: Follows standard Go layout.
  - `cmd/api/main.go`: Entry point.
  - `internal/handlers`: HTTP handlers (Gin). Inject DB/Redis dependencies via struct.
  - `internal/models`: GORM structs.
  - `internal/queue`: Redis setup.
  - `internal/services`: Business logic (e.g., PDF generation with Maroto).
- **Dependency Injection**: Use struct-based injection for Handlers.
  ```go
  type JobHandler struct {
      DB    *gorm.DB
      Redis *redis.Client
  }
  ```
### Error Handling**: Return clean JSON errors with appropriate HTTP status.

## API Endpoints
- `POST /api/v1/jobs`: Create a new job.
- `GET /api/v1/jobs`: List all jobs.
- `GET /api/v1/jobs/:id/cards`: Get cards for a specific job.
- `DELETE /api/v1/jobs/:id`: Delete a job.
- `PATCH /api/v1/jobs/:id`: Update a job's title, description, or link.
- `PATCH /api/v1/jobs/:id/status`: Update a job's status.


### Worker (Rust)
- **Async Runtime**: Tokio.
- **Database**: SQLx for async Postgres interactions.
- **NLP**: Custom regex-based keyword extraction in `src/nlp.rs`.

## Critical Workflows

### Running the Project
- **Backend**:
  ```bash
  cd backend
  go run cmd/api/main.go
  ```
- **Worker**:
  ```bash
  cd worker
  cargo run
  ```

### Development Rules
- **Environment**: Ensure `.env` exists in the project root.
- **Shared DB**: Both services access the same Postgres instance. Ensure schema consistency.
- **Redis Protocol**: When changing the event payload, update both `backend/internal/handlers/job_handler.go` (Publisher) and `worker/src/models.rs` (Consumer/struct).

## Directory Map
- `backend/internal/handlers`: Core API logic.
- `backend/internal/services`: Business logic (PDF Generation).
- `worker/src/nlp.rs`: Keyword extraction logic.
- `mobile`: (Currently empty/placeholder).
