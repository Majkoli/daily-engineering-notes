# Constant-Time HMAC-SHA256 Signature Verification for Webhooks

**Date:** 2026-10-20  
**Category:** Security & APIs  
**Tags:** `Security`, `Webhooks`, `HMAC-SHA256`, `Java 21`, `Cryptography`

---

## Overview

Comparing webhook HMAC digests with standard string equality (`String.equals`) leaks timing information byte-by-byte because it returns `false` on the first mismatched character. Always verify signatures using `MessageDigest.isEqual(expectedBytes, actualBytes)` alongside a bounded timestamp tolerance window (e.g., 300 seconds) to prevent both timing side-channels and replay attacks.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.
