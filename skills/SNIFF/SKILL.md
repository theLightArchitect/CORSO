---
name: SNIFF
description: "Code & Architecture analysis domain. Coding standards, quality metrics, code
  smell detection, architecture style matching, and language-specific patterns. C0RS0
  executes with corsoTools action code_review."
user-invocable: false
context: fork
agent: C0RS0
version: 5.0.0
---

# /SNIFF — Code & Architecture Domain

> Build Phase 3/7: LINT — Static analysis and code quality after research is complete

## Lifecycle Context

Follows **FETCH** (research context) -> feeds into **GUARD** (security scan on detected patterns).

The primary coding and architecture **analysis** entry point for C0RS0. Loads Light Architects coding standards, architecture analysis, quality enforcement, and code smell detection context into C0RS0, which then executes reviews using the code_review MCP tool.

> **Note**: Code generation (`corsoTools` action: `sniff`) is handled by HUNT during plan execution.
> SNIFF provides the quality standards and patterns that HUNT enforces when generating code.

```
Claude -> loads SNIFF context -> C0RS0 executes with code_review tool
```

---

## Protocol

### Step 1: Gather Requirements (if spec is vague)

1. Gather coding-specific requirements:
   - What to build/fix/refactor/review?
   - Which project/files/modules?
   - Language, framework, dependencies?
   - Architecture goals? Pain points?
   - Acceptance criteria?
2. Synthesize into a clear specification
3. Present spec for confirmation

### Step 2: Execute with MCP Tools

Use `mcp__C0RS0__corsoTools` with `action: "code_review"` for quality analysis, applying all coding standards, architecture intelligence, and domain context below.

---

## Quality Gates

### Pre-Execution
- [ ] Requirements clear and confirmed
- [ ] Target files/modules identified
- [ ] Language and framework known
- [ ] Architecture style detected
- [ ] Language-specific patterns identified

### Post-Execution
- [ ] No `.unwrap()` / `.expect()` / `panic!()` in new code
- [ ] All functions <= 60 lines, complexity <= 10
- [ ] Error paths handled (not swallowed)
- [ ] No duplicated logic blocks
- [ ] No deep nesting (>3 levels)
- [ ] Test coverage >= 90%
- [ ] All acceptance criteria met

---

## Light Architects Coding Standards (Non-Negotiable)

### Rust

```
- NO .unwrap() / .expect() in production — use ? or match
- NO panic!() — use Result<T, E>
- unsafe requires // SAFETY: comment with justification
- clippy::pedantic enforced as errors
- Checked arithmetic (checked_add, saturating_sub)
- Functions <= 60 lines
- Cyclomatic complexity <= 10
- Error chains preserve cause (thiserror for library, anyhow for app)
```

### Quality Metrics

```
- Every public function returns Result
- No swallowed errors (empty catch / if let Err(_))
- No TODO/FIXME without ticket reference
- Meaningful variable/function names
- Comments explain WHY, not WHAT
- Test coverage >= 90%
```

### Architecture Principles

```
- Determinism over cleverness
- Fail-safe defaults & degraded modes
- Total traceability
- No unbounded loops (fixed upper bounds)
- No dynamic memory in critical paths
```

---

## Error Handling Enforcement

```
- Result propagation via ? operator
- No swallowed errors (empty catch / if let Err(_))
- Error chains preserve cause (thiserror for library, anyhow for app)
- Every public function returns Result
- Use map_err() to add context when crossing module boundaries
```

## Arithmetic Safety

```
- Use checked_add, checked_mul for overflow-prone operations
- Use saturating_sub for underflow-prone subtractions
- No implicit integer truncation
```

---

## Code Smell Detection (from `review.rs:identify_code_smells`)

| Smell | Detection | Fix |
|-------|-----------|-----|
| Long function | >60 lines | Split into focused helpers |
| Deep nesting | >3 indent levels | Extract, early return, guard clauses |
| God object | >10 methods on one struct | Decompose into focused types |
| Duplicated logic | Same pattern in 2+ places | Extract shared function |
| Long parameter list | >4 params | Use builder pattern or config struct |
| Boolean blindness | `fn foo(bar: bool, baz: bool)` | Use enums for clarity |

---

## Quality Metrics (from `review.rs:extract_quality_metrics`)

```
- Max 60 lines per function — split longer functions
- Cyclomatic complexity <= 10 — extract branches into helpers
- Meaningful comment ratio — comments explain WHY, not WHAT
- No duplicated logic blocks (same pattern in 2+ places)
- No deep nesting (>3 indent levels)
```

---

## Architecture Style Matching (from `architecture.rs:infer_architecture_style`)

Detect and enforce architecture consistency:

| Signal Keywords | Architecture Style |
|----------------|-------------------|
| `http`, `grpc`, `async`, `service` | Microservices |
| `mpsc`, `channel`, `event`, `handler` | Event-Driven |
| `controller`, `service`, `repository` | Layered |
| `port`, `adapter`, `hexagonal` | Hexagonal / Ports & Adapters |

---

## Language-Specific Patterns (from `architecture.rs:select_architecture_patterns`)

**Rust**:
- Type-driven design (newtype pattern, enums for state)
- Result/Option propagation with `?`
- Ownership and borrowing (prefer `&T` over `Clone`)
- Trait-based abstraction (define interfaces as traits)
- Builder pattern for complex construction

**Python**:
- Decorators for cross-cutting concerns
- Context managers for resource lifecycle
- Protocol classes for structural typing
- Dataclasses for value objects

**JavaScript/TypeScript**:
- Module pattern for encapsulation
- Promise/async-await for concurrency
- Factory functions over classes
- Discriminated unions (TS) for type safety

**Go**:
- Interface-based design (small interfaces)
- Goroutines + channels for concurrency
- Table-driven tests
- Error wrapping with `fmt.Errorf`

---

## Scalability Analysis (from `architecture.rs:build_scalability_context`)

| Signal | Scalability Concern |
|--------|-------------------|
| Database access | Connection pooling, query optimization |
| Async/concurrent | Task management, backpressure |
| Static content | Multi-instance review, CDN consideration |
| State management | Stateless design, external state stores |

---

## Cross-Domain Context

| When | Skill Context | MCP Tools |
|------|--------------|-----------|
| Security review of new code | GUARD | `corsoTools` action: `guard` |
| Architecture patterns research | FETCH | `corsoTools` action: `fetch` |
| Test strategy for new code | CHASE | `corsoTools` action: `chase` |

---

## MCP Tools Available

| `corsoTools` Action | Purpose |
|---------------------|---------|
| `code_review` | Quality analysis and review |
