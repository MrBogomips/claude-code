# Switching the project store's git choice

Use when the author asks to share the project store with the team, to version
it, or to make it personal again.

1. Check the current state: `.personal-voice/` listed in the repository's
   exclude file means personal; otherwise it is versioned (or not yet
   committed). The exclude file is `.git/info/exclude`, or, where `.git` is a
   file (a linked worktree or submodule), the path
   `git rev-parse --git-path info/exclude` prints.
2. Explain the implications again, with the store format's Project store
   initialization text, and ask the author to confirm the switch. This is an
   item like any other: change nothing until they confirm.
3. Apply:
   - **Personal → versioned**: remove the `.personal-voice/` line from
     `.git/info/exclude`. Do not commit; tell the author the files now show up
     in `git status` and they can commit them.
   - **Versioned → personal**: add the line to `.git/info/exclude`. If the
     files are already committed, say that they stay in the history, and that
     `git rm -r --cached .personal-voice` stops tracking them; run it only if
     the author asks.
   - Never edit `.gitignore` for the project store.

Edit `.git/info/exclude` with the Edit tool, not a shell command. Claude Code
protects `.git/`, so the edit asks for permission.
