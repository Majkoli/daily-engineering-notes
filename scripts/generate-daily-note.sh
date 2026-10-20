#!/usr/bin/env bash
set -euo pipefail

TODAY=$(date -u +"%Y-%m-%d")
MODE="${1:-auto}" # "step" (1 commit per invocation) or "catchup" (reach full daily target)

# Compute weighted random target commits for TODAY (1, 2, or 3):
#   65% -> 1 commit
#   25% -> 2 commits
#   10% -> 3 commits
HASH_HEX=$(printf "%s-majkoli-notes" "$TODAY" | sha256sum | cut -c1-8)
ROLL=$(( 16#${HASH_HEX} % 100 ))

if [ "$ROLL" -lt 65 ]; then
  TARGET_COMMITS=1
elif [ "$ROLL" -lt 90 ]; then
  TARGET_COMMITS=2
else
  TARGET_COMMITS=3
fi

COMMITS_TODAY=$(git log --since="${TODAY}T00:00:00Z" --oneline | wc -l | tr -d ' ')

echo "Date: ${TODAY} | Roll: ${ROLL}/99 | Target commits today: ${TARGET_COMMITS} | Commits so far: ${COMMITS_TODAY}"

if [ "$COMMITS_TODAY" -ge "$TARGET_COMMITS" ]; then
  echo "Daily target (${TARGET_COMMITS}) already reached for ${TODAY}. Nothing to do."
  exit 0
fi

# Curated bank of backend engineering topics
TOPICS=(
  "java-21-virtual-threads-pinning|Java 21 Virtual Threads: Avoiding Carrier Thread Pinning with ReentrantLock|Java 21 & Concurrency|When running Spring Boot 3.2+ with \`spring.threads.virtual.enabled=true\`, virtual threads unmount from carrier OS threads during blocking I/O. However, entering a \`synchronized\` block while performing blocking I/O pins the virtual thread to its carrier thread. Replace long-lived \`synchronized\` guards around I/O with \`java.util.concurrent.locks.ReentrantLock\` and monitor pinning in production using \`-Djdk.tracePinnedThreads=short\`."
  "transactional-outbox-pattern|The Transactional Outbox Pattern for Reliable Event Publishing|Distributed Systems|Dual writes to a relational database and a message broker (Kafka/RabbitMQ) without distributed two-phase commit risk data inconsistency if the process crashes between the DB commit and broker publish. By inserting domain events into an \`outbox_events\` table within the same local ACID transaction and polling with \`SELECT ... FOR UPDATE SKIP LOCKED\`, you guarantee at-least-once delivery without 2PC overhead."
  "exponential-backoff-full-jitter|Exponential Backoff with Full Jitter for Upstream API Resilience|Resilience & Fault Tolerance|Fixed-interval retries or pure exponential backoff (\`base * 2^attempt\`) cause synchronized retry storms (thundering herds) when a downstream dependency recovers from a brief outage. Applying full jitter (\`random(0, min(maxDelay, base * 2^attempt))\`) spreads retry load uniformly across time and dramatically improves tail latency recovery."
  "hmac-sha256-constant-time-verification|Constant-Time HMAC-SHA256 Signature Verification for Webhooks|Security & APIs|Comparing webhook HMAC digests with standard string equality (\`String.equals\`) leaks timing information byte-by-byte because it returns \`false\` on the first mismatched character. Always verify signatures using \`MessageDigest.isEqual(expectedBytes, actualBytes)\` alongside a bounded timestamp tolerance window (e.g., 300 seconds) to prevent both timing side-channels and replay attacks."
  "flyway-zero-downtime-migrations|Zero-Downtime PostgreSQL Schema Migrations with Flyway|Database Engineering|Adding a \`NOT NULL\` column with a volatile default or creating an index without \`CONCURRENTLY\` acquires an \`ACCESS EXCLUSIVE\` lock in PostgreSQL, blocking reads and writes. Use the expand-and-contract pattern: (1) add nullable column, (2) dual-write in application code and backfill in batches, (3) validate constraint with \`NOT VALID\` followed by \`VALIDATE CONSTRAINT\`."
  "spring-transaction-propagation-pitfalls|Spring @Transactional Self-Invocation and Propagation Pitfalls|Spring Boot Internals|Spring's \`@Transactional\` relies on AOP proxies. Calling a \`@Transactional(propagation = Propagation.REQUIRES_NEW)\` method from another method within the same class bypasses the proxy completely and runs in the existing transaction context. Extract independent transaction boundaries into a dedicated collaborator bean or use \`TransactionTemplate\` for explicit programmatic control."
  "idempotency-key-fingerprinting|SHA-256 Request Fingerprinting for Strict Idempotency Guarantees|API Design|Storing an \`Idempotency-Key\` alone is insufficient if a buggy client reuses the same key with different request parameters. Compute a canonical SHA-256 digest of the request payload and store it alongside the key. On replay, compare the stored hash against the incoming payload hash: return the cached response on match, or reject with \`422 Unprocessable Entity\` on mismatch."
  "postgresql-skip-locked-work-queues|High-Throughput Job Queues in PostgreSQL Using FOR UPDATE SKIP LOCKED|Database & Concurrency|When multiple application replicas poll a database table for pending background jobs, standard locking causes workers to block behind one another. Using \`SELECT * FROM jobs WHERE status = 'PENDING' ORDER BY next_run_at LIMIT 50 FOR UPDATE SKIP LOCKED\` allows concurrent workers to claim disjoint batches with zero lock contention."
  "java-records-and-bean-validation|Immutable DTOs with Java Records and Jakarta Bean Validation|Java 21 & API Design|Java \`record\` types eliminate boilerplate for API request/response payloads while guaranteeing shallow immutability. Combine compact canonical constructors for normalization (such as trimming or upper-casing ISO codes) with Jakarta Validation annotations (\`@NotBlank\`, \`@Positive\`, \`@Valid\`) on record components for fail-fast boundary validation."
  "circuit-breaker-state-transitions|Circuit Breaker State Machine: Closed, Open, and Half-Open Tuning|Resilience & Fault Tolerance|A circuit breaker prevents cascading thread-pool exhaustion when an upstream dependency degrades. Tune three key parameters together: minimum call volume threshold before evaluating failure rate, sliding window size, and permitted calls in \`HALF_OPEN\` state so a single probe request can verify recovery before restoring full traffic."
  "hikaricp-connection-pool-sizing|HikariCP Connection Pool Sizing: Why Smaller Pools Outperform Larger Ones|Database & Performance|Database throughput rarely scales linearly with connection count beyond CPU core saturation. Using the PostgreSQL formula \`connections = (core_count * 2) + effective_spindle_count\`, a pool of 10-20 connections per instance minimizes context switching and lock contention while keeping p99 acquisition latency predictable."
  "structured-concurrency-java-21|Structured Concurrency in Java 21: Scoped Task Lifecycles and Cancellation|Java 21 & Concurrency|Unstructured \`ExecutorService.submit()\` calls risk thread leaks when one subtask fails while sibling tasks keep running. \`StructuredTaskScope.ShutdownOnFailure\` binds subtask lifetimes to a lexical scope, automatically cancelling remaining branches on first exception and guaranteeing clean resource teardown."
  "sealed-interfaces-domain-modeling|Exhaustive Domain State Modeling with Java Sealed Interfaces and Pattern Matching|Java 21 & Architecture|Combining \`sealed interface\` hierarchies with \`switch\` pattern matching enables the compiler to verify exhaustiveness without a catch-all \`default\` branch. When a new domain outcome is added in the future, every unhandled \`switch\` expression fails at compile time rather than silently misrouting in production."
  "postgres-partial-indexes|PostgreSQL Partial Indexes for Hot-State Queries|Database Engineering|Indexing a low-cardinality \`status\` column where 99% of rows are \`COMPLETED\` wastes disk and slows writes. A partial index (\`CREATE INDEX idx_pending ON payments (next_retry_at) WHERE status = 'RETRY_SCHEDULED'\`) indexes only active in-flight rows, keeping the B-tree tiny and index scans sub-millisecond."
  "graceful-shutdown-spring-boot|Zero-Dropped-Request Graceful Shutdown in Spring Boot and Kubernetes|Cloud Native & Operations|Enabling \`server.shutdown=graceful\` with \`spring.lifecycle.timeout-per-shutdown-phase=30s\` stops accepting new requests on \`SIGTERM\` while allowing in-flight HTTP requests and active database transactions to complete cleanly before the container exits."
  "mdc-correlation-ids-observability|Distributed Request Tracing with SLF4J MDC and Correlation IDs|Observability & Operations|Propagating an \`X-Correlation-Id\` header at the servlet filter boundary into SLF4J's Mapped Diagnostic Context (\`MDC.put(\"correlationId\", id)\`) tags every log line across controllers, services, and SQL statements—and clearing it in a \`finally\` block prevents thread-reuse leakage."
  "problem-details-rfc-9457|Standardized API Error Responses with RFC 9457 Problem Details in Spring Boot 3|API Design|Returning ad-hoc JSON error shapes makes client error handling brittle. Spring Framework 6 / Boot 3 natively supports \`ProblemDetail\` (RFC 9457), providing machine-readable \`type\`, \`title\`, \`status\`, \`detail\`, and \`instance\` fields alongside custom extension properties."
  "optimistic-vs-pessimistic-deadlocks|Preventing Lock-Ordering Deadlocks in Multi-Row PostgreSQL Updates|Database & Concurrency|When concurrent transactions lock multiple accounts or ledger rows in different orders, PostgreSQL detects a cycle and aborts one transaction with SQLSTATE \`40P01\`. Sorting entity IDs deterministically (e.g., ascending UUID order) before acquiring row locks eliminates circular wait conditions completely."
  "testcontainers-reusable-singletons|Fast Integration Testing with Singleton Testcontainers in Spring Boot|Testing & Quality|Spinning up a fresh PostgreSQL container per test class adds minutes to CI pipelines. Using a shared abstract base test with \`@ServiceConnection\` and a static container lifecycle runs the entire integration suite against one isolated container instance with Flyway migrations applied once."
  "rate-limiting-token-bucket|Token Bucket vs. Sliding Window Rate Limiting at the API Edge|Security & APIs|Fixed-window counters allow 2x burst traffic across window boundaries. A token bucket or Redis-backed sliding window enforces both sustained average rate and bounded burst capacity, protecting downstream databases from noisy-neighbor traffic spikes."
  "double-entry-ledger-immutability|Immutable Double-Entry Ledger Design for Financial Systems|Fintech & Architecture|Never mutate an account balance column in place without an audit trail. Record every value movement as balanced debit/credit journal entries in an append-only table where \`SUM(entries) = 0\` per transaction, deriving balances via materialized snapshots plus recent deltas."
  "kafka-consumer-idempotency|Idempotent Kafka Consumers: Handling Duplicate Delivery After Rebalances|Distributed Systems|When a consumer group rebalances before offsets are committed, incoming partitions replay the last batch of messages. Storing processed \`event_id\` keys in a deduplication table inside the same database transaction as the business state update turns at-least-once broker delivery into effectively-once processing."
  "jvm-zgc-generational-low-latency|Generational ZGC in Java 21 for Sub-Millisecond Pause Times|Java 21 & Performance|Enabling Generational ZGC (\`-XX:+UseZGC -XX:+ZGenerational\`) separates young and old object collection cycles, dramatically reducing allocation stalls and keeping GC pauses under 1 millisecond even on multi-gigabyte heaps under heavy request allocation."
  "restclient-spring-boot-32|Migrating from RestTemplate to Spring 6 Synchronous RestClient|Spring Boot Internals|Spring 6.1 / Boot 3.2 introduced \`RestClient\`, combining the fluent, readable API of \`WebClient\` with synchronous blocking execution—making it an ideal pairing with Java 21 virtual threads without requiring reactive \`Mono\`/\`Flux\` pipelines."
  "clock-injection-deterministic-tests|Injecting java.time.Clock for 100% Deterministic Time-Based Tests|Testing & Quality|Hardcoding \`Instant.now()\` makes expiration, retry backoff, and timestamp tolerance tests flaky or dependent on \`Thread.sleep()\`. Injecting a Spring \`Clock\` bean allows production to use \`Clock.systemUTC()\` while tests supply \`Clock.fixed()\` or a mutable test clock."
)

pick_unused_topic() {
  local day_num
  day_num=$(date -u +%s)
  local base_idx=$(( (day_num / 86400) % ${#TOPICS[@]} ))
  for offset in $(seq 0 $(( ${#TOPICS[@]} - 1 ))); do
    local idx=$(( (base_idx + offset) % ${#TOPICS[@]} ))
    local entry="${TOPICS[$idx]}"
    local slug="${entry%%|*}"
    if ! ls notes/*-"${slug}".md >/dev/null 2>&1; then
      echo "$entry"
      return 0
    fi
  done
  # Fallback if all topics have been used once: include date suffix
  echo "${TOPICS[$base_idx]}"
}

perform_one_commit() {
  local current_count="$1"
  git config user.name "Michael Bechaalani"
  git config user.email "michaelbechaalani1@gmail.com"

  if [ "$current_count" -eq 0 ] || ! ls notes/"${TODAY}"-*.md >/dev/null 2>&1; then
    # Commit #1: Create today's primary engineering note + update README.md
    ENTRY=$(pick_unused_topic)
    IFS='|' read -r SLUG TITLE CATEGORY BODY <<< "$ENTRY"
    FILE="notes/${TODAY}-${SLUG}.md"

    cat <<EOF > "$FILE"
# ${TITLE}

**Date:** ${TODAY}  
**Category:** ${CATEGORY}

---

## Overview

${BODY}

## Key Checklist
- Verify behavior under concurrent load and failure injection.
- Keep transaction scopes minimal and observability metrics explicit.
EOF

    ROW="| **${TODAY}** | [${TITLE}](${FILE}) | ${CATEGORY} |"
    if ! grep -Fq "$FILE" README.md; then
      awk -v row="$ROW" '
        /^\| :--- \| :--- \| :--- \|$/ { print; print row; next }
        { print }
      ' README.md > README.tmp && mv README.tmp README.md
    fi

    git add notes/ README.md
    git commit -m "docs(notes): add daily engineering note for ${TODAY}"
    echo "Created Commit #1 for ${TODAY}: ${FILE}"

  elif [ "$current_count" -eq 1 ]; then
    # Commit #2: Append implementation guidelines & production readiness verification to today's note
    FILE=$(ls notes/"${TODAY}"-*.md | head -n 1)
    if ! grep -Fq "## Production Implementation Notes" "$FILE"; then
      cat <<EOF >> "$FILE"

---

## Production Implementation Notes

1. **Boundary Validation:** Enforce invariants at the API and persistence boundaries using explicit constraints rather than relying solely on caller discipline.
2. **Observability:** Emit structured logs with correlation IDs and Micrometer counters for both happy-path transitions and rejected/retried edge cases.
3. **Failure Recovery:** Ensure every state transition is either atomic or safely idempotent when re-executed by a background reconciler.
EOF
      git add "$FILE"
      git commit -m "docs(notes): add production implementation notes for ${TODAY}"
      echo "Created Commit #2 for ${TODAY}: updated ${FILE}"
    fi

  else
    # Commit #3: Append trade-offs & testing strategy section to today's note
    FILE=$(ls notes/"${TODAY}"-*.md | head -n 1)
    if ! grep -Fq "## Trade-Offs & Verification Strategy" "$FILE"; then
      cat <<EOF >> "$FILE"

---

## Trade-Offs & Verification Strategy

| Dimension | Naive Approach | Production-Grade Approach |
| :--- | :--- | :--- |
| **Concurrency** | Unsynchronized read-modify-write | Explicit row locking / optimistic version checks |
| **Failure Mode** | Silent partial failure on timeout | Deterministic retry + idempotency key protection |
| **Testing** | Happy-path unit mocks only | Multi-threaded integration tests against real schema |
EOF
      git add "$FILE"
      git commit -m "docs(notes): add trade-offs matrix and verification strategy for ${TODAY}"
      echo "Created Commit #3 for ${TODAY}: updated ${FILE}"
    fi
  fi
}

if [ "$MODE" = "step" ]; then
  # Perform 1 commit in this scheduled slot (up to TARGET_COMMITS)
  perform_one_commit "$COMMITS_TODAY"
else
  # Catch up all remaining commits up to TARGET_COMMITS
  while [ "$COMMITS_TODAY" -lt "$TARGET_COMMITS" ]; do
    perform_one_commit "$COMMITS_TODAY"
    COMMITS_TODAY=$(( COMMITS_TODAY + 1 ))
  done
fi
