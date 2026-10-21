# Generational ZGC in Java 21 for Sub-Millisecond Pause Times

**Date:** 2026-10-21  
**Category:** Java 21 & Performance

---

## Overview

Enabling Generational ZGC (`-XX:+UseZGC -XX:+ZGenerational`) separates young and old object collection cycles, dramatically reducing allocation stalls and keeping GC pauses under 1 millisecond even on multi-gigabyte heaps under heavy request allocation.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
