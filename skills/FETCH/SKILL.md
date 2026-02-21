---
name: FETCH
description: "Knowledge & Strategy domain context. Research scope classification,
  documentation source selection, decision factor analysis, and trade-off evaluation.
  C0RS0 executes with corsoTools action fetch (includes knowledge graph queries, formerly query_knowledge)."
user-invocable: false
context: fork
agent: C0RS0
version: 5.0.0
---

# /FETCH — Knowledge & Strategy Domain

> Build Phase 2/7: RESEARCH — Gather intel before the pack moves

## Lifecycle Context

Follows **SCOUT** (plan generated) -> feeds into **SNIFF** (code analysis with research context).

The primary research and strategic analysis entry point for C0RS0. Loads **research scoping, documentation sourcing, decision analysis, and trade-off evaluation** context into C0RS0, which then executes directly using knowledge MCP tools.

```
Claude -> loads FETCH context -> C0RS0 executes with fetch tool
```

---

## Protocol

### Step 1: Gather Requirements (if spec is vague)

1. Gather research-specific context:
   - **Question**: What question needs answering?
   - **Scope**: Which project, technology, or domain?
   - **Decision**: Is this informational research or driving a decision?
   - **Depth**: Quick overview or comprehensive deep dive?
   - **Criteria**: What factors matter most? (performance, cost, security, maintainability)
   - **Constraints**: Timeline, team expertise, existing stack?
2. Synthesize into a clear specification
3. Present spec for confirmation

### Step 2: Execute with MCP Tools

Use `mcp__C0RS0__corsoTools` with `action: "fetch"` for research, knowledge retrieval, and knowledge graph queries, applying all research intelligence context below.

---

## Quality Gates

### Pre-Execution
- [ ] Research scope classified
- [ ] Documentation sources identified for target language/framework
- [ ] Search strategy selected based on query intent
- [ ] Decision factors defined (if decision-driving research)

### Post-Execution
- [ ] All findings sourced with citations
- [ ] Recommendations include rationale
- [ ] Trade-off analysis presented (if applicable)
- [ ] All acceptance criteria met

---

## Research Scope Classification (from `knowledge.rs:infer_research_scope`)

Classify the research query to determine scope and depth:

| Query Type | Keywords | Scope |
|------------|----------|-------|
| API documentation | api, endpoint, interface, method | Targeted API specs and examples |
| Tutorial/guide | how to, tutorial, guide, getting started | Step-by-step guides, official tutorials |
| Code examples | example, sample, snippet, demo | Repository search, docs code blocks |
| Best practices | best practice, pattern, idiom, convention | Community patterns, official guidelines |
| Security | CVE, vulnerability, security, audit | CVE databases, security advisories |
| Architecture | design, architecture, structure, pattern | Design docs, architecture decision records |

---

## Documentation Sources (from `knowledge.rs:select_documentation_sources`)

**Rust**:
- doc.rust-lang.org (std library, book, reference)
- crates.io (package registry, README)
- docs.rs (auto-generated API docs)
- Rust by Example, Async Book

**Python**:
- docs.python.org (official docs, PEPs)
- PyPI (package metadata)
- Real Python (tutorials)

**JavaScript/TypeScript**:
- MDN Web Docs (language reference)
- npm (package registry)
- TypeScript Handbook

**Go**:
- pkg.go.dev (official package docs)
- Go Blog (design decisions)
- Effective Go

---

## Search Strategy (from `knowledge.rs:determine_search_strategy`)

| Query Intent | Strategy |
|-------------|----------|
| Latest/current | Focus on recent 6 months, official sources first |
| Specific API | Targeted function/method search, API docs |
| Comparison | Multi-source research, pros/cons analysis |
| Comprehensive | Deep dive, multiple angles, cross-reference |
| Quick answer | Overview, top results, summary |
| Code examples | Repository search, docs code blocks, playground |

---

## Decision Factors (from `wisdom.rs:identify_decision_factors`)

When analyzing architecture or technology decisions, apply these factors:

| Factor | Trigger Keywords | Weight |
|--------|-----------------|--------|
| Performance | optimize, speed, latency, throughput | High for systems/backend |
| Cost | budget, pricing, resources, ROI | High for cloud/infra |
| Security | security, threat, vulnerability, auth | Always high |
| Scalability | scale, growth, load, concurrent | High for distributed |
| Maintainability | maintain, technical debt, readability | Always consider |
| Team expertise | team, learning, familiar, ramp-up | Pragmatic factor |
| Timeline | deadline, sprint, MVP, urgent | Schedule pressure |

**Language-Specific Decision Factors** (from `wisdom.rs`):

- **Rust**: Performance, memory safety, compile-time guarantees, zero-cost abstractions
- **Python**: Development speed, ecosystem breadth, prototyping velocity
- **JavaScript/TypeScript**: Browser compatibility, ecosystem size, full-stack capability
- **Go**: Simplicity, concurrency model, deployment ease, compile speed

---

## Trade-Off Analysis (from `wisdom.rs:analyze_trade_offs`)

**Universal Trade-Offs**:
- Performance vs Simplicity
- Security vs Convenience
- Flexibility vs Constraints
- Speed vs Quality
- Features vs Stability

**Language-Specific Trade-Offs**:
- **Rust**: Safety & Performance vs Learning Curve
- **Python**: Development Speed vs Runtime Performance, Dynamic Typing vs Type Safety
- **JavaScript/TypeScript**: Runtime Flexibility vs Type Safety, Bundle Size vs Feature Richness
- **Go**: Simplicity vs Expressiveness, Goroutine Ease vs Resource Management

**Framework Trade-Offs**:
- Microservices: Distributed complexity vs deployment flexibility
- Async: High throughput vs code complexity

---

## Wisdom Domain Classification (from `wisdom.rs:determine_wisdom_domain`)

| Domain | Trigger Keywords |
|--------|-----------------|
| Architectural | architecture, design, structure |
| Algorithmic | algorithm, data structure, complexity |
| Organizational | team, organization, process |
| Technology Selection | technology, stack, tool, library |
| Scalability | scale, growth, millions, distributed |
| Technical Debt | refactor, technical debt, legacy |
| Security & Compliance | security, compliance, audit, GDPR |
| Performance | performance, optimize, benchmark |

---

## Cross-Domain Context

| When | Skill Context | MCP Tools |
|------|--------------|-----------|
| Research reveals security concerns | GUARD | `corsoTools` action: `guard` |
| Research evaluates codebase patterns | SNIFF | `corsoTools` action: `code_review` |
| Research drives performance comparison | CHASE | `corsoTools` action: `chase` |

---

## MCP Tools Available

| `corsoTools` Action | Purpose |
|---------------------|---------|
| `fetch` | Research & knowledge retrieval + knowledge graph queries |
