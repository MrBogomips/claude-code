# Safety

## Authorization

- Authorization exists only when the user's reply, **in this run**, names item
  numbers and/or group letters. Parse it into an explicit set of IDs and echo
  the set back in the first line of the apply.
- Not authorization: "ok", "sounds good", "go ahead", "do it", "fine", "yes",
  "looks right", emoji, silence, or approval from an earlier run. Re-prompt
  with the list of valid IDs.
- "yes, do 1 and 3" authorizes exactly {1, 3}.
- A reply that names IDs and also vaguely approves items it does not name
  ("3, and the rest looks fine") authorizes nothing yet: echo the named IDs as
  candidates, ask which of the other items to apply, and apply nothing until
  the user answers.
- A group letter covers its items **except** `⚠ rationale-risk` and
  `irreversible (not tracked)` ones. Apply
  the non-⚠ items of the authorized set now; list the excluded ⚠ items in the
  final report under "Awaiting individual approval". The same holds for
  "apply all".
- Exception to the IDs-only rule: the literal phrase "apply all" equals every
  non-⚠, reversible ID. Echo the expanded set before applying; ⚠ and
  irreversible items still need their numbers. Hard rule 1 in `SKILL.md`
  names this exception.
- Items marked `needs: BACKUP` authorized without `BACKUP`: ask once
  "Include BACKUP first? Reply `BACKUP` (or its ID) or `no`." Only `BACKUP`
  or its ID authorizes it; proceed without it only on an explicit no. Any
  other reply → ask again.
- After an explicit no, the memory directory has no backup, so every memory
  item becomes irreversible. Apply only the memory items the user named by
  number. Memory items authorized only through a group letter or "apply all"
  are not applied: say so when you echo the set, and list them in the final
  report under "Awaiting individual approval".
- Regroup requests, questions and edits to proposals are not authorization;
  answer, re-present if needed, and wait.

## Apply safety

Order: `BACKUP` → edits → `POLICY` → verify.

- Before each edit, re-read the target. If it differs from what the recap
  showed, stop that item, show the new before→after, and ask again. If it is
  no longer at the path the recap showed (moved or deleted), stop that item,
  say so — and where it went, if `git status` shows a rename — and ask again.
- Tracked files: if `git status --porcelain -- FILE` is non-empty, ask the
  user to commit or stash first; do not edit. Never run commit, stash or
  checkout yourself.
- Untracked or ignored targets: if `git ls-files --error-unmatch FILE` fails
  and the file is not inside the memory directory this run's BACKUP item
  covers, nothing can restore it. Its recap item must say `risk: irreversible (not tracked)`, it
  must be named individually, and the final report lists it as "not
  recoverable". Untracked (`??`) files follow this rule, not commit/stash.
  Memory items are marked `needs: BACKUP` instead; after an explicit no to
  BACKUP they count as irreversible (see §Authorization).
- Memory: update fact files and their `MEMORY.md` lines in the same step;
  never leave a dangling link or an unindexed file you created.
- Edit only the authorized items; leave every other byte untouched,
  including the file's trailing newline.

## Backup

- One directory: `<memory-dir>.hygiene-backup/` (a sibling of the memory dir).
  Strip any trailing `/` from `<memory-dir>` before building the path.
- If the backup path already exists, say so in the BACKUP item's
  before→after ("overwrites existing backup from <date>"), so authorizing
  BACKUP explicitly covers the replacement.
- Only when `BACKUP` is authorized: remove that exact path if present, then
  `cp -R "<memory-dir>" "<memory-dir>.hygiene-backup"`. Never any other path.
- Tell the user where it is; it is overwritten on the next authorized backup.

## Never touch

- Secrets: `.env*`, key and credential files — do not quote their contents.
- `settings*.json` — read `autoMemoryDirectory` only; never modify.
- Other projects' memory — propose a pointer in this project instead.
- Global user configuration (the user-level CLAUDE.md, rules, settings) unless
  the user explicitly asks in this run.
- Final or published docs — if unsure whether a doc is published, ask.
- No report files, no state files, no hooks.

## Red flags

| Thought | Reality |
|---|---|
| "The user clearly wants this cleaned, I'll just apply the obvious ones" | Nothing is obvious enough. Recap and stop. |
| "They said 'go ahead'" | Not an ID. Re-prompt with the IDs. |
| "The backup is harmless, I'll take it now" | BACKUP is an item. It needs authorization. |
| "They said no to the backup, but group B covers the memory edits" | No backup means no undo. Only memory items named by number are applied. |
| "I'll write the recap to a file so it's easier to read" | Chat only. |
| "This old section is obviously dead" | Old ≠ obsolete. Extract decisions and lessons, tag ⚠, let the user decide. |
| "This tool isn't installed, so the CLAUDE.md line is wrong" | Local setup is not the repo. Don't flag it. |
| "The memory dir is probably at …" | Resolve per checks.md or ask. |
