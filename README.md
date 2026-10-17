# Daily Engineering Notes & Architecture Log

A curated daily log of backend engineering deep-dives, **Java 21**, **Spring Boot 3**, **PostgreSQL**, concurrency patterns, and distributed systems architecture notes by **Michael Bechaalani**.

---

## Recent Notes

| Date | Topic | Category |
| :--- | :--- | :--- |
| **2026-10-17** | [Idempotency Keys with SHA-256 Payload Fingerprinting in Distributed APIs](notes/2026-10-17-idempotency-key-sha256-fingerprinting.md) | API Design & Distributed Systems |
| **2026-10-16** | [PostgreSQL `SELECT ... FOR UPDATE` vs. Optimistic `@Version` Locking in High-Contention Workflows](notes/2026-10-16-postgresql-select-for-update-vs-optimistic-locking.md) | Database & Concurrency |

---

## Repository Structure

```text
daily-engineering-notes/
├── notes/                  # Daily engineering deep-dives (YYYY-MM-DD-topic.md)
├── scripts/                # Automation helpers for cloud fallback notes
└── .github/workflows/      # Cloud scheduled workflow (runs when workstation is offline)
```

## Topics Covered
- **Java 21 & JVM Internals**: Virtual threads, structured concurrency, records, sealed hierarchies, ZGC.
- **Spring Boot & Persistence**: Transaction boundaries, JPA locking strategies, outbox pattern, Flyway migrations.
- **Distributed Systems & Resiliency**: Idempotency keys, circuit breakers, exponential backoff with jitter, webhook verification.
