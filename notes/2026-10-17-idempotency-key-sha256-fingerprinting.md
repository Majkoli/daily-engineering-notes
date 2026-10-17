# Idempotency Keys with SHA-256 Payload Fingerprinting in Distributed APIs

**Date:** 2026-10-17  
**Category:** API Design & Distributed Systems  
**Tags:** `Idempotency`, `REST API`, `PostgreSQL`, `Java 21`, `Spring Boot`

---

## Context

Network timeouts, load balancer drops, and mobile client retries mean any mutating HTTP endpoint (`POST /payments`, `POST /orders`) will eventually receive duplicate requests. Accepting an `Idempotency-Key` header prevents duplicate side effects—but storing the key alone is not enough when clients accidentally reuse the same key with a different request body.

## 1. Atomic Claim + Payload Hash Verification

Store both the `idempotency_key` (with a `UNIQUE` constraint) and a canonical `request_hash` (`SHA-256` of the normalized request fields):

```java
String requestHash = sha256Hex(
    request.merchantReference() + "|" +
    request.amountMinorUnits() + "|" +
    request.currency()
);
```

When a request arrives with `Idempotency-Key: <key>`:
1. **First request:** Inserts `(idempotency_key, request_hash, status = 'IN_PROGRESS')`.
2. **Exact retry (same key + same hash):** Returns the cached response payload and original HTTP status code (`201 Created`).
3. **Parameter mismatch (same key + different hash):** Immediately rejects with `422 Unprocessable Entity` (`IdempotencyKeyConflictException`) so a client bug never silently returns a receipt for a different amount or recipient.

## 2. Handling Concurrent In-Flight Retries

If a client retries *while* the first request is still executing against an external gateway:
- The `UNIQUE (idempotency_key)` constraint blocks or rejects the duplicate insert.
- Using a short-lived lock or status check on the existing record prevents firing a second upstream gateway call while the first is still in flight.

## Key Takeaway

Always bind an `Idempotency-Key` to a deterministic **SHA-256 request fingerprint** and enforce uniqueness at the database constraint level, not just in application memory.
