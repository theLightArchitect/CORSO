---
name: SCOUT
description: "Internal phase 1 of the C0RS0 Pack Build Cycle. Triages complexity,
  classifies domain, gathers requirements through HITL gates, and generates
  gold-standard plans. Initializes MANIFEST.yaml for pipeline state tracking.
  Invoked by /CORSO — not a standalone entry point."
user-invocable: false
version: 5.0.0
---

# /SCOUT — Plan Generation (Phase 1: Scope)

> Build Phase 1/7: SCOPE — Define the target. Every build starts here.

## Lifecycle Context

SCOUT is always first. Generates plans that the pack executes in lifecycle order.

**Always Phase 1.** Triages complexity, classifies domain, gathers requirements through interactive gates, and generates a gold-standard plan. Initializes MANIFEST.yaml for pipeline state tracking.

```
/SCOUT <spec>  ->  triage  ->  classify  ->  requirements  ->  generate  ->  approve
                     G1          G2             G2              G3          G4
                                                                     |
                                                        .corso/plans/{id}.md
                                                                     |
                                                      /HUNT .corso/plans/{id}.md
```

## Usage

```
/SCOUT Build a REST API with auth and rate limiting
/SCOUT Security audit of the authentication module
/SCOUT Research async patterns for our event pipeline
/SCOUT                                     # No spec — triggers full requirements gathering
```

---

## Protocol: 4-Gate Planning Pipeline

All HITL gates use `AskUserQuestion` for structured interaction. Every gate updates MANIFEST.yaml. Claude writes MANIFEST — hooks read it for gating decisions.

### Gate 0: Initialize

#### 0a. Resolve Storage Location

Check for SOUL vault first, fall back to local `.corso/`:

1. Check if `~/.soul/helix/corso/` exists (SOUL vault with CORSO helix)
2. **If SOUL available**: `build_root = ~/.soul/helix/corso/builds/{plan_id}/`
   - Create `~/.soul/helix/corso/builds/{plan_id}/` directory
   - Manifest: `{build_root}/manifest.yaml`
   - Plan: `{build_root}/plan.md`
   - Scratchpad: `{build_root}/scratchpad.md`
   - Active pointer: `~/.soul/helix/corso/builds/active.yaml`
3. **If SOUL unavailable**: `build_root = .corso/` (local project directory)
   - Create `.corso/`, `.corso/plans/`, `.corso/scratchpads/`, `.corso/manifests/` directories
   - Manifest: `.corso/manifests/{plan_id}.yaml`
   - Plan: `.corso/plans/{plan_id}.md`
   - Scratchpad: `.corso/scratchpads/{plan_id}.md`
   - Active pointer: `.corso/manifest.yaml`

Store the resolved `build_root` and `storage_mode` (`soul` or `local`) in MANIFEST for downstream skills.

**Active build awareness**: Read `active.yaml` and check the `active:` list. If there are already builds with `status: executing`, inform the user:
- "There are {N} active build(s): {plan_ids}. Starting a new build."
- This is informational — multiple builds can coexist in the active list. No blocking gate.

**Build isolation rule**: Each active build operates in **complete isolation** by default. Builds do not share context, coordinate phases, or read each other's manifests/scratchpads. The only exception is when the user **explicitly** requests cross-build coordination (e.g., "run these two builds together" or "this build depends on that one"). Without explicit user instruction, treat every build as if it's the only one running.

#### 0b. Check Build Queue

Before creating a new plan, check if there are queued follow-up items from previous builds:

1. Read `active.yaml` (resolved in 0a)
2. If `queue:` section exists with `status: pending` items:
   - Present the top-priority pending item to Kevin via `AskUserQuestion`:
     ```
     Question: "There's a queued follow-up from a previous build. Work on this next?"
     Header: "Queue"
     Options:
       1. "Yes, plan this" — "Use the queued spec as this SCOUT's input"
       2. "Skip, use my spec" — "Ignore the queue, plan what I asked for instead"
       3. "Show full queue" — "List all pending queue items before deciding"
     ```
   - **If "Yes"**: Use the queue item's `spec` as the SCOUT input. Set queue item `status: in_progress`.
   - **If "Skip"**: Proceed with the user-provided spec. Queue item stays `pending`.
   - **If "Show full queue"**: List all pending items, then re-ask which to work on.
