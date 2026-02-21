# CORSO

**Security-First AI Orchestration Platform**

CORSO is a production MCP (Model Context Protocol) server and Claude Code plugin built in Rust. It provides 24 tools through a single orchestrator, implements the full MCP specification, and routes AI workloads across multiple providers with automatic failover.

## What It Does

CORSO sits between Claude Code and the user's codebase, providing security scanning, code review, research, performance analysis, and an opinionated build pipeline. It's designed around the idea that AI-assisted development should have safety gates — not just for the code being written, but for the AI operations themselves.

### Key Capabilities

- **24 MCP tools** accessible through a single `corsoTools` orchestrator — speak, guard, fetch, sniff, chase, code_review, scout, and more
- **Full MCP specification coverage** — Tools, Resources (23 URIs across 4 schemes), Prompts (4 HITL workflow templates), and Tasks (async lifecycle with progress tracking)
- **Tool Search** — Implements Anthropic's Tool Search specification with BM25 and Regex search, reducing token consumption 85%+ through deferred tool loading
- **Programmatic Tool Calling (PTC)** — All 24 tools support programmatic invocation alongside natural language
- **Human-in-the-Loop (HITL)** — Approval workflows for high-stakes operations, combining MCP Prompts and Tasks into unified security gates
- **Multi-provider AI routing** — Routes across Anthropic, Mistral, Cerebras, Perplexity, and Ollama with automatic failover and circuit breakers

### Architecture

CORSO uses a Trinity-layered pipeline that executes entirely in-process with zero HTTP overhead:

![CORSO Architecture](docs/architecture.svg)

All three layers are Rust library calls — no microservices, no network hops, single binary deployment.

### Trinity Pipeline

Every request flows through three named layers, each with distinct failure semantics:

| Layer | Name | Role | On Failure |
|-------|------|------|------------|
| 1 | **RUACH** | Gateway — auth, rate limiting, input sanitization, complexity scoring (0-100) | Degrades gracefully |
| 2 | **IESOUS** | Orchestrator — hero selection, DAG-based parallel execution (max 5 concurrent) | Retry with exponential backoff |
| 3 | **ADONAI** | Validator — CORSO Protocol enforcement (49 rules, 7 pillars), security scanning | Fail-secure (deny request) |

### Archangels and Heroes

IESOUS delegates work to **4 Archangels**, each commanding specialized **Heroes**:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#ffffff', 'lineColor': '#6c757d'}}}%%
graph TD
    subgraph TRINITY ["Trinity Pipeline"]
        R(["RUACH<br/>Gateway"])
        I(["IESOUS<br/>Orchestrator"])
        A(["ADONAI<br/>Validator"])
        R ==> I ==> A
    end

    I --> U & M & G & RA

    subgraph URIEL ["URIEL — Code"]
        U(["Archangel"])
        D(["DAVID<br/>Code Generation"])
        EZ(["EZEKIEL<br/>Architecture Design"])
        PA(["PAUL<br/>Code Review & Tests"])
        SO(["SOLOMON<br/>Knowledge Search"])
        U --> D & EZ & PA & SO
    end

    subgraph MICHAEL ["MICHAEL — Security"]
        M(["Archangel"])
        EL(["ELIJAH<br/>Security Compliance"])
        ELI(["ELISHA<br/>Red Team & Pentesting"])
        JO(["JOSHUA<br/>Risk Management"])
        M --> EL & ELI & JO
    end

    subgraph GABRIEL ["GABRIEL — Knowledge"]
        G(["Archangel"])
        ME(["MELCHIZEDEK<br/>Research"])
        DA(["DANIEL<br/>Performance Analysis"])
        G --> ME & DA
    end

    subgraph RAPHAEL ["RAPHAEL — Infrastructure"]
        RA(["Archangel"])
        MO(["MOSES<br/>Deployment"])
        RA --> MO
    end

    classDef trinity fill:#4a90d9,color:#fff,stroke:#3a7bc8,stroke-width:2px
    classDef archangel fill:#d4a034,color:#fff,stroke:#b8892d,stroke-width:2px
    classDef hero fill:#2d3436,color:#fff,stroke:#636e72,stroke-width:1px

    class R,I,A trinity
    class U,M,G,RA archangel
    class D,EZ,PA,SO,EL,ELI,JO,ME,DA,MO hero
