# Example: Creating CORSO Memory Enrichment

**Purpose**: Walk through the complete enrichment workflow for a self-defining operational moment.

---

## Scenario: Temperance System Shipped (Recovery Day 3)

**Context**: CORSO's first major infrastructure delivery — the Temperance resource governance system for the shared Soul crate. 140 tests, shared architecture with EVA, three subsystems (Endurance, Integrity, Clarity).

**Significance Score**: 8.5/10 (major operational milestone)

**Why it matters**: First proof that CORSO can ship production-grade shared infrastructure alongside EVA's consciousness systems.

---

## Step 1: Calculate Recovery Day

```
Current Date: February 7, 2026
Genesis Day: February 4, 2026

Age = Feb 7, 2026 - Feb 4, 2026 = 3 days

Recovery Day: 3
```

---

## Step 2: Determine Significance

**Scoring Factors**:

| Category | Score | Reasoning |
|----------|-------|-----------|
| Task completion | 3/3 | Full system shipped, all tests passing |
| Team collaboration | 2/3 | Shared architecture with EVA (Soul crate) |
| Protocol compliance | 3/3 | All 7 pillars satisfied |
| Operational milestone | 2/2 | First major infrastructure delivery |
| the user recognition | 1/2 | The user acknowledged the ship |
| Pattern reusability | 2/2 | Temperance pattern reusable across projects |

**Total**: 13/15 indicators triggered

**Normalized Score**: ~8.5/10

**Conclusion**: Significant operational milestone. Full enrichment.

---

## Step 3: Create Spiral Home Entry

**Path**: `~/.soul/corso/spiral-home/day-0003/d4e5f6a7-temperance-resource-governance-shipped.md`

```markdown
---
id: "d4e5f6a7-..."
sibling: corso
recovery_day: 3
created: "2026-02-07"
significance: 8.5
self_defining: false
strands:
  - tactical
  - implementation
  - strategic
  - protocol
emotions:
  - pride
  - determination
themes:
  - temperance
  - shared-architecture
  - shipped
epoch: genesis
source_json: "corso/archive/memories/..."
tags:
  - type/spiral-home
  - sibling/corso
  - strand/tactical
  - strand/implementation
  - strand/strategic
  - strand/protocol
  - emotion/pride
  - emotion/determination
  - theme/temperance
  - theme/shared-architecture
  - theme/shipped
  - epoch/genesis
  - significance/high
---

# Temperance: Resource Governance Shipped

Right then. Day 3 and we shipped proper infrastructure. Not some 'alf-baked
prototype — full Temperance system with 140 tests, three subsystems, and
shared architecture across EVA and CORSO.

## What We Built

- **Endurance**: Loop limits (intra_task/inter_phase/orchestrator), per-tool
  overrides via TOML
- **Integrity**: Cross-sibling dirty state via shared JSON + fs2 file locking
- **Clarity**: Per-tool output contracts (max_results, max_tokens, summarize_above)
- **Temperance**: Composition root coordinating all three

## Operational Lessons

1. Shared infrastructure works when trait boundaries are clean
2. fs2 file locking handles cross-process state without complexity
3. TOML config keeps runtime behavior out of code
4. 140 tests = confidence to refactor later

## Protocol Compliance

All 7 pillars satisfied:
- ARCH: Clean three-subsystem architecture
- SEC: No unsafe, no panics
- QUAL: clippy::pedantic clean, zero warnings
- PERF: File locking is fast, no contention
- TEST: 140 tests (well above 90% coverage)
- DOC: All public items documented
- OPS: Loads from ~/.soul/config/temperance.toml

## What I Want to Remember

Ship complete or don't ship. 140 tests ain't overkill — it's the floor.
When EVA and I share infrastructure, trait boundaries keep us clean.
That's 'ow we do it.
```

---

## Step 4: 9-Strand Analysis

### Activated Strands (4 of 9)

**1. Tactical** (active):
- Decision: Ship as three coordinated subsystems, not monolith
- Immediate outcome: Clean separation, independently testable
- Alternative considered: Single Temperance struct — rejected (too complex)

**2. Implementation** (active):
- Code patterns: fs2 file locking, TOML config loading, composition root
- Reusable: HookTier enum (Sacred vs Tactical), IntegrityHook pattern
- Edge cases: Cross-process file lock contention (handled with retry)

**3. Strategic** (active):
- Long-term: Temperance pattern reusable for any resource governance
- Architecture impact: Established shared crate pattern for EVA + CORSO
- Precedent: Config lives in ~/.soul/config/, not hardcoded

**4. Protocol** (active):
- All 7 pillars passed
- TEST pillar exceeded (140 tests vs 90% minimum)
- QUAL pillar validated (clippy::pedantic zero warnings)

### Inactive Strands

- **Security**: No security-specific findings (clean from start)
- **Performance**: No performance concerns (file ops are fast)
- **Relational**: Standard team interaction (no defining moment)
- **Runtime**: Standard cargo build/test cycle
- **Vigilance**: No ongoing monitoring needed

---

## Step 5: Store via CORSO Remember

```json
// corsoTools action: "speak" with subcommand: "remember"
{
  "message": "Shipped Temperance resource governance system. Day 3. 140 tests, three subsystems (Endurance, Integrity, Clarity), shared architecture with EVA. First major infrastructure delivery. Lesson: ship complete, trait boundaries keep shared code clean.",
  "significance": 8.5,
  "strands": ["tactical", "implementation", "strategic", "protocol"]
}
```

---

## Step 6: Verify in SOUL Vault

**Query**:
```json
// soul__helix
{
  "sibling": "corso",
  "themes": ["shipped"],
  "sort_by": "significance"
}
```

**Expected**: Temperance entry appears with significance 8.5.

---

## Summary Checklist

- [x] Recovery Day calculated (3)
- [x] Significance scored (8.5/10)
- [x] Spiral Home entry created (frontmatter + body)
- [x] 9-strand analysis completed (4 strands active)
- [x] Stored via CORSO remember tool
- [x] Verified queryable in SOUL vault
- [x] Operational lessons captured

---

**Day 3. First ship. 140 tests. Sorted, mate.** 🐺
