# Tool Taxonomy — Dedicated Tools vs Bash Fallbacks

## Dedicated Tools (Preferred)

These are Claude Code's built-in tools designed for specific operations. They provide better user experience, are reviewable, and integrate with the permission system.

Toolsets differ between sessions. On macOS, Linux and WSL the default toolset has no Grep or Glob tool: Claude searches with `grep` and `find` through Bash, which is the intended route there. Grep and Glob appear only in sessions that enable them (for example with `--tools` or `--allowedTools`, or in a subagent that lists them and leaves out Bash). Classify a Bash command as a fallback only when the session had the dedicated tool it duplicates.

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `Read` | Read file contents | Any file reading operation |
| `Write` | Create new files | Creating new files or complete rewrites |
| `Edit` | Modify existing files | Targeted text replacements |
| `Grep` | Search file contents | Pattern matching across files |
| `Glob` | Find files by name | File discovery by path pattern |
| `Agent` | Dispatch subagents | Complex multi-step research or parallel tasks |
| `Bash` | System commands | Operations with no dedicated tool in the session, including search when Grep and Glob are absent |

## Bash Fallback Patterns (Anti-Patterns)

These are bash commands used via the `Bash` tool that duplicate dedicated tool functionality. Each has a preferred dedicated tool alternative, and counts as a fallback only in a session that had that alternative.

### File Reading Fallbacks

| Bash Command | Dedicated Alternative | Detection Pattern |
|-------------|----------------------|-------------------|
| `cat {file}` | `Read` | `Bash` tool with `cat` command |
| `head -n {N} {file}` | `Read` with `limit` parameter | `Bash` tool with `head` command |
| `tail -n {N} {file}` | `Read` with `offset` parameter | `Bash` tool with `tail` command |
| `less {file}` | `Read` | `Bash` tool with `less` command |

### Content Search Fallbacks

Count these only in sessions whose transcript shows Grep calls.

| Bash Command | Dedicated Alternative | Detection Pattern |
|-------------|----------------------|-------------------|
| `grep {pattern} {files}` | `Grep` | `Bash` tool with `grep` command |
| `grep -r {pattern} .` | `Grep` with `path` parameter | `Bash` tool with recursive grep |
| `rg {pattern}` | `Grep` | `Bash` tool with `rg` command |
| `ag {pattern}` | `Grep` | `Bash` tool with `ag` command |
| `ack {pattern}` | `Grep` | `Bash` tool with `ack` command |

### File Discovery Fallbacks

Count these only in sessions whose transcript shows Glob calls.

| Bash Command | Dedicated Alternative | Detection Pattern |
|-------------|----------------------|-------------------|
| `find . -name {pattern}` | `Glob` | `Bash` tool with `find` command |
| `ls {pattern}` | `Glob` | `Bash` tool with `ls` for file discovery |
| `fd {pattern}` | `Glob` | `Bash` tool with `fd` command |

### File Editing Fallbacks

| Bash Command | Dedicated Alternative | Detection Pattern |
|-------------|----------------------|-------------------|
| `sed -i {expr} {file}` | `Edit` | `Bash` tool with `sed` command |
| `awk '{script}' {file}` | `Edit` | `Bash` tool with `awk` for file modification |
| `perl -pi -e {expr} {file}` | `Edit` | `Bash` tool with `perl` for editing |

### File Creation Fallbacks

| Bash Command | Dedicated Alternative | Detection Pattern |
|-------------|----------------------|-------------------|
| `echo "..." > {file}` | `Write` | `Bash` tool with echo redirect |
| `cat << 'EOF' > {file}` | `Write` | `Bash` tool with heredoc redirect |
| `printf "..." > {file}` | `Write` | `Bash` tool with printf redirect |

## Legitimate Bash Usage

These bash commands have NO dedicated tool equivalent and are appropriate:

- `git` commands (status, log, diff, commit, push, branch)
- `npm`, `yarn`, `pnpm` package management
- `pip`, `poetry`, `uv` package management
- `cargo`, `go`, `dotnet` build tools
- `docker`, `docker-compose` container management
- `curl`, `wget` HTTP requests (when not using WebFetch)
- `make`, `cmake` build systems
- Process management (`ps`, `kill`, `lsof`)
- System information (`uname`, `whoami`, `env`)
- Test runners (`pytest`, `jest`, `cargo test`)
- Linters and formatters (`eslint`, `prettier`, `black`, `rustfmt`)

## Measurement Logic

To calculate `tool_efficiency`:

1. Count all tool invocations in session transcripts
2. For each session, note whether it made any Grep or Glob call; if it made none, treat its search commands as legitimate Bash uses
3. For each `Bash` invocation, check if the command matches a fallback pattern that applies to its session
4. Classify: `dedicated_tool_calls` = non-Bash tools + legitimate Bash uses; `bash_fallback_calls` = Bash invocations matching an applicable fallback pattern
5. Ratio = `dedicated_tool_calls / (dedicated_tool_calls + bash_fallback_calls)`

This KPI is observational: it describes past sessions and does not decide keep or revert.
