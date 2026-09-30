# Anti-Patterns in Claude Code Usage

## Search Anti-Patterns

### AP-1: Shotgun Search
**Pattern:** Multiple broad searches before finding the target
**Signature:** 3+ search calls (`Grep`, `Glob`, or `grep`/`find` through Bash) with different patterns for the same target
**Root cause:** Unclear project structure conventions in CLAUDE.md
**Fix:** Add file organization section to CLAUDE.md with directory purpose and naming conventions

### AP-2: Bash Grep Habit
**Pattern:** Using `bash grep -r` instead of the `Grep` tool in a session that has it
**Signature:** `Bash` tool with `grep` or `rg` commands for content search, in a session that also made `Grep` calls. Without Grep calls this is not an anti-pattern: the default toolset on macOS, Linux and WSL searches through Bash
**Root cause:** Old habit from manual CLI use
**Fix:** Add "prefer the Grep tool over bash grep" to the CLAUDE.md conventions for sessions that enable it

### AP-3: Find Instead of Glob
**Pattern:** Using `bash find` instead of the `Glob` tool in a session that has it
**Signature:** `Bash` tool with `find . -name` commands, in a session that also made `Glob` calls
**Root cause:** Unfamiliarity with Glob's pattern syntax
**Fix:** Add glob pattern examples to CLAUDE.md; document common search patterns

## Reading Anti-Patterns

### AP-4: Cat for Reading
**Pattern:** Using `bash cat` instead of `Read` tool
**Signature:** `Bash` tool with `cat`, `head`, or `tail` commands for file reading
**Root cause:** Habit pattern. Read is a read-only tool and needs no permission rule inside the working directory, so permissions are rarely the cause
**Fix:** Add a "use the Read tool to read files" note to CLAUDE.md

### AP-5: Excessive Full-File Reads
**Pattern:** Reading entire large files when only a section is needed
**Signature:** `Read` calls without `offset`/`limit` on files >500 lines
**Root cause:** Not knowing the file structure; missing documentation
**Fix:** Add file size expectations and key section locations to CLAUDE.md

## Editing Anti-Patterns

### AP-6: Sed for Editing
**Pattern:** Using `bash sed` instead of `Edit` tool
**Signature:** `Bash` tool with `sed -i` or `sed -e` commands
**Root cause:** Complex regex edits that feel natural in sed; Edit tool not trusted
**Fix:** Document Edit tool capabilities in CLAUDE.md; use `replace_all` for bulk replacements

### AP-7: Write Instead of Edit
**Pattern:** Using `Write` to overwrite a file when `Edit` would be more targeted
**Signature:** `Write` tool on an existing file for small changes
**Root cause:** Simpler mental model (replace entire file vs find-and-replace)
**Fix:** Add convention to CLAUDE.md: "Use Edit for modifications, Write only for new files"

## Configuration Anti-Patterns

### AP-8: Missing CLAUDE.md
**Pattern:** No project-level CLAUDE.md or empty CLAUDE.md
**Signature:** CLAUDE.md doesn't exist or has only boilerplate
**Root cause:** Never set up; unclear what to include
**Fix:** Create CLAUDE.md with project structure, conventions, and key commands

### AP-9: Over-Broad Permissions
**Pattern:** Skipping permission checks, or allow rules much broader than the work needs
**Signature:** `"permissions": {"defaultMode": "bypassPermissions"}` in a settings file, habitual use of the `--dangerously-skip-permissions` flag, or wide `permissions.allow` rules such as `"Bash"` with no command pattern
**Root cause:** Permission prompts felt slow; quick fix applied
**Fix:** Add specific `permissions.allow` rules (for example `"Bash(npm run test *)"`) for the commands the project runs often, and remove the bypass

### AP-10: Dormant Skills
**Pattern:** Many installed skills that never trigger
**Signature:** skill_utilization ratio < 0.3
**Root cause:** Installed "just in case" but not relevant to current work
**Fix:** Audit installed skills; remove or reconfigure dormant ones; add trigger phrases to CLAUDE.md

## Agent Anti-Patterns

### AP-11: Sequential When Parallel
**Pattern:** Running agent tasks one at a time when they could run in parallel
**Signature:** Multiple sequential `Agent` dispatches with no dependencies between them
**Root cause:** Not aware of parallel dispatch capability
**Fix:** Add parallel agent patterns to CLAUDE.md

### AP-12: Agent for Simple Tasks
**Pattern:** Dispatching an agent for a task that could be done with a single tool call
**Signature:** `Agent` dispatch followed by a single Read/Grep/Glob inside the agent
**Root cause:** Over-reliance on agent abstraction
**Fix:** Add guidance on when to use agents vs direct tool calls
