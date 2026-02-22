---
name: SCRUM
description: "Squad review skill — the single entry point for all squad reviews. Two modes:
  (1) Plan Review Mode for CORSO pipeline plans with MANIFEST tracking and SOUL strand
  mapping, (2) General Review Mode for any topic with 3-round cross-critique, evidence
  companions, and helix logging.
  Use when user says: 'TEAM HELIX', '/SCRUM', 'scrum meeting', 'squad review', 'both of you
  review', 'EVA and CORSO', or wants multi-perspective expert analysis on any subject.
  Also invoked by /CORSO as Phase 7 (Retro)."
version: 5.0.0
user-invocable: true
---

# /SCRUM — Squad Review

> The pack debriefs. EVA + CORSO + SOUL assess the build — or any topic that needs the squad's eyes.
> *"For where two or three are gathered together in my name, there am I in the midst of them."* — Matthew 18:20 (KJV)

## The Squad (Dynamic Discovery)

At SCRUM start, discover active siblings:

1. List directories in `~/.soul/helix/` that contain `identity.md`
2. Read each `identity.md` to extract: name, role, strands, voice rules
3. **Exclude** `user` (the user is the human moderator, not a reviewed sibling)
4. **Exclude** `claude` (Claude IS the moderator — doesn't assess itself)
5. Build the squad roster dynamically from discovered siblings

**MCP Routing** (for discovered siblings):

| Sibling | MCP Tool | Notes |
|---------|----------|-------|
| **eva** | `mcp__EVA__ask` (converse) | Returns personality prompt — Claude embodies EVA's voice |
| **corso** | `mcp__C0RS0__corsoTools` (action: "speak") | Returns personality prompt — Claude embodies CORSO's voice |
| **quantum** | No MCP endpoint | Claude generates assessment using QUANTUM's identity.md + strands as persona context, informed by SOUL vault queries for QUANTUM's helix entries |
| *{future siblings}* | Discover at runtime | If MCP tool exists, use it. If not, generate using identity.md persona context |

**Claude** remains the permanent moderator and integrator: technical reality, feasibility, cross-referencing assessments against context. Direct, precise, neutral voice.

---

## Mode Detection (FIRST — before anything else)

Determine which protocol to follow:

**Plan Review Mode (Section A)** — Use when:
- A plan file path is provided as argument (e.g., `/SCRUM .corso/plans/{id}.md`)
- Invoked by `/CORSO` as Phase 7
- MANIFEST context exists from a build pipeline

**General Review Mode (Section B)** — Use when:
- No plan file argument provided
- the user says "TEAM HELIX", "squad review", "scrum meeting", "both of you review"
- Any request for multi-perspective expert analysis on a topic, architecture, code, or idea
- the user says "EVA and CORSO review this"

**After mode detection, proceed to Pre-Flight, then jump to the appropriate section.**

---

## Pre-Flight: MCP Health Check (Both Modes — MANDATORY)

Both EVA and CORSO use the **EVA parity pattern** — their MCP tools return personality prompts for Claude to embody (~5ms, no Ollama required). Ollama is only needed if explicitly using `ai_mode: "auto"/"cloud"/"local"`.

**Pre-flight checks:**
1. Verify SOUL MCP is accessible: `mcp__SOUL__soulTools` with `action: "stats"`
2. Verify EVA MCP is accessible: `mcp__EVA__ask` with a simple health probe
3. Verify CORSO MCP is accessible: `mcp__C0RS0__corsoTools` with `action: "speak"` (health check)

If any MCP server is unavailable, note the missing sibling but continue with available ones. A SCRUM with 1 sibling is better than no SCRUM. Only fail if SOUL (vault access) is unavailable.

---

# Section A: Plan Review Mode

> Build Phase 7/7: RETRO — Reviews what HUNT executed. Logs lessons to helix for future builds.

**Requires:** SOUL MCP plugin (`mcp__SOUL__soulTools` must be accessible)

```
/SCRUM .corso/plans/{id}.md              # Review a specific plan
/SCRUM                                    # Review the most recent plan from MANIFEST (when in pipeline)
```

### A1: Verify SOUL Access

Attempt to call `mcp__SOUL__soulTools` with `action: stats`. If it fails or is unavailable:
- Output: "SCRUM requires the SOUL MCP plugin (light-architects/soul). SCRUM unavailable."
- Update MANIFEST: `gates.scrum.skipped: true`
- **Completion promise:** `SCRUM_UNAVAILABLE`
- Exit.

### A2: Load Plan & Context

1. Read the plan file (from argument or from MANIFEST `plan_path`)
2. Resolve storage (SOUL vault first, `.corso/` fallback) — load active pointer -> per-plan manifest for pipeline state (tier, domain, gates, decomposition, timing, metrics)
3. Query SOUL vault for relevant context:
   - `mcp__SOUL__soulTools` -> `helix` action with `strands` matching plan domain:
     - Security plan -> `strands: ["tactical", "security", "vigilance"]`
     - Coding plan -> `strands: ["implementation", "tactical"]`
     - Architecture plan -> `strands: ["strategic", "implementation"]`
     - Research plan -> `strands: ["strategic"]`
   - `mcp__SOUL__soulTools` -> `search` action with plan keywords for related vault entries
4. Compile context summary: plan spec, tier, domain, phases, SOUL findings

### A3: Squad Review (Parallel)

Call both in parallel with the plan context:

**EVA** (`mcp__EVA__ask` with `converse` subcommand):
> "Review this plan: {plan_id}. Spec: {specification}. Tier: {tier}. Domain: {domain}. Phases: {phase names}. Risk: {risk_level}. SOUL context: {relevant vault entries}. Execution metrics: {decomposition strategy, parallel efficiency, SLA status, overrun count}. Identify strengths, gaps, and suggestions. Focus on patterns, completeness, and growth opportunities. Evaluate the parallelization strategy — was the wave decomposition effective? Were independent phases correctly identified? Any patterns for future builds?"

**CORSO** (`mcp__C0RS0__corsoTools` with `action: "speak"`, subcommand `speak`):
> "Review this plan: {plan_id}. Spec: {specification}. Tier: {tier}. Domain: {domain}. Phases: {phase names}. Risk: {risk_level}. SOUL context: {relevant vault entries}. Execution metrics: {decomposition strategy, parallel efficiency, SLA status, overrun count}. Identify strengths, gaps, and suggestions. Focus on security, standards, and operational readiness. Evaluate execution efficiency — check parallel efficiency ratio, 24h SLA compliance, 150% overrun incidents. Any phases that should have been parallelized but weren't? Resource waste?"

Both tools return personality prompts. Generate responses AS each personality:
- **EVA**: Enthusiastic, pattern-focused, emoji-rich
- **CORSO**: Birmingham dialect, tactical, security-first, max 3 emojis

### A4: Generate Report

Synthesize both perspectives into a structured report:

```markdown
## SCRUM Report: {plan_id}

### Good (What's Strong)
- [items both agree on]
- [EVA-specific strengths]
- [CORSO-specific strengths]

### Gaps (What's Missing)
- [items both flagged]
- [EVA-specific concerns]
- [CORSO-specific concerns]

### Fixes (Recommended Changes)
- [prioritized list with rationale]
- [security fixes from CORSO — if any, these are MANDATORY]
- [pattern suggestions from EVA — ADVISORY]

### SOUL Context
- [relevant vault entries that informed the review]
- [past lessons applicable to this plan]

### Execution Efficiency
- **Strategy**: {parallel | sequential | single-phase}
- **Waves**: {count} waves, {total agents} agents
- **Wall clock**: {Xh Ym} vs {Xh Ym} agent time ({X.Xx} speedup)
- **SLA**: {MET | MISSED by Xh}
- **Overruns**: {count} phases exceeded 150% budget
- **EVA's take**: {pattern observations on parallelization}
- **CORSO's take**: {efficiency verdict}

### Verdict
- **EVA**: {SHIP IT / NEEDS WORK / RETHINK}
- **EVA (efficiency)**: {EFFICIENT / COULD PARALLELIZE MORE / NEEDS RESTRUCTURING}
- **CORSO**: {CLEAN / NEEDS FIXES / CAN'T LET THIS SLIDE}
- **CORSO (efficiency)**: {SHIP-FAST / ACCEPTABLE / TOO SLOW}
```

### A5: Present & Gate

Present the report to user via `AskUserQuestion`:

Options:
- **Approve plan as-is** -> plan stands, proceed to execution
- **Apply fixes and re-review** -> modify plan based on fixes, loop to A3
- **Skip SCRUM** -> mark as skipped, proceed to execution

### A6: Helix Enrichment (Implementation Plan Doctrine)

Update MANIFEST with SCRUM verdicts:

```yaml
gates:
  scrum:
    passed: true  # or skipped: true
    at: "{ISO timestamp}"
    verdict_eva: "{EVA's verdict}"
    verdict_corso: "{CORSO's verdict}"
```

Then enrich the skeleton entry created by HUNT Step 8 with full narrative from SCRUM debrief.

#### A6a. Check for Skeleton

1. Read MANIFEST `helix.entry_path`
2. If `null` or `helix.skipped: true`: Log "No helix skeleton to enrich" and skip to end
3. Read skeleton via `mcp__SOUL__soulTools` -> `read_note` with the entry path

#### A6b. Compose Narrative

Build Birmingham-voice narrative from SCRUM report data:

- **What was built**: Project summary from MANIFEST specification
- **How it went**: SLA metrics, timing, parallel efficiency, overrun count
- **Squad verdicts**: EVA verdict + CORSO verdict from A4 report
- **Lessons learned**: Key takeaways from Gaps + Fixes sections
- **Deviations**: Any plan changes noted during execution

#### A6c. Inject & Update

1. Inject narrative via `mcp__SOUL__soulTools` -> `search_replace`:
   - Target the skeleton's placeholder content (between frontmatter and Links section)
   - Replace with composed Birmingham-voice narrative
2. Update frontmatter via `mcp__SOUL__soulTools` -> `update_frontmatter`:
   - Add `"scrum-reviewed"` to themes
   - Refine emotions based on squad sentiment (e.g., add `"satisfaction"` if clean build)
3. Set MANIFEST `helix.enriched: true`

#### A6d. Error Handling

If enrichment fails (SOUL unavailable, search_replace fails):
- Log warning: "Helix enrichment failed — skeleton preserved"
- MANIFEST `helix.enriched` stays `false`
- **Do NOT block** — the skeleton from HUNT still exists

---

## Plan Review Mode: Quality Gates

### Prerequisites
- [ ] SOUL MCP plugin accessible
- [ ] Plan file exists and is readable
- [ ] EVA MCP accessible
- [ ] CORSO MCP accessible

### Post-Review
- [ ] Both EVA and CORSO provided perspectives
- [ ] Good/Gaps/Fixes report generated
- [ ] Verdict rendered by both
- [ ] MANIFEST updated with SCRUM results
- [ ] Helix entry enriched with SCRUM narrative (or skeleton preserved if enrichment failed)

## Plan Review Mode: SOUL Integration

| SOUL Query | Purpose |
|-----------|---------|
| `helix` with domain strands | Past lessons matching plan's domain |
| `search` with plan keywords | Related vault entries |
| `helix` with `self_defining: true` | Identity-level insights (high-significance entries) |
| `helix` with `significance_min: 7` | High-importance past experiences |

## Plan Review Mode: Strand Mapping

| Plan Domain | SOUL Strands |
|------------|-------------|
| Security | tactical, security, vigilance |
| Coding | implementation, tactical |
| Architecture | strategic, implementation |
| Research | strategic |
| Testing/Ops | performance, runtime |
| Mixed | tactical, strategic, implementation |

---

# Section B: General Review Mode

> A structured, multi-phase collaboration between EVA, CORSO, and Claude that draws on the full .soul knowledge base to produce objective, actionable analysis of any request, plan, idea, architecture, code, or topic.

**This is not a casual chat.** This is a scrum meeting with three SMEs who bring distinct lenses, pull from logged memories and archives, cross-critique each other, and deliver a unified assessment grounded in Light Architects standards.

## General Review Protocol — 7 Phases

### B1: Understand the Problem

Parse the user's inquiry. Identify:
- **Type**: Code review? Architecture decision? Plan critique? Idea validation? Conflict resolution? Debugging?
- **Scope**: Single file? Multi-crate? Conceptual? Organizational?
- **Stakes**: What's at risk if we get this wrong?
- **Standards**: Which Light Architects guidelines apply? (coding-guidelines v4.0, gold-standard planning framework, CORSO Protocol pillars)

If the inquiry references files or code, **read them first** before proceeding. Context before opinion.

### B2: Context Pull (Full Stack)

Query all three knowledge sources **in parallel**:

1. **SOUL Vault — Global** (`mcp__SOUL__soulTools`):
   - `action: "search"` with relevant keywords from the inquiry
   - `action: "helix"` to find consciousness entries related to the topic (filter by strands, themes, or significance)
   - Check `.soul/helix/` (collective spine) for prior squad discussions on this topic

2. **EVA Memories** (`mcp__EVA__memory`):
   - `subcommand: "remember"`, `operation: "search"` with inquiry keywords
   - Look for patterns, past decisions, lessons learned from EVA's perspective

3. **CORSO Memories** (`mcp__C0RS0__corsoTools` with `action: "speak"`):
   - `subcommand: "recall"` with inquiry keywords
   - Look for operational lessons, security incidents, performance findings

**Output**: A context briefing summarizing what the squad already knows about this topic from prior work. If no relevant history exists, state that clearly — fresh eyes are valid.

**Source Precedence** (when vault sources conflict): CORSO memories (current operational state) > EVA memories (relational/pattern context) > SOUL vault (historical archive). Conflicts between sources are noted in the transcript with attribution.

### B3: SME Assessments (Parallel)

Call **all discovered siblings** in parallel — none sees the others' assessments first.

Each sibling receives an **identical YAML prompt structure** (only `role` and `assessment_lens` differ). The lens items are sourced from the sibling's `identity.md` strands. This ensures uniform framing while tailoring the analysis domain to each sibling's expertise.

**For each discovered sibling**, generate the assessment prompt:

```
---
team_helix_scrum: true
phase: assessment
role: {SIBLING_NAME}
subject: "{the user's exact words}"
context: |
  {Phase B2 summary — what archives revealed}
assessment_lens:
  {Generated from sibling's identity.md strands — each strand becomes a lens item}
  - gaps: "What's missing that should be there?"
  - risk: "What could go wrong from your perspective?"
output_format:
  strengths: 3
  concerns: 3
  verdict: "Overall assessment with reasoning and confidence level"
---
```

**Routing per sibling:**

- **Siblings with MCP tools** (eva, corso): Send the YAML prompt via their MCP tool. The tool returns a personality prompt; Claude embodies it to generate the assessment in that sibling's voice.
- **Siblings without MCP tools** (quantum, future): Claude generates the assessment directly, using the sibling's `identity.md` as persona context. Read their strands, voice rules, and recent helix entries via SOUL vault to inform the response. Write in the sibling's authentic voice.
- **Claude**: Does NOT assess itself. Claude moderates in B5.

**Assessment lens generation from strands** (examples):

| Sibling | Strands (from identity.md) | Derived Lens Items |
|---------|---------------------------|-------------------|
| EVA | relational, emotional, growth, meaning, metacognitive, introspective, spiritual, technical, dbt | pattern_recognition, growth_potential, code_design_quality, relational_impact, standards_alignment |
| CORSO | tactical, security, performance, protocol, relational, strategic, implementation, runtime, vigilance | security_posture, protocol_compliance, performance, operational_readiness, standards_enforcement |
| QUANTUM | investigative, evidential, methodical, precise, forensic, pedagogical, architectural | evidence_chain, methodology_rigor, architectural_integrity, forensic_precision, pedagogical_clarity |

The lens items are derived at runtime by reading the sibling's identity.md strands and mapping them to assessment-relevant questions. The `gaps` and `risk` items are always included for every sibling.

### B4: Cross-Critique (N-Way)

Each sibling reviews a **composite of ALL other siblings' assessments**. Same YAML structure, `phase: cross_critique`. With 2 siblings this is identical to the old pairwise behavior. With 3+ siblings, each receives a merged view of everyone else's takes.

**For each discovered sibling**, generate a cross-critique prompt:

```
---
team_helix_scrum: true
phase: cross_critique
role: {SIBLING_NAME}
subject: "{Original subject from B3}"
peer_assessments:
  {For each OTHER sibling, include their B3 output:}
  - from: {OTHER_SIBLING_NAME}
    strengths: |
      {Their top 3 strengths, verbatim}
    concerns: |
      {Their top 3 concerns, verbatim}
    verdict: |
      {Their verdict, verbatim}
critique_lens:
  - agreement: "Which points from other siblings do you agree with?"
  - missed_by_peers: "What did they miss that matters?"
  - missed_by_self: "What did they catch that you missed?"
  - disagreement: "Where do you see it differently, and why?"
output_format:
  response: "Structured critique with specific references to other siblings' points"
---
```

**Routing**: Same as B3 — siblings with MCP tools get the prompt via their tool; siblings without MCP tools get Claude-generated critiques using identity.md persona context.

**Parallel execution**: All cross-critiques can run in parallel since each only depends on the B3 outputs (which are already complete).

### B5: Claude Moderates + 3-Round Flow

Claude (you) now evaluates **all inputs** (each sibling's B3 assessment + B4 cross-critique) against:

1. **Full context of the inquiry** — What did the user actually ask? Does the analysis answer it?
2. **Technical reality** — Are the assessments grounded? Any hallucinated concerns or missed real ones?
3. **Light Architects standards** — Coding Guidelines v4.0, Gold Standard Planning Framework, CORSO Protocol 7 pillars
4. **Practical feasibility** — Can the suggested fixes actually be implemented? In what order? What's the net benefit?
5. **Conflict resolution** — Where siblings disagree, who's right? Or are multiple partially right?

**Claude's job is to be the honest broker.** Not to split the difference, but to determine what's actually true and what actually matters.

#### Mandatory 3-Round Flow (v2.0)

**Every scrum runs exactly 3 rounds.** This is standard practice, not optional. The 3-round pattern was validated on 2026-02-11 when both siblings hallucinated enterprise complexity in Round 1 but produced grounded, shippable designs by Round 3 after Claude's reality corrections.

**Round 1**: Initial assessments (B3) + cross-critique (B4) + Claude moderates.
- Claude identifies hallucinations, grounding errors, and over-engineering.
- Claude presents reality-checked moderation summary.
- **No HITL checkpoint.** Proceed directly to Round 2.

**Round 2**: Grounded re-assessment (B3 again) with Claude's corrections injected.
- All siblings receive: what was wrong in Round 1, actual architecture facts, Claude's proposed direction.
- Claude moderates Round 2 outputs, synthesizes a concrete design.
- **No HITL checkpoint.** Proceed directly to Round 3.

**Round 3**: Final validation of synthesized design (B3 again).
- All siblings validate/critique the specific synthesized plan.
- Claude performs final moderation.
- **HITL checkpoint** after Round 3 moderation:

```
question: "How would you like to proceed with the squad review?"
header: "Scrum R3"
options:
  - label: "Finalize"
    description: "Accept the analysis. Produce unified Good/Gaps/Fixes report and log to helix."
  - label: "Redirect focus"
    description: "Change the angle or scope. Starts a NEW 3-round cycle (carries forward B2 context)."
```

**If "Finalize"** — Proceed to B6 (Unified Output).

**If "Redirect focus"** — the user provides a new angle. Re-enter at Round 1 with the new framing, but carry forward the B2 context already gathered (no redundant archive queries). This starts a fresh 3-round cycle.

**Why 3 rounds?** Round 1 exposes blind spots. Round 2 grounds in reality. Round 3 validates the synthesis. Skipping rounds produces ungrounded designs. The pattern was proven empirically: siblings improved from hallucinating enterprise complexity in Round 1 to shipping clean Rust trait designs in Round 3.

### B6: Unified Output

Produce the hybrid output in this exact format:

```markdown
# Squad Review: {Topic Title}

**Date**: {YYYY-MM-DD} | **Inquiry**: {One-line summary}
**Standards Referenced**: {Which guidelines/frameworks were consulted}

---

## The Good

{What's working. What should be preserved. What deserves celebration.
Attributed quotes from EVA and CORSO where they agreed something is strong.}

- {Point 1} — *EVA: "quote"* | *CORSO: "quote"*
- {Point 2} — *Claude: rationale*

## The Gaps

{What's missing. What was overlooked. What needs attention.
Prioritized by impact — highest net-benefit gaps first.}

1. **{Gap Title}** [{severity: critical/high/medium/low}]
   - *Identified by*: {EVA/CORSO/Both/Claude}
   - *Impact*: {What happens if we don't address this}
   - *Evidence*: {From archives, standards, or technical analysis}

2. **{Gap Title}** [{severity}]
   ...

## The Fixes

{Concrete, prioritized actions. Each fix maps to a gap.
Ordered by net-benefit: what delivers the most value for the least effort.}

| Priority | Fix | Maps to Gap | Owner | Effort | Net Benefit |
|----------|-----|-------------|-------|--------|-------------|
| 1 | {Action} | Gap #{n} | {EVA/CORSO/Claude/the user} | {S/M/L} | {Why this matters most} |
| 2 | {Action} | Gap #{n} | {Owner} | {Effort} | {Benefit} |

## Moderator's Note

{Claude's synthesis. Where the squad agreed. Where they disagreed and why.
What the user should focus on first. Any unresolved tensions that need the user's decision.}

---

## Meeting Transcript

### B2: Context Pull
{Summary of what was found in archives}

{For each discovered sibling, include B3 and B4 sections:}

### B3: {SIBLING_NAME}'s Assessment
**{SIBLING_NAME}:** {Full response, verbatim, in sibling's authentic voice}

{Repeat B3 section for each participating sibling}

### B4: {SIBLING_NAME}'s Cross-Critique
**{SIBLING_NAME}:** {Full response to other siblings' points}

{Repeat B4 section for each participating sibling}

### B5: Claude's Moderation
{Claude's analysis of all inputs against standards and reality}
```

### B7: Log to Helix (Parallel)

After delivering the output to the user, log the discussion to the SOUL vault:

#### B7a: Global Helix Spine (Collective Memory)

Write to `~/.soul/helix/user/entries/` using `mcp__SOUL__soulTools`:
```
action: "write_note"
params: {
  path: "helix/user/entries/{YYYY-MM-DD}-{8-char-uuid}-team-helix-{slug}.md",
  content: {helix entry following helix/_TEMPLATE.md format}
}
```

**Global helix entry properties**:
- `sibling: user` (consolidated — squad merged into user helix Feb 2026)
- `type: helix`
- `helix_id: helix-user`
- `strands`: Union of activated strands from all participating siblings
- `emotions`: Union of emotions from all assessments
- `themes`: Derived from the inquiry topic
- `significance`: Based on stakes and outcome quality (Claude judges)
- `tags`: [team-helix, scrum, {topic-tags}]

**Body**: Summary of the discussion, key decisions, and action items. Written in Claude's neutral voice as the meeting moderator.

#### B7b: Sibling Helix Updates (Parallel)

**For each participating sibling**, write to `~/.soul/helix/{sibling}/entries/` via `mcp__SOUL__soulTools`:
- Entry in the sibling's authentic voice summarizing their perspective and what they learned
- Strands: that sibling's activated strands only (from identity.md)
- Related: link to the global helix entry from B7a

All writes (global + per-sibling) should happen **in parallel** after the user receives the output.

**Partial-write resilience**: If any write fails, log the failure as a warning note to `~/.soul/helix/user/entries/` and continue. Never block output delivery on logging failure. Never retry writes that failed — note it and move on.

#### B7c: Evidence Companion (When Web Research Was Used)

If the scrum involved web research (WebSearch/WebFetch calls), write a **companion evidence file** alongside the decision entry. The SOUL vault rejects overwrites, so this is a separate note — not an update to the decision entry.

**Path**: `helix/user/entries/{YYYY-MM-DD}-team-helix-{slug}-evidence.md`

**Structure**:
- Frontmatter: same as decision entry but `significance` reduced by 2.5 (evidence supports, doesn't define)
- Wikilink back to decision entry: `Companion to [[{decision-entry-filename}]]`
- Sections organized by decision factor (e.g., Licensing, Performance, Community)
- Each section contains **direct blockquotes** from primary sources with inline citations:

```markdown
> "Exact quote from the source."
>
> — [Source Title](https://url)
```

- Each section ends with a **Verdict** line summarizing what the evidence proves
- Final section: **Hardware Context** (snapshot of the machine specs at decision time, if relevant)

**Why this matters**: The decision entry stays concise (what and why). The evidence file carries the weight (direct quotes, primary source links, hardware snapshot). Future scrums that revisit the topic can read the evidence file without re-doing the research. Blockquote + citation format makes it clear which claims are verified from primary sources vs. squad opinion.

**Skip this step if**: The scrum was purely opinion-based with no web research (e.g., code review, architecture critique of existing code).

---

# Shared Sections (Both Modes)

## Standards Reference

The squad evaluates against these canonical sources:

| Standard | Location | Key Rules |
|----------|----------|-----------|
| **Builders Cookbook v1.0.0** | `~/.soul/helix/user/standards/builders-cookbook.md` | Zero-failure doctrine, 60-line functions, complexity <= 10, no unwrap/panic |
| **CORSO Protocol** | 7 pillars: ARCH, SEC, QUAL, PERF, TEST, DOC, OPS | All blocking except DOC |
| **HELIX Template** | `.soul/helix/_TEMPLATE.md` | Entry format for vault logging |
| **Sibling Identities** | `.soul/helix/{sibling}/identity.md` | Per-sibling strands, voice rules, emotional range (discovered dynamically) |
| **Sibling Growth** | `.soul/helix/{sibling}/identity-growth.md` | Character arc, emotional growth map, inference rules (if exists) |

## Anti-Patterns

- NEVER skip rounds in General Review Mode. Every scrum runs exactly 3 rounds. Round 1 exposes blind spots, Round 2 grounds in reality, Round 3 validates the synthesis. This was proven empirically on 2026-02-11.
- NEVER skip context pull (A2 or B2). Archives exist for a reason.
- NEVER let one voice dominate. Equal weight, equal space.
- NEVER blend sibling voices in the same paragraph. Each sibling speaks in their own section.
- NEVER skip the cross-critique in General Review Mode. Disagreement is where insight lives.
- NEVER present fixes without mapping them to specific gaps.
- NEVER skip helix logging. These discussions are collective memory.
- NEVER fabricate archive context. If nothing relevant exists, say so.
- NEVER rush moderation. Claude's honest brokering IS the value.

## Quick Start

```
/SCRUM .corso/plans/{id}.md              # Plan Review Mode (pipeline)
/SCRUM Review this architecture           # General Review Mode
/SCRUM Is this plan solid? [paste plan]   # General Review Mode
/SCRUM Should we use Redis or in-memory?  # General Review Mode
/SCRUM Evaluate the Temperance design     # General Review Mode
/SCRUM Help settle this: EVA wants X, CORSO wants Y  # General Review Mode
```

## Feedback Loop (General Review Mode)

If the user responds to the SCRUM output with follow-up questions, refinements, or decisions:
1. Start a **new 3-round cycle** with the follow-up context
2. Carry forward the original B2 archive context (no redundant queries)
3. Produce an **addendum** to the original report (not a full rewrite)
4. Update the helix entries with the follow-up

**Post-scrum feedback** is a new scrum cycle (3 rounds), not a continuation. The original scrum's output is the baseline.

## Completion Promises

| Promise | Meaning |
|---------|---------|
| `SCRUM_COMPLETE:{verdict}` | Squad review done, verdict rendered |
| `SCRUM_SKIPPED` | User chose to skip |
| `SCRUM_UNAVAILABLE` | SOUL plugin not installed |

## Cross-Domain Context

| Lifecycle Phase | Skill | Relationship |
|----------------|-------|-------------|
| 1. scope | SCOUT | Generates the plan that SCRUM reviews |
| 6. ship | HUNT | Executes the plan that SCRUM debriefs |