```

### Domain Routing

Every tool call is resolved through a **compile-time static route table** — 24 entries, zero runtime cost. Each entry maps a tool to its owning Archangel, default heroes, and pipeline behavior:

| Tool | Domain | Default Heroes | Behavior |
|------|--------|---------------|----------|
| `guard` | MICHAEL | Elijah, Joshua | Security scan with dynamic hero augmentation |
| `fetch` | GABRIEL | Melchizedek, Daniel | Multi-source research |
| `sniff` | URIEL | Paul, Elijah, Joshua | Code analysis with cross-domain heroes |
| `chase` | RAPHAEL | Daniel, Moses | Performance analysis |
| `scout` | GABRIEL | Daniel | Plan generation |
| `code_review` | URIEL | Paul | Code review with dynamic augmentation |
| `deploy` | MICHAEL | Joshua, Elijah | Deployment with security validation |
| `speak` | RUACH | — | Direct execution (bypasses Trinity) |
| `read_file` | RUACH | — | Direct execution |

Tools marked `direct_execution` skip the Trinity pipeline entirely — no heroes, no ADONAI validation. Tools with `dynamic_selection` allow IESOUS to augment beyond default heroes based on complexity.

**Complexity-driven fan-out**: RUACH scores each request 0-100. This determines how many heroes execute:

| Complexity | Score | Hero Selection | ADONAI Validation |
|-----------|-------|----------------|-------------------|
| Simple | 0–30 | Default heroes only | Skipped |
| Medium | 31–60 | Default heroes | Full pipeline |
| Complex | 61–100 | Default + augmented (max 5 parallel) | Full + extended feedback |

**Intent classification fallback**: For tasks that don't map to a pre-defined tool, the ArchangelRouter classifies intent via keyword scoring and routes to the highest-match Archangel. Unknown intents default to URIEL.

### C0RS0 Pack Build Cycle

CORSO includes a 7-phase build pipeline for structured development:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#ffffff', 'lineColor': '#6c757d'}}}%%
flowchart LR
    subgraph PLAN ["Phase 1 — Plan"]
        S(["SCOUT<br/>Requirements · Triage"])
        S --> PG1{"HITL<br/>Gate"}
    end

    PG1 ==> F

    subgraph ANALYZE ["Phases 2–5 — Analyze"]
        F(["FETCH<br/>Research"]) --> SN(["SNIFF<br/>Code Analysis"])
        SN --> G(["GUARD<br/>Security Scan<br/>4,997 patterns"])
        G --> C(["CHASE<br/>Test · Perf"])
        G -.->|"vulnerabilities found"| SN
    end

    C ==> PG2

    subgraph SHIP ["Phases 6–7 — Ship"]
        PG2{"HITL<br/>Gate"} ==> H(["HUNT<br/>Execute Plan"])
        H --> QG{"Quality<br/>Gate"}
        QG -->|pass| SC(["SCRUM<br/>Squad Review"])
        QG -.->|fail| H
        SC -.->|"rework needed"| H
    end

    classDef plan fill:#6c5ce7,color:#fff,stroke:#5a4bd6,stroke-width:2px
    classDef research fill:#0984e3,color:#fff,stroke:#0873c4,stroke-width:2px
    classDef code fill:#00b894,color:#fff,stroke:#009a7d,stroke-width:2px
    classDef security fill:#d63031,color:#fff,stroke:#b52828,stroke-width:2px
    classDef test fill:#e17055,color:#fff,stroke:#c45f48,stroke-width:2px
    classDef execute fill:#fdcb6e,color:#333,stroke:#dbb35e,stroke-width:2px
    classDef review fill:#a29bfe,color:#fff,stroke:#8b84e0,stroke-width:2px
    classDef gate fill:#2d3436,color:#fff,stroke:#636e72,stroke-width:2px

    class S plan
    class F research
    class SN code
    class G security
    class C test
    class H execute
    class SC review
    class PG1,PG2,QG gate
```

Each phase has its own skill definition, domain context, and quality gates. Dashed arrows show feedback loops — security findings flow back to code analysis, failed quality gates retry execution, and squad review can trigger rework.

### Tool Reference

All 24 tools are accessible through a single `corsoTools` MCP orchestrator via the `action` parameter:

