---
name: write
description: Use when writing text the author will send, publish or hand over as their own, in any language - documents, reports, emails, messages, posts, letters, replies - for example "draft an email to the client", "scrivi una mail al team", "rédige un message pour l'équipe", "schreib einen kurzen Bericht", "escribe un post para LinkedIn", or when asked to write in the author's voice or style. Applies the author's personal voice profile of tone and lexicon. Not for code, code comments, commit messages or configuration files.
---

# Write in the author's voice

## Standing instructions — for the rest of this session

Once this skill is loaded, keep watching for two events until the session ends:

1. **The author revises text you wrote in this session** for people: they paste
   a new version, state a correction ("I never write X", "too formal"), say they
   edited a file you wrote, or Claude Code reports that such a file changed on
   disk. Invoke `personal-voice:learn` on that revision in the same turn,
   without asking, then carry on with whatever else they asked.
2. **The author signals the end of the work session**, in any language ("that's
   all for today", "per oggi chiudiamo", "on s'arrête là"). Invoke
   `personal-voice:learn` for the session wrap-up.

## Scope

Apply the profile to text the author will send, publish or use as their own:
documents, reports, emails, messages, posts. Do not apply it to code, code
comments, commit messages or configuration files, even when the author says in
general that everything should sound like them; apply it there only when they
ask for it on that specific text. Your own chat replies to the author are not
their text.

This skill only reads the store. It never writes to it.

## Stores

- **Global store**: `${user_config.store_dir}`
- **Project store**: `.personal-voice/` at the project root (the git top-level
  directory, or the working directory outside git), if it exists.

If the global store path above is empty or still shows the placeholder text
`user_config.store_dir`, tell the author once in this session that the voice
profile is not set up: set **Voice store directory** in `/config`. Then write
the text normally. A configured directory that does not exist yet is an empty
store.

List and read store files with the Glob and Read tools, not shell commands:
the allow rules the plugin documents cover those tools, so no permission
prompt interrupts the author.

## Before writing

1. **Language**: the one the request or its context calls for. No setting.
2. **Topic**: list `topics/` in the global store and pick at most two slugs,
   the first being the primary. When no existing slug fits, name one yourself:
   that is not uncertainty. **Audience**: who will read the text.
3. If the topic or the audience is uncertain, ask one short question naming the
   two or three candidates, and wait. The answer may name a new topic.

## What to read, in this order

1. `core.md`
2. `languages/<code>.md` for the target language
3. `topics/<primary>.md`, then `topics/<secondary>.md`
4. In the project store: `glossary.md`, and `content-types/<slug>.md` when the
   text is one of the listed document types, plus `content-types/general.md`
5. Exemplars: up to two `exemplars/<primary>.<code>.*.md` in the target
   language. If there are none, at most one in another language.

Skip files that do not exist. Never read or apply `observations.md`: pending
observations are not rules.

## Applying the profile

- Rules are the `- ` bullets under the headings. Apply a rule only when its
  qualifiers match: `[<code>]` the target language, `[to <audience>]` the
  audience, `[topic: <slug>]` a loaded topic. An unqualified rule always applies.
- When rules conflict, the more specific wins: project over topic, topic over
  language, language over core, primary topic over secondary.
- Exemplars in the target language guide wording, rhythm and structure.
  Exemplars in another language guide rhythm and structure only: borrow none of
  their words or expressions.
- When the store holds nothing for this language and topic, write normally.
  Never attribute traits to the author that the store does not record, and do
  not describe the text as written in their voice.
- Content comes from the request. The profile changes how the text sounds and
  which words it uses, never the facts.
