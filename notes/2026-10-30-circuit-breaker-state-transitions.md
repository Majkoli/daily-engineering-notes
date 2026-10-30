# Circuit Breaker State Machine: Closed, Open, and Half-Open Tuning

**Date:** 2026-10-30  
**Category:** Resilience & Fault Tolerance

---

## Overview

A circuit breaker prevents cascading thread-pool exhaustion when an upstream dependency degrades. Tune three key parameters together: minimum call volume threshold before evaluating failure rate, sliding window size, and permitted calls in `HALF_OPEN` state so a single probe request can verify recovery before restoring full traffic.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