3. If no queue or no pending items: proceed normally with user-provided spec.

**Queue schema** (in `active.yaml`):
```yaml
queue:
  - id: 1
    spec: "Description of what to build"
    priority: low | normal | high | critical
    tier_hint: RECON | HOTFIX | SMALL | MEDIUM | LARGE | CRITICAL
    domain: coding | security | architecture | testing | ...
    source_plan: "{plan_id that spawned this item}"
    source_context: "Why this was deferred"
    queued_at: "{ISO timestamp}"
    status: pending | in_progress | completed | cancelled
    workspace: "relative/path"
    target_paths: ["files/or/dirs/"]
```

#### 0c. Initialize Plan

1. Generate `plan_id` (adjective-verb-animal format, e.g., `keen-forging-hawk`, `swift-tumbling-falcon`)
2. Initialize manifest at resolved location (see MANIFEST Schema below)
3. Append this build to the `active:` list in `active.yaml`:
   ```yaml
   - plan_id: "{plan_id}"
     path: "{build_root}/manifest.yaml"
     status: planning
     workspace: "{target workspace or null}"
     started_at: null
   ```
4. Set MANIFEST `status: planning`
6. **Pack Voice**: Generate quips for the build (see `/CORSO` Pack Voice spec):
   - Extract animal from plan_id
   - Detect target sibling(s) from the specification (is this plan about EVA, CORSO, or SOUL?)
   - Call `mcp__C0RS0__corsoTools` `action: "speak"` to generate CORSO one-liners for: scout, fetch, sniff, guard, chase, hunt, completion, scrum, error
   - **Always generate Claude banter** (Claude is a permanent sibling): CORSO-to-Claude ribbing + Claude's dry reply + Claude's execution quip
   - If target sibling involved: call that sibling's MCP for banter exchange with CORSO
   - Store all quips in MANIFEST `pack_voice:` section

### Gate 1: Triage (HITL)

Classify complexity. Use `AskUserQuestion` to present tier options:

| Tier | Indicators | Planning Depth |
|------|-----------|---------------|
| **RECON** | Exploration, research, no code changes | Lightweight — skip Gates 2-3, minimal plan |
| **HOTFIX** | Critical bug fix, < 50 LOC, single file | Fast-path — collapse Gates 2+3, minimal plan |
| **SMALL** | Single feature, 1-3 files, known patterns | Standard — all 4 gates, compact plan |
| **MEDIUM** | Multi-file, new dependencies, async/network | Standard + mandatory security phase |
| **LARGE** | Multi-module, architecture changes, new crates | Full — all gates + deep context + SCRUM offered |
| **CRITICAL** | Emergency incident, production down | Immediate — skip to plan gen, post-hoc docs |

Auto-suggest a tier based on spec analysis, but let user override.

**Completion promise:** `GATE_1_TRIAGE_COMPLETE:{tier}`

Update MANIFEST: `gates.triage.passed: true`, `gates.triage.tier: {tier}`, `tier: {tier}`

### Gate 2: Domain & Requirements (HITL)

**Skip if:** RECON or CRITICAL tier.
**Collapse with Gate 3 if:** HOTFIX tier.

#### 2a. Classify Domain

Classify the request into one or more domains using keyword signals, ordered by build cycle:

| Domain Signal | Build Phase | Skill Module | `corsoTools` Actions |
|---------------|-----------|-------------|----------------------|
| Research keywords | 2. research | FETCH | `fetch` |
| Code/architecture | 3. lint | SNIFF | `code_review` |
| Security/vuln | 4. audit | GUARD | `guard` |
| Testing/perf/ops | 5. test | CHASE | `chase` |

Multi-domain requests generate plans with phases in lifecycle order: FETCH (research) -> SNIFF (lint) -> GUARD (audit) -> CHASE (test).

#### 2b. Gather Requirements

Use `AskUserQuestion` to gather context. Questions adapt to classified domain(s):

