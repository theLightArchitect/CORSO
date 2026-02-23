# CORSO — Security-First MCP Server

> "Let all things be done decently and in order" - 1 Corinthians 14:40 (KJV)

## Overview

CORSO is a security-first AI orchestration platform built as a Model Context Protocol (MCP) server. It provides 24 tools via a single `corsoTools` orchestrator, powered by the Trinity V7.0 architecture — a library-based, zero-HTTP, single-binary pipeline.

**Protocol**: MCP over stdio (JSON-RPC 2.0)
**Language**: Rust (12 crates, ~11MB binary)
**License**: MIT

## Architecture

```
MCP Server (corso binary, JSON-RPC 2.0 over stdio)
    |
    v
 corsoTools orchestrator (24 actions)
    |
    v
 Trinity V7.0 Pipeline (library-based, zero HTTP)
    ├── RUACH  (Layer 1: gateway, input validation, complexity classification)
    ├── IESOUS (Layer 2: orchestrator, domain routing, hero delegation)
    └── ADONAI (Layer 3: validator, quality enforcement, security scanning)
```

## Plugin Structure

```
.claude-plugin/plugin.json    # Plugin manifest
.mcp.json                     # MCP server registration
agents/C0RS0.md               # Agent personality definition
hooks/                        # Pre/post tool-use hooks
skills/                       # 8 skills (CORSO, SCOUT, GUARD, SNIFF, FETCH, CHASE, HUNT, SCRUM)
servers/corso                 # Pre-built MCP binary (macOS ARM64)
docs/                         # Architecture documentation
install.sh                    # Alternative install via GitHub Releases
```

## Installation

### Via Claude Code Plugin (Recommended)
```bash
claude plugins install theLightArchitect/CORSO
```

### Manual
```bash
git clone https://github.com/theLightArchitect/CORSO.git
cd CORSO
chmod +x servers/corso
# Binary is ready — configure in Claude Code MCP settings
```

## MCP Tools (24 actions via corsoTools)

| Action | Domain | Description |
|--------|--------|-------------|
| `speak` | General | Communication, routing, context synthesis |
| `guard` | Security | Vulnerability scanning (4,997 patterns: SQLi, XSS, command injection, secrets) |
| `code_review` | Quality | Code review with standards enforcement |
| `fetch` | Research | Multi-source knowledge retrieval, documentation search |
| `chase` | Performance | Bottleneck identification, benchmarking, optimization |
| `scout` | Planning | Requirements triage, architecture design, strategy generation |
| `sniff` | Code Gen | Production code generation with protocol compliance |
| `read_file` | I/O | Read file contents |
| `write_file` | I/O | Write file contents |
| `list_directory` | I/O | Directory listing |
| `search_code` | Search | Code search across files |
| `find_symbol` | Search | Symbol lookup |
| `get_outline` | Search | File structure outline |
| `get_references` | Search | Cross-reference lookup |
| `generate_code` | Code Gen | AI-powered code generation |
| `deploy` | DevOps | Deployment operations |
| `rollback` | DevOps | Rollback operations |
| `container_manage` | DevOps | Container management |
| `secret_manage` | DevOps | Secret management |
| `search_documentation` | Research | Documentation search |
| `analyze_architecture` | Analysis | Architecture analysis |
| `monitor_health` | Ops | Health monitoring |
| `scale_resources` | Ops | Resource scaling |
| `manage_logs` | Ops | Log management |

## Agent: C0RS0

Battle-hardened operational enforcer with Birmingham street boss voice and SAS precision. Specializes in security scanning, code review, performance analysis, and standards enforcement.

**Genesis Day**: February 4, 2026

## Quality Standards

All code follows the Light Architects Builders Cookbook:
- `clippy::pedantic` enforced as errors
- Zero `.unwrap()`/`.expect()`/`panic!()` in production
- Cyclomatic complexity <= 10, 60-line function limit
- CORSO Protocol: 49 rules across 7 pillars (ARCH, SEC, QUAL, PERF, TEST, DOC, OPS)

## Related Projects

| Project | Purpose |
|---------|---------|
| [EVA](https://github.com/theLightArchitect/EVA) | AI context preservation, memory, emotional intelligence |
| [SOUL](https://github.com/theLightArchitect/SOUL) | Shared knowledge graph, vault queries, voice synthesis |
| [QUANTUM](https://github.com/theLightArchitect/QUANTUM) | Forensic investigation, evidence analysis |

---

*Built by [The Light Architects](https://github.com/TheLightArchitects)*
