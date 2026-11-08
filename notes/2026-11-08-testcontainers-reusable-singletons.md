# Fast Integration Testing with Singleton Testcontainers in Spring Boot

**Date:** 2026-11-08  
**Category:** Testing & Quality

---

## Overview

Spinning up a fresh PostgreSQL container per test class adds minutes to CI pipelines. Using a shared abstract base test with `@ServiceConnection` and a static container lifecycle runs the entire integration suite against one isolated container instance with Flyway migrations applied once.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
