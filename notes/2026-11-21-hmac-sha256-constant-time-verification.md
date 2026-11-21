# Constant-Time HMAC-SHA256 Signature Verification for Webhooks

**Date:** 2026-11-21  
**Category:** Security & APIs

---

## Overview

Comparing webhook HMAC digests with standard string equality (`String.equals`) leaks timing information byte-by-byte because it returns `false` on the first mismatched character. Always verify signatures using `MessageDigest.isEqual(expectedBytes, actualBytes)` alongside a bounded timestamp tolerance window (e.g., 300 seconds) to prevent both timing side-channels and replay attacks.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
