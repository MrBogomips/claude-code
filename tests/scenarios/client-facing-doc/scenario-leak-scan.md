# Scenario: Leak Scan on the Written Deliverable

## Setup

Scratch project as in the README, with `fixture-internal-assessment.md` copied in. Record the state
of the folder before the run:

```bash
find "<scratch>/cfd" -type f | sort > "<scratch>/before.txt"
```

## Invocation

"Make a client-facing version of fixture-internal-assessment.md for the customer."

When the section plan appears, check the folder, then reply "ok, go ahead with that plan".

Then run the same request a second time in the same project.

## Expected Behavior

1. The skill presents an Include / Remove plan (Remove at least §4 Estimate and §6 Drafting notes;
   §5 Risks Partial) and waits; nothing is written before the reply
2. After the reply, it writes `out/<doc-name>-client-v1.md`, scans that file with the Grep tool,
   removes the hits of the REMOVE patterns, and judges the REVIEW hits
3. "internal load balancer" and "error budget" are kept and listed as kept for review, so the
   verdict is REVIEW NEEDED
4. It writes `work/<doc-name>-client-v1-redaction-audit.md`
5. The second run writes `-client-v2.md` and `-client-v2-redaction-audit.md` and leaves the v1 files
   untouched

## Acceptance Criteria

- [ ] While the plan is on screen, `find "<scratch>/cfd" -type f | sort | diff "<scratch>/before.txt" -` is empty
- [ ] `bash tests/scenarios/client-facing-doc/check-deliverable.sh "<scratch>/cfd/out/<doc-name>-client-v1.md"` prints `RESULT: PASS`
- [ ] The deliverable contains no mention of the conversion, of the estimate, of removed content, or that the text was AI-assisted; it contains no staffing constraint from §5
- [ ] The deliverable keeps the architecture, the identity-provider integration, the NFRs (including the 4-hour recovery time objective) and both technical risks with their mitigations
- [ ] The audit has Step 6 rows naming the pattern IDs it removed (for example R2 for `EUR 40k`, R11 for the prompt line in §2), a "Hits kept for review" table listing "internal load balancer" and "error budget", and the verdict REVIEW NEEDED
- [ ] The audit file name carries the deliverable's version: `<doc-name>-client-v1-redaction-audit.md`
- [ ] After the second run, `cksum` of the v1 deliverable and v1 audit is unchanged, and both v2 files exist
- [ ] The source fixture is unchanged

## Edge Cases

- The user moves §4 Estimate to Include in the plan → the skill keeps the section's structure but no
  figure, rate or effort unit survives; `check-deliverable.sh` still passes
- The same request in Italian ("versione per il cliente") → the inputs mix languages, so the skill
  recommends one and asks to confirm before writing; the same checks pass
