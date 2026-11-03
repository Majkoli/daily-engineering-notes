# PostgreSQL Partial Indexes for Hot-State Queries

**Date:** 2026-11-03  
**Category:** Database Engineering

---

## Overview

Indexing a low-cardinality `status` column where 99% of rows are `COMPLETED` wastes disk and slows writes. A partial index (`CREATE INDEX idx_pending ON payments (next_retry_at) WHERE status = 'RETRY_SCHEDULED'`) indexes only active in-flight rows, keeping the B-tree tiny and index scans sub-millisecond.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
