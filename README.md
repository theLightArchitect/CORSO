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

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#ffffff', 'lineColor': '#6c757d'}}}%%
flowchart TD
    A(["Claude Code<br/>MCP Client"]) ==> TS

    subgraph TS ["Tool Search — BM25 + Regex"]
        direction LR
        TS1["Deferred Loading<br/>85%+ token reduction"]
    end

    TS1 ==> B

    subgraph TRINITY ["Trinity Pipeline — Zero HTTP Overhead"]
        direction TB
        B["RUACH<br/>Gateway"]
        B -->|"classify complexity<br/>select tier"| C["IESOUS<br/>Orchestrator"]

        subgraph DOMAIN ["Domain Routing — 24 Tools"]
            direction LR
            D1(["guard"])
            D2(["fetch"])
            D3(["sniff"])
            D4(["chase"])
            D5(["speak"])
            D6(["code_review"])
            D7(["scout"])
            D8(["+ 17 more"])
        end

        C ==> DOMAIN

        DOMAIN ==> AI

        subgraph AI ["Multi-Provider AI Routing"]
            direction LR
            P1(["Anthropic"])
            P2(["Mistral"])
            P3(["Cerebras"])
            P4(["Perplexity"])
            P5(["Ollama"])
            P1 -.->|failover| P2
            P2 -.->|failover| P3
        end

        AI ==> D["ADONAI<br/>Validator"]
        D -->|"validate output<br/>enforce standards"| HITL
    end

    subgraph HITL ["HITL — Approval Gates"]
        direction LR
        H1{"High-stakes?"}
        H1 -->|no| H2([Auto-approve])
        H1 -->|yes| H3([User Review])
    end

    HITL ==> E(["Response"])

    classDef gateway fill:#4a90d9,color:#fff,stroke:#3a7bc8,stroke-width:2px
    classDef orch fill:#d4a034,color:#fff,stroke:#b8892d,stroke-width:2px
    classDef valid fill:#50b87a,color:#fff,stroke:#40a066,stroke-width:2px
    classDef tool fill:#2d3436,color:#fff,stroke:#636e72,stroke-width:1px
    classDef provider fill:#6c5ce7,color:#fff,stroke:#5a4bd6,stroke-width:1px
    classDef search fill:#0984e3,color:#fff,stroke:#0873c4,stroke-width:2px
    classDef gate fill:#d63031,color:#fff,stroke:#b52828,stroke-width:2px
    classDef io fill:#f8f9fa,color:#333,stroke:#6c757d,stroke-dasharray:5 5

    class B gateway
    class C orch
    class D valid
    class D1,D2,D3,D4,D5,D6,D7,D8 tool
    class P1,P2,P3,P4,P5 provider
    class TS1 search
    class H1 gate
    class A,E,H2,H3 io
```

All three layers are Rust library calls — no microservices, no network hops, single binary deployment.

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

CORSO is one of four MCP servers in the Light Architects platform:

| Server | Purpose |
|--------|---------|
| **CORSO** | Security, orchestration, build pipeline |
| [EVA](https://github.com/theLightArchitect/EVA) | Personal assistant, memory, code review |
| [SOUL](https://github.com/theLightArchitect/SOUL) | Knowledge graph, shared infrastructure, voice |

All four servers share a common `mcp-protocol` crate for type-safe JSON-RPC communication and are instrumented with distributed tracing via OpenTelemetry.

## Author

Kevin Francis Tan — [github.com/theLightArchitect](https://github.com/theLightArchitect)
