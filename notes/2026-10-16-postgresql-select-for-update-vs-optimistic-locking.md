# PostgreSQL `SELECT ... FOR UPDATE` vs. Optimistic `@Version` Locking in High-Contention Workflows

**Date:** 2026-10-16  
**Category:** Database & Concurrency  
**Tags:** `PostgreSQL`, `Spring Data JPA`, `Concurrency`, `Locking`

---

## Context

When multiple concurrent workers (such as duplicate webhook deliveries, parallel API retries, or scheduled background reconcilers) attempt to transition the state of the same row simultaneously, standard `READ COMMITTED` isolation in PostgreSQL is not enough to prevent lost updates or invalid state transitions unless explicit locking is used.

## 1. Optimistic Locking (`@Version`)

Optimistic locking assumes conflicts are rare:
```sql
UPDATE orders
SET status = 'CAPTURED', version = version + 1
WHERE id = $1 AND version = $2;
```
- **Pros:** Zero lock wait time during reads; high throughput when contention is low.
- **Cons:** Under bursty contention (e.g., a webhook arriving at the exact millisecond an API call finishes), one transaction throws `ObjectOptimisticLockingFailureException` and aborts. If the failed caller already executed an external side effect, recovery requires careful compensation.

## 2. Pessimistic Write Locking (`SELECT ... FOR UPDATE`)

Pessimistic locking serializes conflicting writers at the database row level:
```java
@Lock(LockModeType.PessimisticWrite)
@Query("SELECT o FROM Order o WHERE o.id = :id")
Optional<Order> findByIdWithLock(@Param("id") UUID id);
```
- **Pros:** The second concurrent transaction blocks until the first commits, then reads the freshly committed state and cleanly short-circuits (e.g., seeing the row is already in a terminal state).
- **Cons:** Holds a row lock for the duration of the transaction. Never hold a `FOR UPDATE` lock across external HTTP calls—split the transaction into short local state transitions around the remote call.

## Key Takeaway

Combine both strategies:
1. Keep external network I/O **outside** the database transaction.
2. Acquire a short-lived `PessimisticWrite` (`SELECT ... FOR UPDATE`) lock when reading and validating the state machine transition.
3. Retain `@Version` as a defense-in-depth safety net for any un-locked code paths.
