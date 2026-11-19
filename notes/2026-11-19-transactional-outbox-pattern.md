# The Transactional Outbox Pattern for Reliable Event Publishing

**Date:** 2026-11-19  
**Category:** Distributed Systems

---

## Overview

Dual writes to a relational database and a message broker (Kafka/RabbitMQ) without distributed two-phase commit risk data inconsistency if the process crashes between the DB commit and broker publish. By inserting domain events into an `outbox_events` table within the same local ACID transaction and polling with `SELECT ... FOR UPDATE SKIP LOCKED`, you guarantee at-least-once delivery without 2PC overhead.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.
