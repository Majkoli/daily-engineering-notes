# Distributed Request Tracing with SLF4J MDC and Correlation IDs

**Date:** 2026-11-05  
**Category:** Observability & Operations

---

## Overview

Propagating an `X-Correlation-Id` header at the servlet filter boundary into SLF4J's Mapped Diagnostic Context (`MDC.put("correlationId", id)`) tags every log line across controllers, services, and SQL statements—and clearing it in a `finally` block prevents thread-reuse leakage.

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
