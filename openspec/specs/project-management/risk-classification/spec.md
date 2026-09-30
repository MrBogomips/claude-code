# project-management/risk-classification Specification

## Purpose
Defines one high-risk threshold for every skill of the project-management plugin.

## Requirements

### Requirement: A risk is high when P×I is at least 10
Every skill of the plugin SHALL treat a risk as high when Probability × Impact ≥ 10 on 1–5
scales: sow-write asks for a mitigation plan on it, sow-review expects one, sow-estimate flags it
when the mitigation is missing, and pmo-pert-estimate classifies it HIGH (10–14) or CRITICAL
(≥ 15) and writes its Risks-sheet row in red.

#### Scenario: Score of 10
- **WHEN** a risk has probability 2 and impact 5
- **THEN** it is high in every skill, and its Risks-sheet row is red with priority HIGH

#### Scenario: Score of 9
- **WHEN** a risk has probability 3 and impact 3
- **THEN** it is not high, its priority is MEDIUM, and its row is not red
