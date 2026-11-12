# Token Bucket vs. Sliding Window Rate Limiting at the API Edge

**Date:** 2026-11-12  
**Category:** Security & APIs

---

## Overview

Fixed-window counters allow 2x burst traffic across window boundaries. A token bucket or Redis-backed sliding window enforces both sustained average rate and bounded burst capacity, protecting downstream databases from noisy-neighbor traffic spikes.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.
