# SHA-256 Request Fingerprinting for Strict Idempotency Guarantees

**Date:** 2026-10-27  
**Category:** API Design

---

## Overview

Storing an `Idempotency-Key` alone is insufficient if a buggy client reuses the same key with different request parameters. Compute a canonical SHA-256 digest of the request payload and store it alongside the key. On replay, compare the stored hash against the incoming payload hash: return the cached response on match, or reject with `422 Unprocessable Entity` on mismatch.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
