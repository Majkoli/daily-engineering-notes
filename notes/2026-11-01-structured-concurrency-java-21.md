# Structured Concurrency in Java 21: Scoped Task Lifecycles and Cancellation

**Date:** 2026-11-01  
**Category:** Java 21 & Concurrency

---

## Overview

Unstructured `ExecutorService.submit()` calls risk thread leaks when one subtask fails while sibling tasks keep running. `StructuredTaskScope.ShutdownOnFailure` binds subtask lifetimes to a lexical scope, automatically cancelling remaining branches on first exception and guaranteeing clean resource teardown.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
