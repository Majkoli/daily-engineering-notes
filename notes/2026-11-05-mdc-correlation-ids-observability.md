# Distributed Request Tracing with SLF4J MDC and Correlation IDs

**Date:** 2026-11-05  
**Category:** Observability & Operations

---

## Overview

Propagating an `X-Correlation-Id` header at the servlet filter boundary into SLF4J's Mapped Diagnostic Context (`MDC.put("correlationId", id)`) tags every log line across controllers, services, and SQL statements—and clearing it in a `finally` block prevents thread-reuse leakage.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
