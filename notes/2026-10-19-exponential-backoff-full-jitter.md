# Exponential Backoff with Full Jitter for Upstream API Resilience

**Date:** 2026-10-19  
**Category:** Resilience & Fault Tolerance

---

## Overview

Fixed-interval retries or pure exponential backoff (`base * 2^attempt`) cause synchronized retry storms (thundering herds) when a downstream dependency recovers from a brief outage. Applying full jitter (`random(0, min(maxDelay, base * 2^attempt))`) spreads retry load uniformly across time and dramatically improves tail latency recovery.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
