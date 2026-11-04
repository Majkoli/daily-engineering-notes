# Zero-Dropped-Request Graceful Shutdown in Spring Boot and Kubernetes

**Date:** 2026-11-04  
**Category:** Cloud Native & Operations

---

## Overview

Enabling `server.shutdown=graceful` with `spring.lifecycle.timeout-per-shutdown-phase=30s` stops accepting new requests on `SIGTERM` while allowing in-flight HTTP requests and active database transactions to complete cleanly before the container exits.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
