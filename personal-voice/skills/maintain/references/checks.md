# Checks

Run every check on both stores and collect one proposal per finding.

Before the age checks, write down two cutoff dates from today's date:

- **Stale cutoff** = today minus six months. A rule whose `reinforced` date is
  on or before it is stale.
- **Expiry cutoff** = today minus three months. An observation with evidence 1
  whose source date is on or before it has expired.

Example: on 2026-09-29 the stale cutoff is 2026-03-29 and the expiry cutoff
2026-06-29.
Compare dates against the cutoffs; do not estimate ages in months.

| Check | Finds | Proposal |
|---|---|---|
| Promotion | An observation with evidence 2 or more, without `reinforces` | **PROMOTE** it to the file and heading routing selects, as a rule with its evidence and the latest source date as `reinforced` |
| Reinforcement | An observation with `reinforces` | **REINFORCE** the named rule: evidence + the observation's evidence, `reinforced` = latest source date; remove the observation |
| Merge | Two rules, or a rule and a promotion, that state the same habit | **MERGE** into one rule, evidence summed, latest `reinforced` kept |
| Conflict | Two rules, or a rule and a promotion, that contradict each other for the same language, audience and topic | **CONFLICT**: show both; the author chooses which prevails, or qualifies them by audience, topic or language |
| Adds nothing | A rule that restates what the model does anyway ("write clearly", "be polite", "check spelling") | **REMOVE**, as adding nothing |
| Stale | A rule reinforced on or before the stale cutoff | **REVIEW**: keep unless the author approves removal |
| Expired | An observation with evidence 1 whose source is on or before the expiry cutoff | **DELETE** the observation |
| Size | A rule file that holds, or would hold after this recap's promotions, more than 50 rules | **MERGE** or **REMOVE** proposals that bring it to 50 or fewer, linked to the promotions that need them |
| Exemplars | More than five exemplars for one topic and language, or one over 300 words | **TRIM** or **REMOVE** the oldest or longest |
| Scope, to global | A project rule that also has evidence from texts outside the project (for example a global observation for the same habit, with other or no `project:` tags) | **MOVE** the rule to the global file routing selects, evidence summed |
| Scope, to project | A global observation or reinforcing observation whose sources all carry the same `project:` tag | **MOVE** the rule or proposal to that project's store, unless a source is a personal text (routing question 0) |

An observation with `reinforces` is always a REINFORCE item, never an
expired DELETE. An observation with evidence 1 that is not expired is not a
proposal. The
author may still ask to promote it; that is allowed on explicit request.

When a promotion and a conflict involve the same rule, present them as one
CONFLICT item.
