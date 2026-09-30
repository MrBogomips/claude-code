# Spec Delta

## Purpose

Defines how bid-delivery-summary treats prices the source quotes without an approved cost model,
which confidentiality notice satisfies its header check, and what it records when a cost model is
authorized.

## ADDED Requirements

### Requirement: Unapproved prices become a clarification without figures
In effort-only mode, when the source quotes prices, rates or other cost figures that no approved cost
model backs, bid-delivery-summary SHALL NOT reproduce any of the figures and SHALL add to the Bid
Review Checklist's Commercial Clarifications the language pack's verbatim "unapproved cost figures"
item, naming where in the source the figures appear. Commercial Considerations SHALL still contain
only the effort-only statement.

#### Scenario: A price mentioned in passing
- **WHEN** the source says the previous vendor quoted €85,000 and no rate card is available
- **THEN** the summary contains no currency figure, Commercial Considerations holds only the effort-only statement, and Commercial Clarifications say the source quotes cost figures not backed by an approved model

### Requirement: The confidentiality notice follows the language pack
The summary SHALL begin with the language pack's verbatim confidentiality notice, and the header
self-check SHALL accept the notice of the output language (`INTERNAL USE ONLY` in English,
`SOLO PER USO INTERNO` in Italian).

#### Scenario: Italian summary
- **WHEN** the summary is written in Italian
- **THEN** it begins with `# SOLO PER USO INTERNO` and no English header is added

### Requirement: An authorized cost model is recorded with its approver
When the user authorizes an approved cost model, bid-delivery-summary SHALL ask whose authorization
to record and SHALL open Commercial Considerations with the cost basis: the model used (its name, and
its version or date when it has one), where it was found, and who authorized it.

#### Scenario: Rate card authorized
- **WHEN** the user confirms use of a versioned rate card and names the bid manager as authorizer
- **THEN** Commercial Considerations opens with the rate card's name and version, where it was found, and "Authorized by: bid manager"
