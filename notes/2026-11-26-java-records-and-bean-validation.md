# Immutable DTOs with Java Records and Jakarta Bean Validation

**Date:** 2026-11-26  
**Category:** Java 21 & API Design

---

## Overview

Java `record` types eliminate boilerplate for API request/response payloads while guaranteeing shallow immutability. Combine compact canonical constructors for normalization (such as trimming or upper-casing ISO codes) with Jakarta Validation annotations (`@NotBlank`, `@Positive`, `@Valid`) on record components for fail-fast boundary validation.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.
