# Spring @Transactional Self-Invocation and Propagation Pitfalls

**Date:** 2026-10-26  
**Category:** Spring Boot Internals

---

## Overview

Spring's `@Transactional` relies on AOP proxies. Calling a `@Transactional(propagation = Propagation.REQUIRES_NEW)` method from another method within the same class bypasses the proxy completely and runs in the existing transaction context. Extract independent transaction boundaries into a dedicated collaborator bean or use `TransactionTemplate` for explicit programmatic control.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
