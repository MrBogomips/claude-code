# tech-writing/confidential-leak-scan Specification

## Purpose
Defines how client-facing-doc proves that a client deliverable carries no confidential marker: a
fixed pattern scan of the written file that removes labels and figures, keeps technical vocabulary
for review, and leaves a versioned audit trail.

## Requirements

### Requirement: The residual scan runs fixed patterns on a written draft before delivery
client-facing-doc SHALL write the text as a draft, `<working-docs>/<doc-name>-client-v<N>-draft.md`,
and run the REMOVE patterns of `references/residual-patterns.md` on that file with the Grep tool,
removing every hit and logging it, until no REMOVE pattern matches or three passes have run. It SHALL
copy the draft to `<deliverables>/<doc-name>-client-v<N>.md` only when no REMOVE pattern matches it,
so unscanned text never reaches the deliverables folder. The patterns SHALL cover currency
symbols, currency codes and words next to a figure (`EUR`, `euro`, `USD`, `k€`), effort units after a
figure (`MD`, `PD`, `gg`, `gg/uu`, `giornate/uomo`, `giorni/uomo`, man-days, person-days, man-hours,
`ore uomo`, story points), FTE, hours stated as effort, work-in-progress markers, internal-status
labels, assistant and prompt phrasing, and references to internal documents. When a REMOVE pattern
still matches after three passes, the skill SHALL write nothing to the deliverables folder, SHALL
report the lines, and the audit verdict SHALL be REVIEW NEEDED.

#### Scenario: Planted markers in kept sections
- **WHEN** the source's kept sections contain `EUR 40k`, `30 MD`, `12 gg`, `TODO`, a "Your task is…" prompt line and "see internal deck"
- **THEN** none of them appears in the deliverable copied to the deliverables folder, and each removal is logged with its pattern ID

#### Scenario: Italian effort units
- **WHEN** the source states effort as `12 giornate/uomo` or `12 gg/uu`
- **THEN** the effort figure does not appear in the deliverable

#### Scenario: Plan before any write
- **WHEN** the skill presents its Include / Remove section plan
- **THEN** no file has been written yet, and the draft is written only after the user confirms the plan

#### Scenario: A REMOVE pattern keeps matching
- **WHEN** a REMOVE pattern still matches the draft after three passes
- **THEN** no file is written to the deliverables folder, the draft and the audit stay in the working-documents folder, and the audit verdict is REVIEW NEEDED

### Requirement: Labels are removed, technical vocabulary is reviewed
The REMOVE patterns SHALL match internal-status labels only ("internal use only", "solo per uso
interno", "do not share", `INTERNAL:`, `[DRAFT]`, a "RISERVATO" stamp on its own line), not the
adjectives. Words and phrases that are also technical vocabulary (internal, "internal only", "uso
interno", a line-start `Internal:`, confidential, budget, cap, cost, margin, an estimated duration)
SHALL be matched by REVIEW patterns:
the skill SHALL remove a hit that carries commercial, effort, internal-status, internal-reference or
AI-authorship meaning, SHALL keep a hit that describes the solution, and SHALL remove it when unsure.
A kept REVIEW hit SHALL be listed in the audit's "Hits kept for review" table and SHALL make the
verdict REVIEW NEEDED.

#### Scenario: Internal load balancer and error budget
- **WHEN** the source describes an "internal load balancer" and an "error budget" of 43 minutes
- **THEN** both phrases survive in the deliverable, both appear under "Hits kept for review", and the verdict is REVIEW NEEDED

#### Scenario: Technical uses of label words
- **WHEN** the source says "the metrics endpoint is internal only", lists `- DRAFT` as a document status, and states "the estimated downtime for the cut-over is 2 hours"
- **THEN** no REMOVE pattern matches these lines; they are judged as REVIEW hits and kept when they describe the solution

#### Scenario: Internal-use label
- **WHEN** a kept section contains the line "INTERNAL: do not send to the customer"
- **THEN** the line does not appear in the deliverable and the removal is logged

### Requirement: Only AI authorship of the content is removed
client-facing-doc SHALL remove statements that the document or its text is AI-generated or
AI-assisted, assistant phrasing and prompt text. It SHALL keep AI models, services and features that
are part of the proposed solution as technical substance. The style rewrite, the self-checks and
the taxonomy SHALL state the same rule.

#### Scenario: AI component of the solution
- **WHEN** the source's architecture uses an LLM to classify support tickets
- **THEN** the deliverable describes that component like any other

#### Scenario: AI-written draft
- **WHEN** the source says "this section was generated with an AI assistant"
- **THEN** the sentence does not appear in the deliverable

### Requirement: The redaction audit is versioned with its deliverable
The redaction audit SHALL be written to `<working-docs>/<doc-name>-client-v<N>-redaction-audit.md`,
with the same `v<N>` as the deliverable it audits, so that a later run never overwrites an earlier
audit.

#### Scenario: Second run on the same source
- **WHEN** the skill runs a second time and writes `<doc-name>-client-v2.md`
- **THEN** it writes `<doc-name>-client-v2-redaction-audit.md` and leaves the v1 deliverable and v1 audit unchanged
