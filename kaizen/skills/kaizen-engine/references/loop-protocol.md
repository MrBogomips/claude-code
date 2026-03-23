# Loop Protocol — 8-Phase Iteration Detail

## Phase Sequence

```
MEASURE → ANALYZE → HYPOTHESIZE → PROPOSE → APPLY → VERIFY → DECIDE → LOG → [loop or stop]
```

Each phase maps to one Sequential Thinking thought. The chain represents a single iteration.

## Phase Specifications

### Phase 1: MEASURE

**Purpose:** Collect current KPI values as the starting point for this iteration.

**Inputs:**
- Measurement tool path (from manifest)
- Run directory path

**Outputs:**
- `iterations/{NNN}/measurement.json`

**Failure modes:**
| Failure | Severity | Recovery |
|---------|----------|----------|
| Tool script not found | CRITICAL | Abort iteration, check BOOTSTRAP |
| Tool runtime missing (Python/TS) | CRITICAL | Abort run, report to user |
| Tool exits with error | RECOVERABLE | Read stderr, fix if simple typo/path, retry once |
| Tool produces invalid JSON | RECOVERABLE | Fix output parsing, retry once |
| Tool hangs (>60s) | CRITICAL | Kill process, abort iteration |
| Partial KPI output (some missing) | WARNING | Log warning, proceed with available KPIs |

### Phase 2: ANALYZE

**Purpose:** Compare current KPIs to baseline/previous, identify trends and opportunities.

**Inputs:**
- Current measurement.json
- Previous measurement (baseline.json or previous iteration's measurement.json)
- Profile KPI definitions

**Outputs:**
- `iterations/{NNN}/analysis.md` (first section)

**Analysis structure:**
1. **Per-KPI delta table** — current vs previous, absolute and percentage change
2. **Trend assessment** — improving, plateauing, or regressing (based on last 3 iterations if available)
3. **Opportunity ranking** — which KPI has the most room for improvement, considering direction and current distance from ideal
4. **Anomaly detection** — sudden jumps, reversals, or values outside expected range

**Failure modes:**
| Failure | Severity | Recovery |
|---------|----------|----------|
| No previous measurement | INFO | Use baseline as comparison point |
| KPI value type mismatch | WARNING | Log, cast if possible, skip if not |
| Analyzer agent fails | RECOVERABLE | Run analysis inline (no subagent) |

### Phase 3: HYPOTHESIZE

**Purpose:** Form testable hypotheses about root causes and improvement opportunities.

**Inputs:**
- Analysis from Phase 2
- Profile's HYPOTHESIZE section (domain knowledge)

**Outputs:**
- Appended to `iterations/{NNN}/analysis.md`

**Hypothesis structure:**
- **Observation**: what the data shows
- **Hypothesis**: proposed explanation
- **Predicted effect**: what change would improve the KPI
- **Confidence**: high/medium/low based on evidence strength

### Phase 4: PROPOSE

**Purpose:** Generate a concrete, minimal, actionable change proposal.

**Inputs:**
- Hypotheses from Phase 3
- Mutation targets (allowed files/assets)
- Immutable list (forbidden files)
- Profile's PROPOSE section
- Previous iteration's decision (to avoid repeating reverted proposals)

**Outputs:**
- `iterations/{NNN}/proposal.md`

**Proposal structure:**
1. **Target**: which file(s) or asset(s) to modify
2. **Change description**: precise description of what to change
3. **Rationale**: which hypothesis this tests
4. **Expected KPI impact**: predicted improvement with reasoning
5. **Risk assessment**: what could go wrong
6. **Confidence**: high/medium/low

**Constraints:**
- MUST NOT propose changes to immutable files
- MUST propose the **minimum viable change** — prefer small, targeted edits over large refactors
- MUST NOT repeat a proposal that was reverted in the immediately previous iteration (try a different approach)
- If confidence is low, flag this in the proposal

**Failure modes:**
| Failure | Severity | Recovery |
|---------|----------|----------|
| No viable proposal found | INFO | Skip to DECIDE with `no_proposal: true` |
| Proposal touches immutable file | CRITICAL | Reject proposal, re-propose |
| Proposer agent fails | RECOVERABLE | Generate proposal inline |

### Phase 5: APPLY

**Purpose:** Execute the proposed changes safely with full rollback capability.

**Inputs:**
- Proposal from Phase 4
- Mutation targets and immutable list

**Outputs:**
- `iterations/{NNN}/backup/` directory
- `iterations/{NNN}/diff.patch`
- Modified target files

**Protocol:**
1. Create `backup/` directory
2. For each file in mutation scope: copy to backup preserving relative path
3. Verify no proposed change violates immutable list
4. Apply each change using Edit/Write tools
5. After each file change, verify syntactic validity if applicable
6. Generate diff (git diff or unified diff from backups)

**Failure modes:**
| Failure | Severity | Recovery |
|---------|----------|----------|
| Backup creation fails | CRITICAL | Abort iteration (cannot safely proceed) |
| File write permission denied | CRITICAL | Abort, restore from backup |
| Partial apply (some succeed, some fail) | CRITICAL | Full restore from backup |
| Syntax validation fails | RECOVERABLE | Revert specific file, attempt fix, or full revert |
| Immutable violation detected | CRITICAL | Full restore, flag to user |

### Phase 6: VERIFY

**Purpose:** Re-measure KPIs after the change to assess impact.

Same protocol as Phase 1 (MEASURE), writing to `verification.json` instead.

### Phase 7: DECIDE

**Purpose:** Determine whether to keep or revert the change based on KPI comparison.

**Inputs:**
- measurement.json (before)
- verification.json (after)
- Profile strategy and convergence settings

**Outputs:**
- `iterations/{NNN}/decision.json`
- File restoration (if revert)
- Git commit (if keep + git-managed)

**Decision logic documented in `ratchet-strategies.md`.**

### Phase 8: LOG

**Purpose:** Update aggregate run state and inform the user.

**Inputs:**
- Decision from Phase 7
- Running totals from summary.json

**Outputs:**
- Updated `summary.json`
- User-facing iteration summary

## Timing Expectations

| Phase | Typical Duration | Model |
|-------|-----------------|-------|
| MEASURE | 5-15s | haiku (via measurer agent) |
| ANALYZE | 10-30s | sonnet (via analyzer agent) |
| HYPOTHESIZE | 5-15s | inline (Sequential Thinking) |
| PROPOSE | 15-45s | sonnet (via proposer agent) |
| APPLY | 5-20s | inline (file operations) |
| VERIFY | 5-15s | haiku (via measurer agent) |
| DECIDE | 5-10s | inline (comparison logic) |
| LOG | 2-5s | inline (file write) |

**Total per iteration:** ~1-3 minutes depending on complexity and autonomy pauses.