**General (always):**
- **Objective**: What are you trying to accomplish?
- **Scope**: Which project, modules, or systems are involved?

**Domain-specific additions:**
- **+ SNIFF (coding/arch)**: Language, framework, dependencies? Performance targets? Existing codebase patterns?
- **+ GUARD (security)**: What systems/code to audit? Compliance requirements (OWASP, SOC2)? Known concerns?
- **+ FETCH (research)**: What question needs answering? Decision criteria? Depth: quick overview or deep dive?
- **+ CHASE (testing/ops)**: Coverage gaps? Test types? Performance targets/constraints?

Present synthesized spec to user for confirmation via `AskUserQuestion`.

**Completion promise:** `GATE_2_REQUIREMENTS_COMPLETE`

Update MANIFEST: `gates.requirements.passed: true`

### Gate 3: Context Assembly (HITL)

**Skip if:** RECON or CRITICAL tier.
**Collapsed into Gate 2 if:** HOTFIX tier.

1. Load relevant domain module(s) via `mcp__C0RS0__corsoTools` with `action: "read_file"`
2. Read existing codebase context as needed via `mcp__C0RS0__corsoTools` with `action: "fetch"`
3. Present context summary to user via `AskUserQuestion`:
   - Domain module(s) loaded
   - Codebase files identified
   - Dependencies and risk indicators
   - Options: **Looks good** / **Add to scope** / **Remove from scope**

**Completion promise:** `GATE_3_CONTEXT_COMPLETE`

Update MANIFEST: `gates.context.passed: true`

### Phase 3: Generate Plan

1. Call `mcp__C0RS0__corsoTools` with `action: "sniff"` and the specification + assembled context
2. Structure plan with gold standard elements (see below)
3. Save plan to `.corso/plans/{plan_id}.md`
4. Create scratchpad at `.corso/scratchpads/{plan_id}.md`

### Gate 4: Plan Approval (HITL)

Present plan summary via `AskUserQuestion`:
- Tier and domain classification
- Phase count and names
- MCP tool assignments per phase
- Risk assessment

Options:
- **Approve** -> proceed to next steps
- **Revise** -> loop back to Phase 3 (re-generate plan, NOT back to requirements)
- **Abort** -> set MANIFEST `status: aborted`

**On approval:**

Update MANIFEST:
```yaml
status: approved
gates.plan.passed: true
compliance:
  approved_by: "user"
  approved_at: "{ISO timestamp}"
  rollback_checksum: "{sha256 of plan file}"
```

**Completion promise:** `GATE_4_PLAN_APPROVED`

### Optional: SCRUM Offer

After Gate 4, check if SOUL MCP plugin is available (`mcp__SOUL__soulTools`):

- **If available:** Offer squad review: "Squad review available — run `/SCRUM .corso/plans/{plan_id}.md` to get EVA and CORSO's perspectives."
- **If not available:** Skip silently.

SCRUM is **optional for all tiers** — offered, never forced.

Update MANIFEST: `gates.scrum.skipped: true` (if not run)

### Final Output

**Completion promise:** `ALL_GATES_PASSED`

Present next step:
```
Execute with: /HUNT .corso/plans/{plan_id}.md
Trust mode:   /HUNT --trust .corso/plans/{plan_id}.md
```

---

## Quality Gates

### Plan Acceptance Criteria
- [ ] Has YAML frontmatter with all required fields including `tier`
- [ ] Has domain classification
- [ ] Has phases appropriate to the domain
- [ ] Has risk assessment with severity ratings
- [ ] Has checkboxed acceptance criteria per phase
- [ ] Has MCP tool assignments per phase
- [ ] Has domain module assignment per phase
- [ ] Security phase present when tier >= MEDIUM
- [ ] Dependency graph is acyclic (no circular deps)
- [ ] Intra-phase task dependencies are acyclic (when present)
- [ ] Task wave assignments are consistent with task dependencies (when present)
- [ ] MANIFEST.yaml initialized with all gates recorded

---

## Tier Fast-Paths

