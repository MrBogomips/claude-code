# Checks

All commands are read-only. Run mechanical tests first; use judgment only to
interpret their results. Every finding records: check, `file:line`, evidence.

## Scope

| Tier | Items | How to list |
|---|---|---|
| Always-loaded | `CLAUDE.md` at root and in subdirectories, `.claude/CLAUDE.md`, `CLAUDE.local.md`, files pulled in by `@path` imports, `.claude/rules/*.md`, first 200 lines of the memory `MEMORY.md` | `git ls-files -co --exclude-standard '*CLAUDE.md' 'CLAUDE.local.md' '.claude/rules/*.md'`, plus the untracked ones found by `find . -name CLAUDE.md -not -path './.git/*'` |
| On-demand | Memory fact files (every `*.md` in the memory dir except `MEMORY.md`) | `ls` the memory dir |
| Working area | See [Working area](#working-area) | — |

Measure each file with `wc -c`; tokens ≈ bytes / 4. Sum per tier.
Resolve `@path` imports relative to the importing file; a missing import is a
**Wrong** finding.

## Memory location

Resolve in order; stop at the first hit that exists as a directory:

1. A path the user gave in the request.
2. `autoMemoryDirectory` in `.claude/settings.local.json`, `.claude/settings.json`, or
   the user settings file — **read only**, never modify or quote other keys:
   `grep -h '"autoMemoryDirectory"' .claude/settings.local.json .claude/settings.json "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json" 2>/dev/null`
   — extract the string value, expand a leading `~`, then `test -d` it.
3. Claude Code's default: the project key is the absolute path of the main
   repository root (worktrees share it) with every non-alphanumeric character
   replaced by `-`:
   ```bash
   common="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" \
     && root="$(dirname "$common")" || root="$(pwd)"
   key="$(printf '%s' "$root" | sed 's/[^A-Za-z0-9]/-/g')"
   dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/$key/memory"
   ```

If none exists: tell the user, ask for the path, or offer to continue without
memory. Never guess further.

## Working area

Transient or scratch folders and docs. **No folder name is assumed.** A folder
is a candidate when at least two signals agree:

- ignored by git and contains `*.md`: `git ls-files -o -i --exclude-standard --directory | grep -v '^\.git/'`, then check for markdown inside
- dated or versioned filenames: `grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}-|-[0-9]+\.[0-9]+\.[0-9]+\.md$|-v[0-9]+\.md$|\+[0-9]+\.md$'`
- names containing `plan`, `handoff`, `draft`, `scratch`, `notes`, `wip` (case-insensitive)
- status frontmatter (`status:`) or headers matching `supersedes|refines|doc version|replaced by` (case-insensitive)
- the project's own CLAUDE.md declares the folder as a working area — this
  signal alone is sufficient

Otherwise, one signal only → ask the user whether it is a working area; do not
classify.
Published or final docs (e.g. a folder that a site generator or the README
links to) are never working area.

## Check: Wrong

Always-loaded text that contradicts the repository, and index integrity.

1. **Named paths** — collect backticked tokens that look like paths:
   `grep -noE '\`[^\` ]+\`' FILE | tr -d '\`'`, keep tokens containing `/` or
   ending in a file extension; skip ones containing `* < > { } $ ~` or `://`.
   `test -e "$root/$token"` fails → finding.
2. **Enumerations vs reality** — when a file lists components (directories,
   packages, plugins, services), compare against the actual top-level
   directories and any manifest in the repo that enumerates them (for example
   `package.json` workspaces, `pnpm-workspace.yaml`, `go.work`, `Cargo.toml`
   workspace members, a marketplace or plugin manifest, a JSON/YAML list).
   Missing or extra entries → finding.
3. **Scripts and commands** — script paths inside the repo (as in 1); package
   script names vs the manifest's `scripts`; branch names vs
   `git branch -a --list`. Do **not** flag a tool because it is absent on this
   machine — that is local configuration, not a contradiction.
4. **Relocated components** — text describing something as local that git
   history shows was removed or extracted: `git log --diff-filter=D --oneline -- PATH`.
5. **Index integrity** — for each `[..](file)` link in `MEMORY.md`, `test -e`;
   each fact file not linked from the index; index hook text that contradicts
   the file's `description` frontmatter.

## Check: Stale

1. **Status narrative** in the index and fact files:
   `grep -nE 'PR #[0-9]+|MERGED|[Pp]ending|\bopen\b|WIP|in progress|next step|v[0-9]+\.[0-9]+\.[0-9]+' FILE`
   A hit is stale when it reports progress rather than a durable fact.
2. **Version chains** in the working area — group files by stem after removing
   `-N.N.N`, `-vN`, `+N`; also follow `supersedes / refines` headers. The newest
   member is current; older members are candidates.
3. **Finished plans and handoffs** — take branch or feature names from the doc;
   the work is done when `git log --merges --oneline | grep -i NAME` matches
   and no unchecked boxes remain (`grep -cE '^[[:space:]]*- \[ \]'` is 0).

## Check: Redundant

1. **Duplication** — for each rule in memory, grep a distinctive 4+ word
   fragment (or code token) in the always-loaded files. Keep the copy in
   CLAUDE.md; propose removing the memory copy and its index line.
2. **Derivable** — memory that restates directory structure, file lists or
   commit history that the repo or `git log` already answers.
3. **Size** — fact file > 3072 bytes; index line > 200 characters; index
   longer than 150 lines (a safety margin below the ~200-line load cut-off).
