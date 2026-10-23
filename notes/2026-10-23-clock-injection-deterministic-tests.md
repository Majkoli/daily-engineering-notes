# Injecting java.time.Clock for 100% Deterministic Time-Based Tests

**Date:** 2026-10-23  
**Category:** Testing & Quality

---

## Overview

Hardcoding `Instant.now()` makes expiration, retry backoff, and timestamp tolerance tests flaky or dependent on `Thread.sleep()`. Injecting a Spring `Clock` bean allows production to use `Clock.systemUTC()` while tests supply `Clock.fixed()` or a mutable test clock.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
