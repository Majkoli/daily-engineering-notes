# Idempotent Kafka Consumers: Handling Duplicate Delivery After Rebalances

**Date:** 2026-11-11  
**Category:** Distributed Systems

---

## Overview

When a consumer group rebalances before offsets are committed, incoming partitions replay the last batch of messages. Storing processed `event_id` keys in a deduplication table inside the same database transaction as the business state update turns at-least-once broker delivery into effectively-once processing.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
