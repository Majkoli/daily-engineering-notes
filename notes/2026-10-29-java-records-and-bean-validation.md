# Immutable DTOs with Java Records and Jakarta Bean Validation

**Date:** 2026-10-29  
**Category:** Java 21 & API Design

---

## Overview

Java `record` types eliminate boilerplate for API request/response payloads while guaranteeing shallow immutability. Combine compact canonical constructors for normalization (such as trimming or upper-casing ISO codes) with Jakarta Validation annotations (`@NotBlank`, `@Positive`, `@Valid`) on record components for fail-fast boundary validation.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
