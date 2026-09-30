# Spec Delta

## Purpose

Defines how client-facing-doc proves that a client deliverable carries no confidential marker: a
fixed pattern scan of the written file that removes labels and figures, keeps technical vocabulary
for review, and leaves a versioned audit trail.

## ADDED Requirements

### Requirement: The residual scan runs fixed patterns on the written deliverable
client-facing-doc SHALL write the deliverable to its versioned path and then run the REMOVE patterns
of `references/residual-patterns.md` on that file with the Grep tool, removing every hit and logging
it, until no REMOVE pattern matches or three passes have run. The patterns SHALL cover currency
symbols, currency codes and words next to a figure (`EUR`, `euro`, `USD`, `k€`), effort units after a
figure (`MD`, `PD`, `gg`, `gg/uu`, `giornate/uomo`, `giorni/uomo`, man-days, person-days, man-hours,
`ore uomo`, story points), FTE, hours stated as effort, work-in-progress markers, internal-status
labels, assistant and prompt phrasing, and references to internal documents. When a REMOVE pattern
still matches after three passes, the skill SHALL report the lines and the audit verdict SHALL be
REVIEW NEEDED.

#### Scenario: Planted markers in kept sections
- **WHEN** the source's kept sections contain `EUR 40k`, `30 MD`, `12 gg`, `TODO`, a "Your task is…" prompt line and "see internal deck"
- **THEN** none of them appears in the written deliverable, and each removal is logged with its pattern ID

#### Scenario: Italian effort units
- **WHEN** the source states effort as `12 giornate/uomo` or `12 gg/uu`
- **THEN** the effort figure does not appear in the deliverable

#### Scenario: Plan before any write
- **WHEN** the skill presents its Include / Remove section plan
- **THEN** no file has been written yet, and the deliverable is written only after the user confirms the plan

### Requirement: Labels are removed, technical vocabulary is reviewed
The REMOVE patterns SHALL match internal-status labels only ("internal only", "uso interno",
`INTERNAL:`, `[DRAFT]`, a "RISERVATO" stamp), not the adjectives. Words that are also technical
vocabulary (internal, confidential, budget, cap, cost, margin) SHALL be matched by REVIEW patterns:
the skill SHALL remove a hit that carries commercial, effort, internal-status, internal-reference or
AI-authorship meaning, SHALL keep a hit that describes the solution, and SHALL remove it when unsure.
A kept REVIEW hit SHALL be listed in the audit's "Hits kept for review" table and SHALL make the
verdict REVIEW NEEDED.

#### Scenario: Internal load balancer and error budget
- **WHEN** the source describes an "internal load balancer" and an "error budget" of 43 minutes
- **THEN** both phrases survive in the deliverable, both appear under "Hits kept for review", and the verdict is REVIEW NEEDED

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
