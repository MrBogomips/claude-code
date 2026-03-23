---
name: claude-code-usage
description: "Analyze and improve Claude Code tool and skill usage patterns within a project or globally"
version: 1.0.0

strategy: multi-objective
autonomy: supervised
iteration_budget: 10
convergence:
  epsilon: 0.03
  patience: 3

initial_state:
  capture_strategy: automatic
  sources:
    - type: session_transcripts
      path: "~/.claude/projects/*/sessions/"
      description: "Claude Code session conversation logs"
    - type: config
      path: ".claude/"
      description: "Project-level Claude Code configuration (CLAUDE.md, settings.json)"
    - type: git_history
      command: "git log --oneline -100"
      description: "Recent commit activity for context on what work was done"
    - type: memory
      path: "~/.claude/projects/*/memory/"
      description: "Project memory files with learned preferences and feedback"
    - type: config
      path: "~/.claude/settings.json"
      description: "Global Claude Code settings and permissions"

measurement:
  tool_generation: true
  language: python

kpis:
  - name: tool_efficiency
    description: "Ratio of dedicated tool usage (Read, Grep, Glob, Edit, Write) vs bash fallback equivalents (cat, grep, rg, sed, awk, echo). Higher is better."
    direction: maximize
    unit: ratio
    measurement_method: automated
    formula: "dedicated_tool_calls / (dedicated_tool_calls + bash_fallback_calls)"
  - name: search_precision
    description: "Average number of search operations (Grep, Glob, or bash find/grep) needed to locate a target file or code pattern. Lower is better."
    direction: minimize
    unit: count
    measurement_method: automated
    formula: "total_search_operations / unique_search_targets_found"
  - name: config_completeness
    description: "Coverage of recommended Claude Code configurations — permissions, rules, memory, CLAUDE.md sections. Higher is better."
    direction: maximize
    unit: percentage
    measurement_method: automated
    formula: "configured_items / recommended_items * 100"
  - name: skill_utilization
    description: "Ratio of installed skills that were actually triggered in recent sessions vs total installed skills. Higher means the skill portfolio is well-curated."
    direction: maximize
    unit: ratio
    measurement_method: automated
    formula: "triggered_skills / installed_skills"

mutation_targets:
  defaults:
    - path: ".claude/CLAUDE.md"
      description: "Project instructions — add tool usage conventions, search strategies"
    - path: ".claude/settings.json"
      description: "Permissions and tool configuration"
    - path: ".claude/settings.local.json"
      description: "Local settings overrides"
  immutable:
    - path: "**/*.ts"
    - path: "**/*.js"
    - path: "**/*.py"
    - path: "**/*.go"
    - path: "**/*.rs"
    - path: "tests/**"
    - path: ".git/**"
    - path: "node_modules/**"

connectors:
  required:
    - "~~sequential-thinking"
  optional:
    - "~~memory"
---

# Claude Code Usage Improvement Instructions

## MEASURE Phase

Analyze recent Claude Code session transcripts to extract tool usage statistics:

1. **Scan session files** — look for tool invocation patterns in conversation transcripts
2. **Classify tool calls** — categorize each tool usage as:
   - **Dedicated tool**: Read, Write, Edit, Grep, Glob, Agent, Bash (for system commands only)
   - **Bash fallback**: bash commands that duplicate dedicated tool functionality:
     - `cat`, `head`, `tail` → should be `Read`
     - `grep`, `rg` (via bash) → should be `Grep`
     - `find`, `ls` (for file search) → should be `Glob`
     - `sed`, `awk` (for file editing) → should be `Edit`
     - `echo >`, `cat <<` (for file creation) → should be `Write`
3. **Count search operations** — group sequential searches for the same target
4. **Inventory installed skills** — list all skills in `~/.claude/plugins/` and project plugins
5. **Check config coverage** — compare current `.claude/` configuration against recommended items:
   - CLAUDE.md exists and has project-specific content
   - settings.json has appropriate allowedTools
   - Memory files exist and are actively used
   - Rules directory has relevant conventions

`Read references/tool-taxonomy.md` for the complete classification guide.

## ANALYZE Phase

Compare current tool usage ratios against industry best practices:

- **tool_efficiency < 0.5**: Significant reliance on bash fallbacks. Look for patterns — is it a specific category (search, read, edit) or across the board?
- **tool_efficiency 0.5-0.8**: Moderate. Focus on the most frequent fallback category.
- **tool_efficiency > 0.8**: Good. Look for subtle improvements.

- **search_precision > 5**: Too many searches per target. Likely missing proper glob patterns or searching too broadly.
- **search_precision 2-5**: Average. Room for improvement with better search strategies.
- **search_precision < 2**: Efficient. Check if this is genuine or if search targets are too easy.

- **config_completeness < 50%**: Basic setup. Many recommended configurations missing.
- **config_completeness 50-80%**: Partial. Focus on the highest-impact missing items.
- **config_completeness > 80%**: Well-configured. Look for fine-tuning opportunities.

- **skill_utilization < 0.3**: Many dormant skills. Portfolio needs pruning or the user needs guidance.
- **skill_utilization 0.3-0.7**: Moderate. Check if dormant skills are relevant to current work.
- **skill_utilization > 0.7**: Well-curated portfolio.

`Read references/anti-patterns.md` for common inefficiency patterns and their signatures.

## HYPOTHESIZE Phase

Common root causes for poor Claude Code usage:

1. **Habit patterns** — user or Claude defaults to bash because it's familiar, not because it's better
2. **Permission gaps** — dedicated tools not in allowedTools, forcing bash workarounds
3. **CLAUDE.md gaps** — project instructions don't mention preferred tool usage patterns
4. **Missing skills** — relevant skills are available but not installed
5. **Over-installed skills** — too many skills create noise and reduce triggering precision
6. **Search strategy gaps** — no documented file organization conventions, leading to broad searches

## PROPOSE Phase

Appropriate changes for this profile:

- **Add tool usage conventions to CLAUDE.md** — e.g., "Always use Grep instead of bash grep for code search"
- **Update allowedTools in settings.json** — grant permissions for frequently-used dedicated tools
- **Add search strategy hints to CLAUDE.md** — document the project structure so searches are targeted
- **Recommend skill installation/removal** — suggest installing relevant skills or removing dormant ones

**Constraints:**
- NEVER modify source code files — this profile only touches Claude Code configuration
- Changes should be conservative — one config change per iteration
- Prefer CLAUDE.md additions over settings.json changes (more visible, easier to review)
- Provide the user with context for why the change helps (reference the specific anti-pattern)

## APPLY Phase

When modifying CLAUDE.md:
- Add new sections at the end, don't reorganize existing content
- Use clear headings that indicate the content was added by kaizen

When modifying settings.json:
- Validate JSON syntax after changes
- Preserve all existing settings — only add or modify, never remove

## VERIFY Phase

After applying changes, re-run the measurement tool. Additionally:
- Verify that modified configuration files are syntactically valid
- Check that no existing functionality was broken by the config change
- Note that tool_efficiency improvements may not be immediately visible (they affect future sessions)
