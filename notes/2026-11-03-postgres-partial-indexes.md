# PostgreSQL Partial Indexes for Hot-State Queries

**Date:** 2026-11-03  
**Category:** Database Engineering

---

## Overview

Indexing a low-cardinality `status` column where 99% of rows are `COMPLETED` wastes disk and slows writes. A partial index (`CREATE INDEX idx_pending ON payments (next_retry_at) WHERE status = 'RETRY_SCHEDULED'`) indexes only active in-flight rows, keeping the B-tree tiny and index scans sub-millisecond.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.

---

## Trade-Offs & Verification Strategy

| Dimension | Naive Approach | Production-Grade Approach |
| :--- | :--- | :--- |
| **Concurrency** | Unsynchronized read-modify-write | Explicit row locking / optimistic version checks |
| **Failure Mode** | Silent partial failure on timeout | Deterministic retry + idempotency key protection |
| **Testing** | Happy-path unit mocks only | Multi-threaded integration tests against real schema |
