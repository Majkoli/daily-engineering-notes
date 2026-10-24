# Java 21 Virtual Threads: Avoiding Carrier Thread Pinning with ReentrantLock

**Date:** 2026-10-24  
**Category:** Java 21 & Concurrency

---

## Overview

When running Spring Boot 3.2+ with `spring.threads.virtual.enabled=true`, virtual threads unmount from carrier OS threads during blocking I/O. However, entering a `synchronized` block while performing blocking I/O pins the virtual thread to its carrier thread. Replace long-lived `synchronized` guards around I/O with `java.util.concurrent.locks.ReentrantLock` and monitor pinning in production using `-Djdk.tracePinnedThreads=short`.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.
