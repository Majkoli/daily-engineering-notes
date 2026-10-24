# Java 21 Virtual Threads: Avoiding Carrier Thread Pinning with ReentrantLock

**Date:** 2026-10-24  
**Category:** Java 21 & Concurrency

---

## Overview

When running Spring Boot 3.2+ with `spring.threads.virtual.enabled=true`, virtual threads unmount from carrier OS threads during blocking I/O. However, entering a `synchronized` block while performing blocking I/O pins the virtual thread to its carrier thread. Replace long-lived `synchronized` guards around I/O with `java.util.concurrent.locks.ReentrantLock` and monitor pinning in production using `-Djdk.tracePinnedThreads=short`.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
