---
name: CHASE
description: "Testing, Performance & Ops domain context. Test strategy inference,
  bottleneck detection, metrics selection, infrastructure analysis, and coverage
  enforcement. C0RS0 executes with corsoTools action chase."
user-invocable: false
context: fork
agent: C0RS0
version: 5.0.0
---

# /CHASE — Testing, Performance & Ops Domain

> Build Phase 5/7: TEST — Find the weak points before the pack ships

## Lifecycle Context

Follows **GUARD** (security verified) -> feeds into **HUNT** (execute with confidence).

The primary testing, performance, and infrastructure entry point for C0RS0. Loads **test strategy, bottleneck detection, metrics, coverage enforcement, and infrastructure analysis** context into C0RS0, which then executes directly using performance MCP tools.

```
Claude -> loads CHASE context -> C0RS0 executes with track tool
```

---

## Protocol

### Step 1: Gather Requirements (if spec is vague)

1. Gather ops-specific context:

   **Testing focus**:
   - What to test? Which modules, functions, or flows?
   - Current coverage? Known gaps?
   - Test types needed? (unit, integration, E2E, property-based)

   **Performance focus**:
   - Current metrics / baseline?
   - Target metrics? (latency p99, throughput, memory)
   - Constraints? (CPU, memory, network, budget)

   **Infrastructure focus**:
   - Target environment? (cloud, on-prem, container, serverless)
   - Existing infrastructure?
   - Scale requirements? (users, requests/sec, data volume)

2. Synthesize into a clear specification
3. Present spec for confirmation

### Step 2: Execute with MCP Tools

Use `mcp__C0RS0__corsoTools` with `action: "chase"` for performance analysis and monitoring, applying all ops intelligence context below.

---

## Quality Gates

### Pre-Execution
- [ ] Scope and objectives defined
- [ ] Test strategy inferred from code patterns
- [ ] Framework conventions identified for target language
- [ ] Coverage targets defined (minimum 90%)

### Post-Execution
- [ ] Coverage >= 90%
- [ ] All test failures explained with actionable notes
- [ ] Performance baselines established (if performance domain)
- [ ] Infrastructure configs validated (if infrastructure domain)
- [ ] All acceptance criteria met

---

## Test Strategy Inference (from `testing.rs:infer_test_strategy`)

Map code constructs to test types:

| Code Pattern | Test Type | Priority |
|-------------|-----------|----------|
| `fn` / `impl` / `struct` | Unit test | Must have |
| `async` functions | `tokio::test` / async runtime | Must have |
| `pub` functions | Integration test | Must have |
| `Result` / `Error` types | Error path test | Must have |
| Module boundaries | Integration test | Should have |
| HTTP/API endpoints | Integration + E2E | Should have |
| CLI commands | Integration test | Should have |

---

## Framework Conventions (from `testing.rs:select_test_types`)

**Rust**:
- `#[cfg(test)]` module in same file for unit tests
- `tests/` directory for integration tests
- `#[test]` attribute, `assert!`, `assert_eq!`
- `proptest` for property-based testing
- `tokio::test` for async tests
- `mockall` for mock generation

**Python**:
- `pytest` as primary framework
- `hypothesis` for property-based testing
- `pytest-asyncio` for async tests
- `unittest.mock` for mocking
- Fixtures for setup/teardown

**JavaScript/TypeScript**:
- Jest or Vitest for unit/integration
- Playwright for E2E / browser tests
- `describe`/`it`/`expect` BDD pattern
- `jest.mock` for module mocking

**Go**:
- `testing.T` standard library
- `testify` for assertions
- Table-driven tests (idiomatic Go pattern)
- `httptest` for HTTP testing

---

## Coverage Requirements

| Level | Target | What |
|-------|--------|------|
| Unit | 90%+ | All public functions, edge cases |
| Integration | Key paths | Cross-module interactions |
| Error paths | All | Invalid input, network failure, timeout |
| Edge cases | All | Empty input, max values, concurrent access |

**Minimum: 90% line coverage** (unit + integration combined).