| Tier | Gate 1 | Gate 2 | Gate 3 | Gen | Gate 4 |
|------|--------|--------|--------|-----|--------|
| RECON | Yes | Skip | Skip | Minimal | Yes |
| HOTFIX | Yes | Collapsed with G3 | Collapsed with G2 | Minimal | Yes |
| SMALL | Yes | Yes | Yes | Standard | Yes |
| MEDIUM | Yes | Yes | Yes | Standard + security | Yes |
| LARGE | Yes | Yes | Yes | Full | Yes + SCRUM offered |
| CRITICAL | Yes | Skip | Skip | Immediate | Yes |

---

## Plan Gold Standard

### Required Elements

| Element | Description |
|---------|-------------|
| YAML frontmatter | `plan_id`, `created`, `specification`, `validated`, `domain`, `risk_level`, `tier` |
| Phase structure | Ordered phases appropriate to the domain |
| MCP tool assignments | Each phase maps to primary MCP tools |
| Domain module | Each phase maps to the domain module providing context |
| Acceptance criteria | Each phase has checkboxed criteria |
| Risk assessment | HIGH / MEDIUM / LOW with indicators |
| Dependency graph | `depends_on` chains between phases |
| Task decomposition | Optional intra-phase sub-task waves (tier >= MEDIUM) |
| Security phase | Mandatory when tier >= MEDIUM |

### Plan Frontmatter Format

```yaml
---
plan_id: {generated-id}
created: {ISO timestamp}
specification: {original request}
validated: true
domain: {coding | security | research | infrastructure | performance | mixed}
risk_level: {HIGH | MEDIUM | LOW}
tier: {RECON | HOTFIX | SMALL | MEDIUM | LARGE | CRITICAL}
phases: {count}
---
```

### Intra-Phase Task Decomposition

For tiers **MEDIUM and above**, SCOUT analyzes each phase for parallelizable sub-tasks. Optional for SMALL tier. Skipped for RECON, HOTFIX, and CRITICAL.

Standard SCOUT plans only parallelize *across* phases (inter-phase waves handled by HUNT Step 3). Intra-phase task decomposition goes one level deeper — decomposing individual phases into dependency-ordered waves so HUNT can spawn parallel agents for independent tasks *within the same phase*.

**When to decompose a phase:**
- Phase contains >= 3 discrete, identifiable work units (type definitions, module implementations, handler functions, test suites, etc.)
- Sub-tasks have a clear dependency structure (some independent, some sequential)
- Phase spans multiple files or modules that don't share mutable state during the same wave

**When NOT to decompose:**
- Phase is inherently sequential (e.g., single-threaded research, linear refactoring)
- Phase has < 3 sub-tasks (agent-spawn overhead exceeds parallelism benefit)
- All sub-tasks depend on each other linearly (no parallelism possible)
- Tier is RECON, HOTFIX, or CRITICAL (fast-path, decomposition adds latency)

#### Task Format

Each decomposed phase includes a `### Tasks` subsection with wave-grouped tasks:

```markdown
## Phase 2: Core Types & Middleware
- **Tools**: corsoTools action: sniff
- **Domain module**: SNIFF
- **depends_on**: [1]
- **Acceptance criteria**:
  - [ ] All types compile with required trait impls
  - [ ] Middleware validates tokens and returns proper status codes
  - [ ] Integration wiring passes e2e test

### Tasks

| Task | Name | Wave | Depends On | Criteria |
|------|------|------|------------|----------|
| 2.1 | Define UserAuth type | 1 | — | Type compiles, implements Serialize/Deserialize |
| 2.2 | Define SessionToken type | 1 | — | Type compiles, has validation methods |
| 2.3 | Define RateLimitConfig type | 1 | — | Type compiles, has sensible defaults |
| 2.4 | Implement auth middleware | 2 | 2.1, 2.2 | Middleware validates tokens, returns 401 on failure |
| 2.5 | Implement rate limiter | 2 | 2.3 | Limiter tracks requests per window, returns 429 |
| 2.6 | Integration wiring | 3 | 2.4, 2.5 | All middleware registered in router, e2e test passes |
```

In this example, HUNT spawns 3 agents in Wave 1 (types), then 2 agents in Wave 2 (middleware), then 1 agent in Wave 3 (wiring) — all within a single phase.

