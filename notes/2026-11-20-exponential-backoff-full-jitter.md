# Exponential Backoff with Full Jitter for Upstream API Resilience

**Date:** 2026-11-20  
**Category:** Resilience & Fault Tolerance

---

## Overview

Fixed-interval retries or pure exponential backoff (`base * 2^attempt`) cause synchronized retry storms (thundering herds) when a downstream dependency recovers from a brief outage. Applying full jitter (`random(0, min(maxDelay, base * 2^attempt))`) spreads retry load uniformly across time and dramatically improves tail latency recovery.

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
