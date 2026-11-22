# Zero-Downtime PostgreSQL Schema Migrations with Flyway

**Date:** 2026-11-22  
**Category:** Database Engineering

---

## Overview

Adding a `NOT NULL` column with a volatile default or creating an index without `CONCURRENTLY` acquires an `ACCESS EXCLUSIVE` lock in PostgreSQL, blocking reads and writes. Use the expand-and-contract pattern: (1) add nullable column, (2) dual-write in application code and backfill in batches, (3) validate constraint with `NOT VALID` followed by `VALIDATE CONSTRAINT`.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