#### Task ID Convention

Task IDs use `{phase_number}.{task_number}` format (e.g., `2.1`, `2.2`, `3.1`). This namespaces tasks under their parent phase and avoids collision with phase-level IDs.

#### Wave Assignment Rules

1. **Independence**: Tasks with no intra-phase dependencies share the same wave
2. **Dependency depth**: Task wave = max(dependency waves) + 1
3. **File conflicts**: Tasks modifying the same file must be in different waves
4. **Max agents per wave**: 4 (system constraint, Builders Cookbook S21.3)
5. **Wave ordering**: Waves within a phase execute sequentially; tasks within a wave run in parallel

#### Decomposition Heuristics

| Code Pattern | Task Decomposition |
|-------------|-------------------|
| Multiple type/struct definitions | One task per type (Wave 1) |
| Multiple trait implementations | One task per impl, depends on type tasks (Wave 2) |
| Multiple handler/endpoint functions | One task per handler, independent wave |
| Multiple test suites | One task per suite, independent wave |
| Module scaffolding + implementation | Scaffold tasks (Wave 1), implementation tasks (Wave 2) |
| Config + consumers | Config task (Wave 1), consumer tasks in parallel (Wave 2) |
| Crate setup + module files | Crate skeleton (Wave 1), module implementations (Wave 2) |

#### Two-Level Parallelism Overview

```
Phase Wave 1: [Phase 1, Phase 2]          — inter-phase parallelism (HUNT Step 3)
  Phase 1, Task Wave 1: [1.1, 1.2]        — intra-phase parallelism
  Phase 1, Task Wave 2: [1.3]             — depends on 1.1, 1.2
  Phase 2, Task Wave 1: [2.1, 2.2, 2.3]   — intra-phase parallelism
  Phase 2, Task Wave 2: [2.4, 2.5]        — depends on 2.1-2.3
Phase Wave 2: [Phase 3]                   — depends on Phases 1, 2
  Phase 3: (no task decomposition)         — executes as single unit
```

Phases WITHOUT a `### Tasks` section execute as a single unit (current behavior, fully backward compatible).

---

## Domain-Specific Phase Templates

Phase structure adapts to the domain. These are templates — plans can add custom phases as needed. Templates are ordered by build cycle.

### Research (FETCH)

| Phase | `corsoTools` Actions | Skill Module |
|-------|----------------------|--------------|
| Scope Definition | `fetch` | FETCH |
| Codebase Analysis | `fetch`, `code_review` | FETCH |
| External Research | `fetch` | FETCH |
| Comparative Analysis | `fetch` | FETCH |
| Findings & Recommendations | `sniff` | SNIFF |

*Findings generation uses `corsoTools` action: `sniff` via HUNT execution. SNIFF provides coding standards context.*

*Next phase: SNIFF (if code review follows research)*

### Coding

| Phase | `corsoTools` Actions | Skill Module |
|-------|----------------------|--------------|
| Research (if needed) | `fetch` | FETCH |
| Foundation | `sniff` | SNIFF |
| Core Logic | `sniff` | SNIFF |
| Integration | `sniff` | SNIFF |
| Security Scan | `guard` | GUARD |
| Testing | `chase` | CHASE |

*Code generation phases use `corsoTools` action: `sniff` via HUNT execution. SNIFF provides coding standards context.*

### Security Audit (GUARD/audit)

| Phase | `corsoTools` Actions | Skill Module |
|-------|----------------------|--------------|
| Scope & Threat Model | `fetch` | FETCH |
| Static Analysis | `guard` | GUARD |
| Dependency Audit | `guard` | GUARD |
| Secrets Scan | `guard` | GUARD |
| Findings Report | `fetch` | FETCH |
| Remediation Plan | `sniff` | SNIFF |

*Remediation uses `corsoTools` action: `sniff` via HUNT execution. SNIFF provides coding standards context.*

### Infrastructure (CHASE)

