# CORSO

**Security-first MCP server for Claude Code.** Scans your code for vulnerabilities, reviews pull requests, researches documentation, analyzes performance, and enforces quality gates — all through a single tool orchestrator.

## Quick Start

```bash
# Install (macOS arm64)
curl -fsSL https://raw.githubusercontent.com/theLightArchitect/CORSO/main/install.sh | bash

# Add to Claude Code
claude mcp add C0RS0 -- ~/.corso/bin/corso
```

Restart Claude Code. You're done.

## What You Get

| Tool | What It Does | Try It |
|------|-------------|--------|
| `guard` | Security scan — 4,997 vulnerability patterns (SQL injection, XSS, command injection, secrets, dependency CVEs) | *"CORSO, scan this project for security issues"* |
| `code_review` | Code review with standards enforcement (complexity, error handling, architecture) | *"CORSO, review this file"* |
| `fetch` | Multi-source research — documentation, knowledge graphs, decision analysis | *"CORSO, research how to implement OAuth2 in Rust"* |
| `chase` | Performance analysis — bottleneck identification, benchmarking, optimization | *"CORSO, profile this function"* |
| `scout` | Plan generation — requirements triage, architecture design, strategy | *"CORSO, plan the implementation for this feature"* |

Plus 19 more tools (code generation, deployment, container management, log analysis, etc.) accessible through a single `corsoTools` orchestrator.

## Requirements

- macOS with Apple Silicon (M1/M2/M3/M4)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI

## macOS Security Note

The binary is ad-hoc signed. If macOS blocks it:

```bash
xattr -cr ~/.corso/bin/corso
```

## Architecture

CORSO routes every request through a three-layer pipeline — zero HTTP, single binary, entirely in-process:

```mermaid
flowchart LR
    REQ([Request]) ==> GW["Gateway<br/>Input validation<br/>Complexity classification"]
    GW ==> OR["Orchestrator<br/>Domain routing<br/>Parallel execution"]
    OR ==> VL["Validator<br/>Quality enforcement<br/>Security scanning"]
    VL ==> RES([Response])

    OR -.-> D1["Code<br/>Domain"]
    OR -.-> D2["Security<br/>Domain"]
    OR -.-> D3["Knowledge<br/>Domain"]
    OR -.-> D4["Infrastructure<br/>Domain"]

    classDef pipeline fill:#4a90d9,color:#fff,stroke:#3a7bc8,stroke-width:2px
    classDef domain fill:#2d3436,color:#fff,stroke:#636e72,stroke-width:1px
    classDef io fill:#00b894,color:#fff,stroke:#009a7d,stroke-width:2px

    class GW,OR,VL pipeline
    class D1,D2,D3,D4 domain
    class REQ,RES io
```

**Gateway** classifies each request by complexity and sanitizes input. **Orchestrator** routes to domain-specialized modules — simple requests get direct handling, complex requests fan out to multiple domains in parallel. **Validator** enforces quality standards and runs security checks before any response leaves the pipeline. On failure, the validator denies by default (fail-secure).

### Build Cycle

CORSO includes a 7-phase build pipeline with human-in-the-loop gates:

```mermaid
flowchart LR
    subgraph PLAN ["Phase 1 — Plan"]
        S(["Plan<br/>Requirements · Triage"])
        S --> PG1{"Gate"}
    end

    PG1 ==> F

    subgraph ANALYZE ["Phases 2–5 — Analyze"]
        F(["Research"]) --> SN(["Code Analysis"])
        SN --> G(["Security Scan"])
        G --> C(["Test · Perf"])
        G -.->|"issues found"| SN
    end

    C ==> PG2

    subgraph SHIP ["Phases 6–7 — Ship"]
        PG2{"Gate"} ==> H(["Execute"])
        H --> QG{"Quality<br/>Gate"}
        QG -->|pass| SC(["Review"])
        QG -.->|fail| H
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

## Plugin Structure

This repository is a Claude Code plugin. The MCP binary provides the tools; the plugin layer wires them into Claude Code's agent, hook, and skill systems.

```
├── agents/
│   ├── C0RS0.md              # Agent personality and tool routing
│   └── TEAM-HELIX.md         # Multi-agent consultation router
├── hooks/
│   ├── hooks.json             # 9 hooks (security gates, formatting, quality checks)
│   ├── check-mcp.sh           # MCP server health verification
│   ├── block-destructive.sh   # Blocks dangerous bash commands
│   ├── security-pre-check.sh  # Pre-commit security validation
│   └── ...
├── skills/
│   ├── CORSO/SKILL.md         # Master build cycle skill
│   ├── SCOUT/SKILL.md         # Plan generation
│   ├── GUARD/SKILL.md         # Security domain
│   └── ...                    # 8 skills total
├── install.sh                 # One-line installer
├── .mcp.json                  # MCP server definition
└── LICENSE                    # MIT
```

## Tech Stack

- **Language**: Rust (single binary, ~12MB, LTO + stripped)
- **Protocol**: MCP over stdio (JSON-RPC 2.0)
- **Standards**: `clippy::pedantic`, zero `.unwrap()`/`panic!()`, mandatory security scans before commit

## Part of Light Architects

CORSO is part of the Light Architects MCP platform:

| Server | Purpose | Install |
|--------|---------|---------|
| **CORSO** | Security scanning, code review, build pipeline | `curl -fsSL .../CORSO/main/install.sh \| bash` |
| [EVA](https://github.com/theLightArchitect/EVA) | AI personality, memory enrichment, creative workflows | `curl -fsSL .../EVA/main/install.sh \| bash` |
| [SOUL](https://github.com/theLightArchitect/SOUL) | Knowledge graph, structured memory, voice synthesis | `curl -fsSL .../SOUL/main/install.sh \| bash` |
| [QUANTUM](https://github.com/theLightArchitect/QUANTUM) | Forensic investigation, evidence analysis, hypothesis testing | `curl -fsSL .../QUANTUM/main/install.sh \| bash` |

Each server works standalone. Together they form an integrated development environment with persistent memory, security enforcement, personality, and investigation capabilities.

## License

MIT — see [LICENSE](LICENSE).

## Author

Kevin Francis Tan — [github.com/theLightArchitect](https://github.com/theLightArchitect)
