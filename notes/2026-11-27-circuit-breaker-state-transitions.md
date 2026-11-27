# Circuit Breaker State Machine: Closed, Open, and Half-Open Tuning

**Date:** 2026-11-27  
**Category:** Resilience & Fault Tolerance

---

## Overview

A circuit breaker prevents cascading thread-pool exhaustion when an upstream dependency degrades. Tune three key parameters together: minimum call volume threshold before evaluating failure rate, sliding window size, and permitted calls in `HALF_OPEN` state so a single probe request can verify recovery before restoring full traffic.

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