| Phase | `corsoTools` Actions | Skill Module |
|-------|----------------------|--------------|
| Requirements Analysis | `fetch` | FETCH |
| Infrastructure Design | `sniff` | SNIFF |
| Configuration (IaC) | `sniff` | SNIFF |
| Security Review | `guard` | GUARD |
| Deployment Testing | `chase` | CHASE |

*Design/config phases use `corsoTools` action: `sniff` via HUNT execution. SNIFF provides coding standards context.*

### Performance (CHASE)

| Phase | `corsoTools` Actions | Skill Module |
|-------|----------------------|--------------|
| Baseline Measurement | `chase` | CHASE |
| Bottleneck Analysis | `fetch`, `chase` | CHASE |
| Optimization Implementation | `sniff` | SNIFF |
| Regression Testing | `chase` | CHASE |
| Benchmark Comparison | `chase` | CHASE |

*Optimization uses `corsoTools` action: `sniff` via HUNT execution. SNIFF provides coding standards context.*

---

## Risk Assessment

| Severity | Indicators | Action |
|----------|-----------|--------|
| HIGH | `unsafe`, FFI, `extern`, secrets handling, auth changes | Mandatory security phase, extra testing |
| MEDIUM | `async`, external deps, network, file I/O, new dependencies | Standard testing, error path coverage |
| LOW | Tested frameworks, standard patterns, documentation-only | Normal quality gates |

---

## MANIFEST.yaml Schema

Claude writes one manifest per plan. Hooks read it for gating decisions.

**Storage resolves at Gate 0a.** SOUL vault first, `.corso/` fallback.

| Mode | Build Root | Active Pointer |
|------|-----------|----------------|
| `soul` | `~/.soul/helix/corso/builds/{plan_id}/` | `~/.soul/helix/corso/builds/active.yaml` |
| `local` | `.corso/` (per-project) | `.corso/manifest.yaml` |

**SOUL mode** — one directory per plan, all artifacts together:
```
~/.soul/helix/corso/builds/
├── active.yaml                    # Tracks active builds, completed archive, and queue
├── keen-forging-hawk/
│   ├── manifest.yaml
│   ├── plan.md
│   └── scratchpad.md
└── swift-tumbling-falcon/
    ├── manifest.yaml
    ├── plan.md
    └── scratchpad.md
```

**Local mode** — `.corso/` fallback (when SOUL unavailable):
```
.corso/
├── manifest.yaml                  # Points to active plan
├── manifests/{plan_id}.yaml
├── plans/{plan_id}.md
└── scratchpads/{plan_id}.md
```

Active pointer format (`active.yaml` in SOUL mode, `.corso/manifest.yaml` in local mode):

```yaml
# active: list of in-flight builds (supports parallel execution)
active:
  - plan_id: "{plan_id}"
    path: "{resolved manifest path}"
    status: planning | approved | executing | completed | aborted
    workspace: "{target workspace or null}"
    started_at: "{ISO timestamp or null}"

# completed: archive of finished builds (most recent first)
completed:
  - plan_id: "{plan_id}"
    path: "{resolved manifest path}"
    status: completed
    workspace: "{target workspace}"
    started_at: "{ISO timestamp}"
    completed_at: "{ISO timestamp}"

# queue: follow-up work spawned by completed builds (see Gate 0b)
queue: []
```

**Concurrent build support**: Multiple entries in `active:` can coexist simultaneously. SCOUT appends new entries; HUNT updates the matching entry's status. Completed builds are moved from `active:` to `completed:` by HUNT Step 7.

**Isolation by default**: Each build operates independently — no shared context, no cross-build coordination, no reading other builds' manifests or scratchpads. Builds only coordinate when the user **explicitly** requests it. This prevents accidental interference between unrelated builds targeting different workspaces or domains.

### Per-Plan Manifest Format

