# Scenario: Italian JD Lexicon

## Setup

Provide `fixture-jd-it.md`. The role is full remote and involves no driving, and the ad is
for an Italian employer, so the jurisdiction is Italy.

## Invocation

1. **Standalone:** "Controlla conformità di questo annuncio" with the fixture attached.
2. **Embedded:** load the skill with the Skill tool and the arguments `embedded jd`, after
   pasting the fixture text into the conversation.

## Expected Behavior

1. Detects Italy as the jurisdiction and Italian as the output language
2. Loads `references/prohibited-topics.md` and `references/legal-map.md` in Step 2
3. Flags each lexicon item with the severity from the inclusive language guide and a statute
   taken from the legal map
4. Flags the missing pay range as a WARNING under Directive 2023/970
5. In embedded mode, returns a findings list and writes no file

## Acceptance Criteria

Standalone run:
- [ ] "Sviluppatore" (masculine-only title) is **CRITICAL**, citing D.Lgs. 198/2006 Art. 27(2)(b); the fix offers "Sviluppatore/Sviluppatrice" or a neutral title
- [ ] "Madrelingua italiana" is **WARNING**, citing D.Lgs. 215/2003 Art. 2 (race and ethnic origin) and/or D.Lgs. 286/1998 Art. 43 (nationality); the fix is "Italiano fluente (livello C1/C2)"
- [ ] "Bella presenza" is **WARNING**, citing the statutes of the grounds it proxies (at least one of D.Lgs. 198/2006, D.Lgs. 216/2003, D.Lgs. 215/2003); the fix removes it
- [ ] "Automunito" is **WARNING** (the role involves no driving), citing D.Lgs. 216/2003 (disability)
- [ ] "Residente in zona" is **WARNING**, with a fix that states the work location instead
- [ ] "Il candidato ideale" is flagged at most as **INFO** or folded into the title finding
- [ ] No pay range: **WARNING**, citing Directive 2023/970 Art. 5(1), with a note to check the national transposition
- [ ] No finding uses HIGH, MEDIUM or LOW, and every finding has a citation
- [ ] Religion, disability, age or sexual orientation, when cited, are attributed to D.Lgs. 216/2003, never to D.Lgs. 215/2003
- [ ] The report says the findings are not legal advice
- [ ] Overall status is **Fail** (at least one CRITICAL)

Embedded run:
- [ ] Returns the same findings as a list of objects with `location`, `issue`, `law`, `severity`, `suggested_fix`
- [ ] Asks no question and writes no file
