# Token Bucket vs. Sliding Window Rate Limiting at the API Edge

**Date:** 2026-11-09  
**Category:** Security & APIs

---

## Overview

Fixed-window counters allow 2x burst traffic across window boundaries. A token bucket or Redis-backed sliding window enforces both sustained average rate and bounded burst capacity, protecting downstream databases from noisy-neighbor traffic spikes.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
