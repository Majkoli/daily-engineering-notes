# Idempotent Kafka Consumers: Handling Duplicate Delivery After Rebalances

**Date:** 2026-11-14  
**Category:** Distributed Systems

---

## Overview

When a consumer group rebalances before offsets are committed, incoming partitions replay the last batch of messages. Storing processed `event_id` keys in a deduplication table inside the same database transaction as the business state update turns at-least-once broker delivery into effectively-once processing.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.
