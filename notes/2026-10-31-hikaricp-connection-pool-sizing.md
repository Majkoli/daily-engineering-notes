# HikariCP Connection Pool Sizing: Why Smaller Pools Outperform Larger Ones

**Date:** 2026-10-31  
**Category:** Database & Performance

---

## Overview

Database throughput rarely scales linearly with connection count beyond CPU core saturation. Using the PostgreSQL formula `connections = (core_count * 2) + effective_spindle_count`, a pool of 10-20 connections per instance minimizes context switching and lock contention while keeping p99 acquisition latency predictable.

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
