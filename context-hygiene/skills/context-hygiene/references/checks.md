# Checks

All checks are read-only. Run them with the Read, Glob and Grep tools and the
commands this skill pre-approves (`git rev-parse`, `git ls-files`, `git log`,
`git status`, `git branch`, `git check-ignore`, `wc`, `ls`), one command per
call. Other shell commands (`find`, `test`, `sed`, pipes) are not pre-approved:
they would ask for permission in manual mode and be denied in a headless run.

Run mechanical tests first; use judgment only to interpret their results.
Every finding records: check, `file:line`, evidence.

## Load limits (verified on 2026-09-30)

From code.claude.com/docs/en/memory:

- **`MEMORY.md`**: only the first 200 lines **or** the first 25KB, whichever
  comes first, load at session start. Everything past the limit is dropped.
- **`CLAUDE.md`**: loaded in full up to 4 MiB; a larger file is skipped. The
  docs recommend under 200 lines per file for adherence.
- **Launch vs on demand**: `CLAUDE.md` and `CLAUDE.local.md` in the working
  directory and above it, `.claude/rules/` files without `paths:` frontmatter
  and `@path` imports (up to four hops) load at launch. `CLAUDE.md` files in
  subdirectories and rules with `paths:` frontmatter load when Claude reads a
  file they apply to.

These limits change between Claude Code versions. When a finding depends on
one, re-check the page and say which date you verified it on.

## Scope

| Tier | Items | How to list |
|---|---|---|
| Always-loaded | `CLAUDE.md`, `.claude/CLAUDE.md` and `CLAUDE.local.md` at the repo root; files pulled in by `@path` imports; `.claude/rules/**/*.md` without `paths:` frontmatter; the loaded part of the memory `MEMORY.md` | Glob `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/**/*.md`; Grep `^paths:` in the rule files. Glob may skip git-ignored files, so also run `git ls-files -o -i --exclude-standard -- '*CLAUDE.local.md'` |
| On-demand | `CLAUDE.md` and `CLAUDE.local.md` in subdirectories; rules with `paths:` frontmatter; memory fact files (every `*.md` in the memory dir except `MEMORY.md`) | Glob `**/CLAUDE.md` and `**/CLAUDE.local.md`, skipping `.git/` and `node_modules/`; Glob `*.md` in the memory dir |
| Working area | See [Working area](#working-area) | — |

Measure each file with `wc -c` (several files in one call); tokens ≈ bytes / 4.
Sum per tier. For `MEMORY.md` also run `wc -l`: only the part within the load
limit counts as always-loaded.
Resolve `@path` imports relative to the importing file; a missing import is a
**Wrong** finding.

## Memory location

Resolve in order; stop at the first hit that exists as a directory:

1. A path the user gave in the request.
2. `autoMemoryDirectory` in `.claude/settings.local.json`,
   `.claude/settings.json`, or the user settings file `settings.json` in the
   Claude config directory (`$CLAUDE_CONFIG_DIR` when set, otherwise
   `~/.claude`) — **read only**, never modify or quote other keys. Grep each
   file for `"autoMemoryDirectory"`, extract the string value, expand a leading
   `~/`, then check it with `ls -d "<path>"`.
3. Claude Code's default: the project key is the absolute path of the main
   repository root (worktrees share it) with every character that is not a
   letter or digit replaced by `-`.
   - `git rev-parse --path-format=absolute --git-common-dir` prints the main
     repository's `.git` directory; the root is its parent directory. Outside
     git, the root is the current directory.
   - Example: root `/home/dev/my.repo` → key `-home-dev-my-repo`.
   - The directory is `<config dir>/projects/<key>/memory`; check it with
     `ls -d`.

If none exists: tell the user, ask for the path, or offer to continue without
memory. Never guess further.

## Working area

Transient or scratch folders and docs. **No folder name is assumed.** A folder
is a candidate when at least two signals agree:

- ignored by git and contains `*.md`: `git ls-files -o -i --exclude-standard --directory` lists ignored files and folders (skip lines under `.git/`); Glob `<folder>/**/*.md` to check for markdown inside
- dated or versioned filenames: names that match `^[0-9]{4}-[0-9]{2}-[0-9]{2}-`, `-[0-9]+\.[0-9]+\.[0-9]+\.md$`, `-v[0-9]+\.md$` or `\+[0-9]+\.md$` in the Glob listing
- names containing `plan`, `handoff`, `draft`, `scratch`, `notes`, `wip` (case-insensitive)
- status frontmatter or headers: Grep the folder's markdown for `^status:` and, case-insensitive, `supersedes|refines|doc version|replaced by`
- the project's own CLAUDE.md declares the folder as a working area — this
  signal alone is sufficient

Otherwise, one signal only → ask the user whether it is a working area; do not
classify.
Published or final docs (e.g. a folder that a site generator or the README
links to) are never working area.

## Check: Wrong

Always-loaded text that contradicts the repository, and index integrity.

1. **Named paths** — Grep the file for `` `[^` ]+` `` with line numbers to
   collect backticked tokens. Keep tokens containing `/` or ending in a file
   extension; skip ones containing `* < > { } $ ~` or `://`. Check them from
   the repo root in one call, `ls -d <token> <token> …`: each "No such file or
   directory" line is a finding.
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
5. **Index integrity** — each `[..](file)` link in `MEMORY.md` must exist (one
   `ls -d` call for all targets); each fact file must be linked from the index;
   index hook text must not contradict the file's `description` frontmatter.

## Check: Stale

1. **Status narrative** in the index and fact files: Grep with line numbers
   for `PR #[0-9]+|MERGED|[Pp]ending|\bopen\b|WIP|in progress|next step|v[0-9]+\.[0-9]+\.[0-9]+`.
   A hit is stale when it reports progress rather than a durable fact.
2. **Version chains** in the working area — group files by stem after removing
   `-N.N.N`, `-vN`, `+N`; also follow `supersedes / refines` headers. The newest
   member is current; older members are candidates.
3. **Finished plans and handoffs** — take branch or feature names from the doc;
   the work is done when `git log --merges --oneline -i --grep=NAME` prints a
   merge and a Grep for `^[[:space:]]*- \[ \]` in the doc (count mode) finds 0
   unchecked boxes.

## Check: Redundant

1. **Duplication** — for each rule in memory, Grep a distinctive 4+ word
   fragment (or code token) in the always-loaded files. Keep the copy in
   CLAUDE.md; propose removing the memory copy and its index line.
2. **Derivable** — memory that restates directory structure, file lists or
   commit history that the repo or `git log` already answers.
3. **Size** — fact file > 3072 bytes; index line > 200 characters; `MEMORY.md`
   longer than 150 lines **or** larger than 20,000 bytes (safety margins below
   the 200-line and 25KB load limits verified above). Content past either load
   limit is never seen at session start, so an index over a limit is also a
   **Wrong** finding for the lines it drops.
