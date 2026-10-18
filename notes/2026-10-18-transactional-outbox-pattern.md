# The Transactional Outbox Pattern for Reliable Event Publishing

**Date:** 2026-10-18  
**Category:** Distributed Systems

---

## Overview

Dual writes to a relational database and a message broker (Kafka/RabbitMQ) without distributed two-phase commit risk data inconsistency if the process crashes between the DB commit and broker publish. By inserting domain events into an `outbox_events` table within the same local ACID transaction and polling with `SELECT ... FOR UPDATE SKIP LOCKED`, you guarantee at-least-once delivery without 2PC overhead.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