---

## Bottleneck Detection (from `performance.rs:identify_bottleneck_areas`)

| Pattern | Concern | Optimization |
|---------|---------|-------------|
| Loops (`for`, `while`, `loop`) | O(n) scaling | Iterators, early exit, parallel |
| `HashMap` | Hash computation overhead | Pre-size with `with_capacity` |
| `Vec` | Reallocation on growth | Pre-size with `with_capacity` |
| `String` | Heap allocation per concat | `format!`, `push_str`, `Cow<str>` |
| `.clone()` | Unnecessary copying | Borrow (`&T`), `Rc`/`Arc` for shared |
| `Mutex` | Lock contention | `RwLock`, lock-free, finer granularity |
| `File` I/O | Disk latency | Buffered I/O, async I/O, batch |
| HTTP calls | Network latency | Connection pooling, batching, caching |

---

## Metrics Selection (from `performance.rs:suggest_metrics`)

| Category | Metrics |
|----------|---------|
| Latency | p50, p95, p99 response times |
| Throughput | Requests/second, Transactions/second |
| Resources | CPU %, memory usage, heap size |
| Rust-specific | Compile time, binary size, allocator stats |
| Go-specific | Goroutine count, GC pause time |
| JS-specific | Event loop lag, heap snapshot size |

---

## Optimization Strategies (from `performance.rs:recommend_optimization_strategies`)

**Rust**:
- Iterators over manual loops (zero-cost abstraction)
- Borrowing over cloning (`&T` not `T`)
- `with_capacity` for Vec/HashMap/String
- `flamegraph` for profiling
- LTO (Link-Time Optimization) for release builds
- `rayon` for data-parallel computation

**Python**:
- List comprehensions over loops
- `asyncio` for I/O-bound work
- `multiprocessing` for CPU-bound work
- `numpy`/`pandas` for data processing
- Profile with `cProfile`

**JavaScript**:
- `Promise.all` for parallel async
- Avoid blocking event loop
- Stream processing for large data
- Bundle splitting for client-side

---

## Infrastructure Analysis (from `infrastructure.rs`)

**Deployment Targets** (from `infrastructure.rs:infer_deployment_target`):

| Signal | Target |
|--------|--------|
| kubernetes, k8s | Kubernetes cluster |
| docker, container | Docker containerized |
| aws, amazon | AWS |
| gcp, google cloud | GCP |
| serverless, lambda | Serverless / FaaS |
| bare metal, vps | Bare metal / VPS |

**IaC Tools** (from `infrastructure.rs:select_iac_tools`):

| Language | Default Tools |
|----------|--------------|
| Rust | Dockerfile (multi-stage), Kubernetes manifests |
| Python | Dockerfile, Ansible |
| JavaScript | Dockerfile (Node.js), Serverless Framework |
| Go | Dockerfile (single binary), Kubernetes manifests |

**CI/CD Pipeline** (from `infrastructure.rs:determine_cicd_pipeline`):

- **Rust**: `cargo build --release` -> `cargo test --all-features` -> `cargo clippy -- -D warnings` -> `cargo fmt --check` -> Security Scan -> Deploy
- **Python**: `pip install` -> `pytest` with coverage -> `pylint`, `flake8`, `black` -> Security Scan -> Deploy
- **JS/TS**: `npm install` -> `npm run build` -> `npm test` -> `eslint`, `prettier` -> Security Scan -> Deploy
- **Go**: `go build` -> `go test ./...` -> `golangci-lint run` -> Security Scan -> Deploy

---

## Cross-Domain Context

| When | Skill Context | MCP Tools |
|------|--------------|-----------|
| Researching test patterns or benchmarks | FETCH | `corsoTools` action: `fetch` |
| Reviewing code under test for quality | SNIFF | `corsoTools` action: `code_review` |
| Infrastructure security review | GUARD | `corsoTools` action: `guard` |

---

## MCP Tools Available

| `corsoTools` Action | Purpose |
|---------------------|---------|
| `chase` | Performance analysis & monitoring |