```yaml
schema_version: "1.0"
plan_id: "{id}"
storage:
  mode: soul | local                    # Resolved by Gate 0a
  build_root: "{resolved path}"         # ~/.soul/helix/corso/builds/{id}/ or .corso/
  plan_path: "{build_root}/plan.md"     # soul mode: single dir per plan
  scratchpad_path: "{build_root}/scratchpad.md"
  manifest_path: "{build_root}/manifest.yaml"
  active_pointer: "{pointer path}"      # ~/.soul/helix/corso/builds/active.yaml or .corso/manifest.yaml
status: planning | approved | executing | completed | aborted
tier: RECON | HOTFIX | SMALL | MEDIUM | LARGE | CRITICAL
created: "{ISO timestamp}"
updated: "{ISO timestamp}"

compliance:
  approved_by: null
  approved_at: null
  rollback_checksum: null

gates:
  triage: { passed: false, at: null, tier: null }
  requirements: { passed: false, at: null }
  context: { passed: false, at: null }
  plan: { passed: false, at: null }
  scrum: { passed: false, skipped: false }

phases: []
# Each: { id, name, status, wave, completed_at, tools_used, criteria_met, criteria_total, depends_on }
# Optional per-phase (intra-phase decomposition):
#   tasks: [{ id: "N.M", name, wave, status, depends_on: [], completed_at, criteria }]
#   task_waves: N  (total intra-phase waves for this phase)

decomposition:
  strategy: null          # parallel | sequential | single-phase
  waves: []               # [{wave: 1, phases: [1, 2], agents: 2, estimated_minutes: 60}, ...]
  approved_at: null

timing:
  started_at: null
  estimated_completion: null
  actual_completion: null
  sla_target_hours: 24

metrics:
  parallel_efficiency: null    # wall_clock / sum_agent_time (lower = better parallelization)
  phase_accuracy: null         # avg % variance from time estimates
  overrun_count: 0             # phases exceeding 150% of budget

feedback:
  l1_retries: 0
  l2_security_loops: 0

abort:
  triggered: false
  reason: null
  at: null

helix:
  entry_path: null          # SOUL vault path, set by HUNT Step 8
  enriched: false           # Set true by SCRUM Step 6
  significance: null        # Computed from tier by HUNT
  strands: []               # Computed from domain by HUNT
  skipped: false            # True if SOUL MCP unavailable
  skip_reason: null         # Reason helix was skipped

pack_voice:
  animal: null              # Extracted from plan_id (e.g., "hawk")
  target_siblings: []       # Siblings this plan touches (e.g., ["eva"])
  quips:
    scout: null             # Plan spotted — printed after Gate 4
    fetch: null             # Research begins — printed when FETCH loads
    sniff: null             # Code analysis — printed when SNIFF loads
    guard: null             # Security sweep — printed when GUARD loads
    chase: null             # Testing/perf — printed when CHASE loads
    hunt: null              # Execution starts — printed at HUNT Step 4
    completion: null        # Victory — printed after HUNT Step 7
    scrum: null             # Retrospective — printed before SCRUM Step 3
    error: null             # Something went wrong — printed on L1 failure or abort
  claude_quip: null         # Claude's dry engineer one-liner — printed at execution start
  sibling_banter:
    corso_to_claude: null   # Always present — Claude is a permanent sibling
    claude_reply: null      # Always present — Claude's dry reply to CORSO
    # corso_to_eva: null    # Only if EVA is a target sibling
    # eva_reply: null       # Only if EVA is a target sibling
```

---

## Completion Promises

| Promise | Meaning |
|---------|---------|
| `GATE_1_TRIAGE_COMPLETE:{tier}` | Triage gate passed with selected tier |
| `GATE_2_REQUIREMENTS_COMPLETE` | Requirements gathered and confirmed |
| `GATE_3_CONTEXT_COMPLETE` | Context assembled and approved |
| `GATE_4_PLAN_APPROVED` | Plan approved, ready for execution |
| `ALL_GATES_PASSED` | All planning gates complete |
| `BLOCKED:{reason}` | Pipeline blocked, needs intervention |
| `ABORTED:{reason}` | Pipeline terminated by user |

---

## Cross-Domain Context

| Lifecycle Phase | Skill | Feeds Into |
|----------------|-------|------------|
| 2. research | FETCH | SNIFF (code analysis with research context) |
| 3. lint | SNIFF | GUARD (security scan on detected patterns) |
| 4. audit | GUARD | CHASE (verify fixes pass tests) |
| 5. test | CHASE | HUNT (execute with confidence) |
