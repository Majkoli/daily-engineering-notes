# Preventing Lock-Ordering Deadlocks in Multi-Row PostgreSQL Updates

**Date:** 2026-11-07  
**Category:** Database & Concurrency

---

## Overview

When concurrent transactions lock multiple accounts or ledger rows in different orders, PostgreSQL detects a cycle and aborts one transaction with SQLSTATE `40P01`. Sorting entity IDs deterministically (e.g., ascending UUID order) before acquiring row locks eliminates circular wait conditions completely.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
