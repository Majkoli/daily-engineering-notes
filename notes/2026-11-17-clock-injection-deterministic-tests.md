# Injecting java.time.Clock for 100% Deterministic Time-Based Tests

**Date:** 2026-11-17  
**Category:** Testing & Quality

---

## Overview

Hardcoding `Instant.now()` makes expiration, retry backoff, and timestamp tolerance tests flaky or dependent on `Thread.sleep()`. Injecting a Spring `Clock` bean allows production to use `Clock.systemUTC()` while tests supply `Clock.fixed()` or a mutable test clock.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.
