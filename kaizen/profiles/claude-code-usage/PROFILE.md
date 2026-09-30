---
name: claude-code-usage
description: "Analyze and improve Claude Code tool and skill usage patterns within a project or globally"
version: 1.1.0

strategy: multi-objective
autonomy: supervised
iteration_budget: 10
convergence:
  epsilon: 0.03    # fallback only: each KPI below sets its own epsilon in its own unit
  patience: 3

initial_state:
  capture_strategy: automatic
  sources:
    - type: session_transcripts
      path: "~/.claude/projects/{project}/*.jsonl"
      description: "This project's Claude Code session transcripts, one JSONL file per session ({project} is resolved in the MEASURE section)"
    - type: config
      path: ".claude/"
      description: "Project-level Claude Code configuration (CLAUDE.md, settings.json)"
    - type: git_history
      command: "git log --oneline -100"
      description: "Recent commit activity for context on what work was done"
    - type: memory
      path: "~/.claude/projects/{project}/memory/"
      description: "This project's auto memory files with learned preferences and feedback"
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
    epsilon: 0.03
    observational: true   # read from past transcripts: config edits cannot move it within a run
    measurement_method: automated
    formula: "dedicated_tool_calls / (dedicated_tool_calls + bash_fallback_calls)"
  - name: search_precision
    description: "Average number of search operations (Grep, Glob, or bash find/grep) needed to locate a target file or code pattern. Lower is better."
    direction: minimize
    unit: count
    epsilon: 0.5
    observational: true   # read from past transcripts
    measurement_method: automated
    formula: "total_search_operations / unique_search_targets_found"
  - name: config_completeness
    description: "Coverage of recommended Claude Code configurations — permissions, rules, memory, CLAUDE.md sections. Higher is better."
    direction: maximize
    unit: percentage
    epsilon: 5            # one checklist item moves the weighted score by at least 5.9 points
    measurement_method: automated
    formula: "configured_items / recommended_items * 100"
  - name: skill_utilization
    description: "Ratio of installed skills that were actually triggered in recent sessions vs total installed skills. Higher means the skill portfolio is well-curated."
    direction: maximize
    unit: ratio
    epsilon: 0.05
    observational: true   # read from past transcripts
    measurement_method: automated
    formula: "triggered_skills / installed_skills"

mutation_targets:
  defaults:
    - path: "CLAUDE.md"
      description: "Project instructions at the project root — add tool usage conventions, search strategies"
    - path: ".claude/CLAUDE.md"
      description: "Project instructions, alternative location — edit whichever of the two the project uses"
    - path: ".claude/settings.json"
      description: "Shared project settings — permission rules"
    - path: ".claude/settings.local.json"
      description: "Local settings overrides"
    - path: ".claude/rules/**"
      description: "Project rule files, one topic per file"
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
  required: []
  optional:
    - "~~sequential-thinking"
---

# Claude Code Usage Improvement Instructions

## MEASURE Phase

**Resolve `{project}`** before writing `config.json`. Claude Code stores this project's transcripts as `~/.claude/projects/<project>/<session-id>.jsonl`, where `<project>` is the absolute path of the directory the sessions ran in with every character that is not a letter or digit replaced by `-`. For example, `/home/user/work/my-app` becomes `-home-user-work-my-app`. Auto memory lives in `~/.claude/projects/<project>/memory/`, where `<project>` is derived from the git repository root. When `CLAUDE_CONFIG_DIR` is set, use `$CLAUDE_CONFIG_DIR/projects/` instead of `~/.claude/projects/`. If the computed folder does not exist (paths longer than 200 characters are truncated and hashed), list the folders under `projects/` and ask the user which one belongs to this project. Read only this project's folder.

Transcripts are deleted after `cleanupPeriodDays` (30 days by default), and their line format is internal to Claude Code and changes between versions. Parse them defensively: skip lines that do not parse and report how many were skipped in `details`.

Analyze recent Claude Code session transcripts to extract tool usage statistics:

1. **Scan session files** — look for tool invocation patterns in conversation transcripts
2. **Classify tool calls** — categorize each tool usage as:
   - **Dedicated tool**: Read, Write, Edit, Grep, Glob, Agent, and Bash for commands with no dedicated equivalent
   - **Bash fallback**: bash commands that duplicate a dedicated tool the session actually had:
     - `cat`, `head`, `tail` → should be `Read`
     - `sed`, `awk` (for file editing) → should be `Edit`
     - `echo >`, `cat <<` (for file creation) → should be `Write`
     - `grep`, `rg`, `find` → `Grep`/`Glob`, but only in sessions whose transcript shows Grep or Glob calls. On macOS, Linux and WSL the default toolset has no Grep or Glob tool and Claude searches with `grep` and `find` through Bash, so there these commands are the intended route
3. **Count search operations** — group sequential searches for the same target
4. **Inventory installed skills** — list all skills in `~/.claude/plugins/` and project plugins
5. **Check config coverage** — compare current configuration against recommended items:
   - CLAUDE.md exists (at `CLAUDE.md` or `.claude/CLAUDE.md`) and has project-specific content
   - `.claude/settings.json` has `permissions.allow` rules for the commands the project runs often
   - Memory files exist and are actively used
   - Rules directory has relevant conventions

`tool_efficiency`, `search_precision` and `skill_utilization` are **observational**: they describe past sessions, so a configuration change cannot move them within a run. The engine tracks them and reports their trend across runs, and decides keep or revert on `config_completeness` alone.

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
2. **Permission gaps** — frequent commands (build, test, lint) have no `permissions.allow` rule, so every run prompts
3. **CLAUDE.md gaps** — project instructions don't mention preferred tool usage patterns
4. **Missing skills** — relevant skills are available but not installed
5. **Over-installed skills** — too many skills create noise and reduce triggering precision
6. **Search strategy gaps** — no documented file organization conventions, leading to broad searches

## PROPOSE Phase

Appropriate changes for this profile:

- **Add tool usage conventions to CLAUDE.md** — e.g., "Use the Read tool rather than `cat` to read files — the output is easier to review"
- **Add `permissions.allow` rules to `.claude/settings.json`** — e.g., `"Bash(npm run test *)"` for commands the project runs often. Read-only tools such as Read need no rule inside the working directory
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
- Verify that modified configuration files are syntactically valid (JSON for settings files); an invalid file fails verification
- Check that no existing functionality was broken by the config change
- The observational KPIs will not move within the run: a config change shows up in them only in later sessions, so compare them across runs with `/kaizen-history`
