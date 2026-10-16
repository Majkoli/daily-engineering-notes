#!/usr/bin/env bash
set -euo pipefail

TODAY=$(date -u +"%Y-%m-%d")

# Check if a note or commit was already created today
if ls notes/"${TODAY}"-*.md >/dev/null 2>&1; then
  echo "A note for ${TODAY} already exists. Skipping fallback generation."
  exit 0
fi

# Curated bank of backend engineering notes for cloud fallback when workstation is offline
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
)

DAY_INDEX=$(( $(date -u +%j) % ${#TOPICS[@]} ))
ENTRY="${TOPICS[$DAY_INDEX]}"

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

# Append entry to README table right after the table header
ROW="| **${TODAY}** | [${TITLE}](${FILE}) | ${CATEGORY} |"
awk -v row="$ROW" '
  /^\| :--- \| :--- \| :--- \|$/ { print; print row; next }
  { print }
' README.md > README.tmp && mv README.tmp README.md

echo "Generated ${FILE}"