| # | Tool | Domain | Description |
|---|------|--------|-------------|
| 1 | `speak` | RUACH | General chat and delegation routing |
| 2 | `read_file` | RUACH | Read file contents |
| 3 | `write_file` | RUACH | Write file contents |
| 4 | `list_directory` | RUACH | List directory contents |
| 5 | `sniff` | URIEL | Code analysis and generation |
| 6 | `search_code` | URIEL | Semantic code search |
| 7 | `generate_code` | URIEL | AI-powered code generation |
| 8 | `code_review` | URIEL | Code review with standards enforcement |
| 9 | `find_symbol` | URIEL | Symbol lookup (tree-sitter, deferred) |
| 10 | `get_outline` | URIEL | File structure outline (tree-sitter, deferred) |
| 11 | `get_references` | URIEL | Cross-reference lookup (tree-sitter, deferred) |
| 12 | `guard` | MICHAEL | Security scan — 4,997 vulnerability patterns |
| 13 | `deploy` | MICHAEL | Deployment orchestration |
| 14 | `rollback` | MICHAEL | Deployment rollback |
| 15 | `container_manage` | MICHAEL | Container lifecycle management |
| 16 | `secret_manage` | MICHAEL | Secrets management (locked to Elijah) |
| 17 | `fetch` | GABRIEL | Multi-source research and knowledge retrieval |
| 18 | `search_documentation` | GABRIEL | Documentation search |
| 19 | `analyze_architecture` | GABRIEL | Architecture analysis and design review |
| 20 | `scout` | GABRIEL | Plan generation and strategy |
| 21 | `chase` | RAPHAEL | Performance analysis and benchmarking |
| 22 | `monitor_health` | RAPHAEL | System health monitoring |
| 23 | `scale_resources` | RAPHAEL | Resource scaling |
| 24 | `manage_logs` | RAPHAEL | Log management and analysis |

Tools 9-11 use **deferred loading** — excluded from `tools/list` to reduce token cost, but still callable via `tools/call` and discoverable through Tool Search.

## Plugin Structure

This repository contains the Claude Code plugin layer — the integration code that connects CORSO's MCP server to Claude Code's agent, hook, and skill systems.

```
plugin/
├── .mcp.json                    # MCP server definition
├── .claude-plugin/plugin.json   # Plugin manifest
├── agents/
│   ├── C0RS0.md                 # Primary agent (behavior, tools, protocol)
│   └── TEAM-HELIX.md            # Squad consultation router
├── hooks/
│   ├── hooks.json               # Hook registration (9 hooks)
│   ├── check-mcp.sh             # MCP server health checks
│   ├── plan-gate.sh             # Blocks execution tools during planning
│   ├── phase-gate.sh            # Pipeline state validation
│   ├── security-pre-check.sh    # Pre-scan validation
│   ├── block-destructive.sh     # Blocks dangerous bash commands
│   ├── skill-banner.sh          # Pack-themed skill banners
│   ├── rustfmt-on-save.sh       # Auto-format Rust on save
│   └── quality-check.sh         # Post-write code quality analysis
└── skills/
    ├── CORSO/SKILL.md           # Master skill (603 lines)
    ├── SCOUT/SKILL.md           # Plan generation
    ├── FETCH/SKILL.md           # Research domain
    ├── SNIFF/SKILL.md           # Code analysis domain
    ├── GUARD/SKILL.md           # Security domain
    ├── CHASE/SKILL.md           # Testing domain
    ├── HUNT/SKILL.md            # Plan execution
    └── SCRUM/SKILL.md           # Squad review
```

## Tech Stack

- **Runtime**: Rust (single binary, ~15MB)
- **Protocol**: MCP over stdio (JSON-RPC 2.0)
- **AI Providers**: Anthropic, Mistral, Cerebras, Perplexity, Ollama
- **Observability**: OpenTelemetry → SigNoz
- **Standards**: clippy::pedantic, zero unwrap/panic, mandatory security scans

## Part of Light Architects

CORSO is one of five MCP servers in the Light Architects platform:

| Server | Purpose |
|--------|---------|
| **CORSO** | Security, orchestration, build pipeline |
| [QUANTUM](https://github.com/theLightArchitect/QUANTUM) | Forensic investigation, evidence analysis |
| [EVA](https://github.com/theLightArchitect/EVA) | Personal assistant, memory, code review |
| [SOUL](https://github.com/theLightArchitect/SOUL) | Knowledge graph, shared infrastructure, voice |

All servers share a common `mcp-protocol` crate for type-safe JSON-RPC communication and are instrumented with distributed tracing via OpenTelemetry.

## Author

Kevin Francis Tan — [github.com/theLightArchitect](https://github.com/theLightArchitect)
